window.App = {
    start: function() {
        var self = this;
        let provider = new Web3.providers.HttpProvider("http://localhost:9545");
        self.setProvider(provider);
        renderStore();
    },
};

async function renderStore() {
    let instance = await Store.deployed();
    let product = instance.getProduct.call(1);
    $('#product-list').append(buildProduct(product));
}

const file = event.target.files[0];
reader = new window.FileReader();
reader.readAsArrayBuffer(file);

async function saveProduct(fileReader, productName) {
    let response = await saveImageOnIpfs(fileReader);
    let imageId = response[0].hash;

    let instance = await Store.deployed();
    let res = await instance.addProduct(productName, 'cat', imageId, 1, {from: web3.eth.accounts[0], gas: 440000});
    alert('Product added.')
}

function saveImageOnIpfs(reader) {
    const buffer = Buffer.from(reader.result);
    return saveImageOnIpfs.add(buffer);
}