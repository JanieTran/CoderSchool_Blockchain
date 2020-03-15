pragma solidity ^0.4.17;


contract Escrow {
    address public buyer;
    address public seller;
    bool public buyerOk = false;
    bool public sellerOk = false;
    uint createdAt = 0;

    function Escrow(address _seller) public payable {
        require(_seller != address(0));

        buyer = msg.sender;
        seller = _seller;
        createdAt = now;
    }

    function confirm(bool _accepted) public {
        require(msg.sender == buyer || msg.sender == seller);

        if (!_accepted) {
            selfdestruct(buyer);
        } else {
            if (msg.sender == seller) {
                sellerOk = _accepted;
            } else {
                buyerOk = _accepted;
            }
        }

        if (sellerOk && buyerOk) {
            selfdestruct(seller);
        }
    }
}


contract Store {
    // PROPERTIES
    string[3] public productStatus = ["Unsold", "Sold", "Buying"];

    uint public index;

    // Mapping seller to their products - 1 to many
    mapping (address => mapping (uint => Product)) stores;
    // Mapping product to seller - 1 to 1
    mapping (uint => address) productIdInStore;

    struct Product {
        uint id;
        string name;
        string cat;
        string img;
        string des;
        uint price;
        string status;
    }

    event EscrowCreated(address newAddress);

    // CONSTRUCTOR
    function Store() public {
        index = 0;
    }

    // FUNCTIONS
    function addProduct(string _n, string _c, string _i, string _d, uint _p) public {
        index++;
        Product memory product = Product(index, _n, _c, _i, _d, _p, productStatus[0]);
        stores[msg.sender][index] = product;
        productIdInStore[index] = msg.sender;
    }

    function getProduct(uint _id) public view returns (uint, string, string, string, string, uint, string) {
        address store = productIdInStore[_id];
        Product memory p = stores[store][_id];

        return (p.id, p.name, p.cat, p.img, p.des, p.price, p.status);
    }

    function getIndex() public view returns (uint) {
        return index;
    }

    function changeStatusOfProduct(uint _id, uint _status) public {
        address store = productIdInStore[_id];
        Product p = stores[store][_id];

        p.status = productStatus[_status];
    }

    // ESCROW FUNCTIONS
    function createEscrow() public payable {
        address addr = address((new Escrow).value(msg.value)(0x5aeda56215b167893e80b4fe645ba6d5bab767de));
        EscrowCreated(addr);
    }
}