web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:7545"));
abi = JSON.parse('[{"constant":false,"inputs":[{"name":"candidate","type":"bytes32"}],"name":"getVotes","outputs":[{"name":"","type":"uint8"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"candidate","type":"bytes32"}],"name":"validCandidate","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"","type":"bytes32"}],"name":"votesReceived","outputs":[{"name":"","type":"uint8"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"x","type":"bytes32"}],"name":"bytes32ToString","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"","type":"uint256"}],"name":"candidateList","outputs":[{"name":"","type":"bytes32"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"candidate","type":"bytes32"}],"name":"vote","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"inputs":[{"name":"candidateNames","type":"bytes32[]"}],"payable":false,"type":"constructor"}]')
VotingContract = web3.eth.contract(abi);

contractInstance = VotingContract.at('0xeec918d74c746167564401103096d45bbd494b74');

candidates = {"Rama": "candidate-1", "Nick": "candidate-2", "Jose": "candidate-3"}

function vote() {
    candidateName = $("#candidate").val();
    contractInstance.vote(candidateName, {from: web3.eth.accounts[0]}, function() {
        let div_id = candidates[candidateName];
        $("#" + div_id).html(contractInstance.getVotes.call(candidateName).toString());
    });
}

$(document).ready(function () {
    candidateNames = Object.keys(candidates);
    for (var i = 0; i < candidateNames.length; i++) {
        let name = candidateNames[i];
        let val = contractInstance.getVotes.call(name).toString()
        $("#" + candidates[name]).html(val);
    }
});