Web3 = require('web3')
web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:7545"))
fs = require('fs')

code = fs.readFileSync('VirtLotto.sol').toString();
solc = require('solc');
compiledCode = solc.compile(code);
abi = JSON.parse(compiledCode.contracts[':VirtLotto'].interface);

VirtLottoContract = web3.eth.contract(abi)

byteCode = compiledCode.contracts[':VirtLotto'].bytecode 

deployedContract = VirtLottoContract.new(
    1, 5,
    {
        data: byteCode,
        from: web3.eth.accounts[0],
        gas: 2000000
    }
)

contractInstance = VirtLottoContract.at(deployedContract.address)

console.log(abi);
console.log("***************************************");
console.log(contractInstance.address);
console.log("***************************************");
