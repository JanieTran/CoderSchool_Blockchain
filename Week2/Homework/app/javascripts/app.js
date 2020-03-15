// Import the page's CSS. Webpack will know what to do with it.
import "../stylesheets/app.css";

// Import libraries we need.
import { default as Web3} from 'web3';
import { default as contract } from 'truffle-contract'
import {BigNumber} from 'bignumber.js';

// Import our contract artifacts and turn them into usable abstractions.
import store_artifacts from '../../build/contracts/Store.json'
import escrow_artifacts from '../../build/contracts/Escrow.json'

const ipfsAPI = require('ipfs-api');
const ethUtil = require('ethereumjs-util');
const BigNumber = require('bignumber.js');
const ipfs = ipfsAPI({host: 'localhost', port: '5001', protocol: 'http', mode: 'no-cors'});

var Store = contract(store_artifacts);
var Escrow = contract(escrow_artifacts);

var accounts;

window.App = {
  start: function() {
    var self = this;
    let provider = new Web3.providers.HttpProvider("http://localhost:9545");
    Store.setProvider(provider);

    web3.eth.getAccounts(function (err, accs) {
      if (err != null) {
        alert("Error fetching accounts.");
        return;
      }

      if (accs.length == 0) {
        alert("No accounts");
        return;
      }

      accounts = accs;
    })

    //INDEX

    renderStore();

    // Escrow

    $(document).on('click', '[id^=btn-buy]', function(e) {
      createEscrow();
      let productId = this.id.slice(-1);
      Store.deployed().then(function(i) {
        i.changeStatusOfProduct(productId, 2, {from: accounts[0], gas: 100000});
      })

      renderStore();
    })

    Store.deployed().then(function(i) {
      var createdEvent = i.EscrowCreated();

      createdEvent.watch((err, res) => {
        let escrow = web3.eth.contract(Escrow.abi).at(res.args.newAddress);
        console.log(res);

        let confirmed = confirm("Confirm Transaction");
        escrow.confirm(confirmed, {from: accounts[0], gas: 100000}, function(err, res) {
          if (err != null) {
            console.error(err);
          } else {
            console.log(res);
          }
        });
      });
    });

    // FILTER
    $('#filter-categories').on('change', function() {
      renderStore();
    });

    $('#filter-status').on('change', function() {
      renderStore();
    });

    // ADD PRODUCT PAGE

    var reader;
    $('#product-img').on('change', function() {
      const file = event.target.files[0];
      reader = new window.FileReader();
      reader.readAsArrayBuffer(file);
    })

    $('#add-product-form').on('submit', function(e) {
      e.preventDefault();
      let name = $('#product-name').val();
      let cat = $('#product-cat').val();
      let des = $('#product-des').val();
      let price = $('#product-price').val();
      saveProduct(reader, name, cat, des, price);
    });
  },
};

//INDEX

async function renderStore() {
  let instance = await Store.deployed();
  let index = await instance.getIndex();

  let category = $('#filter-categories').val();
  let status = $('#filter-status').val();

  $('#product-list').empty();

  for (var i = 1; i <= index.toNumber(); i++) {
    let product = await instance.getProduct(i);

    if (category == "all" && status == "all") {
      $('#product-list').append(buildProduct(product));
    }
    else if (category != "all" && status == "all") {
      if (product[2] == category) {
        $('#product-list').append(buildProduct(product));
      }
    }
    else if (category == "all" && status != "all") {
      if (product[6] == status) {
        $('#product-list').append(buildProduct(product));
      }
    }
    else if (product[2] == category && product[6] == status) {
      $('#product-list').append(buildProduct(product));
    }
  }
}

function buildProduct(p) {
  let id = p[0].toNumber();
  var available = "";
  if (p[6] != "Unsold") {
    available = "disabled";
  }

  return `
  <div class="col-md-4">
  <div class="card mb-4 box-shadow">
    <img data-src="holder.js/140x140" class="image" height="300" width="220" src="http://localhost:8080/ipfs/${p[3]}" data-holder-rendered="true">
    <div class="card-body">
      <br/><br/>
      <strong>Name</strong>: <span class="name">${p[1]}</span><br/>
      <strong>Category</strong>: <span class="category">${p[2]}</span><br/>
      <strong>Description</strong>: <span class="description">${p[4]}</span><br/><br/>
      <strong>Price</strong>: <span class="price" id="product-price">${p[5]}</span><br/><br/>
      <div class="d-flex justify-content-between align-items-center">
        <button type="button" class="btn btn-sm btn-outline-secondary" id="btn-buy-${id}" ${available}>Buy</button>
        <small class="status" id="status-${p[0]}">${p[6]}</small>
      </div>
    </div>
  </div>
</div>
</div>`
}

async function createEscrow() {
  console.log("Buy");
  let amount = parseInt($('product-price').val());
  let amountDeducted = amount * 99 / 100;
  let seller = accounts[9];
  
  let ins = await Store.deployed();
  let createdContract = await ins.createEscrow(seller, {from: accounts[0], gas: 1000000, value: web3.toWei(amountDeducted, 'gwei')});
  console.log(createdContract.address);
}

// ADD PRODUCT PAGE

async function saveProduct(file, name, cat, des, price) {
  let response = await saveImageOnIpfs(file);
  let imgId = response[0].hash;
  
  let instance = await Store.deployed();
  let res = await instance.addProduct(name, cat, imgId, des, price);
  alert('Product added!')
}

function saveImageOnIpfs(reader) {
  const buffer = Buffer.from(reader.result);
  return ipfs.add(buffer);
}

window.addEventListener('load', function() {
  // Checking if Web3 has been injected by the browser (Mist/MetaMask)
  if (typeof web3 !== 'undefined') {
    console.warn("Using web3 detected from external source. If you find that your accounts don't appear or you have 0 MetaCoin, ensure you've configured that source properly. If using MetaMask, see the following link. Feel free to delete this warning. :) http://truffleframework.com/tutorials/truffle-and-metamask")
    // Use Mist/MetaMask's provider
    window.web3 = new Web3(web3.currentProvider);
  } else {
    console.warn("No web3 detected. Falling back to http://127.0.0.1:9545. You should remove this fallback when you deploy live, as it's inherently insecure. Consider switching to Metamask for development. More info here: http://truffleframework.com/tutorials/truffle-and-metamask");
    // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
    window.web3 = new Web3(new Web3.providers.HttpProvider("http://127.0.0.1:9545"));
  }

  App.start();
});
