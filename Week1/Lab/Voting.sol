pragma solidity ^0.4.18;


contract Voting {
    // PROPERTIES
    // Address of the owner of the contract
    address public owner;

    // List of candidates
    bytes32[] public candidateList;

    // Candidate - vote mapping
    mapping (bytes32 => uint256) candidateVote;

    // CONSTRUCTOR
    function Voting(bytes32[] candidateNames) public {
        owner = msg.sender;
        candidateList = candidateNames;
    }

    // FUNCTIONS
    // Vote for candidate
    function vote(bytes32 name) public {
        candidateVote[name] += 1;
    }

    // Get votes of candidate
    function getVotes(bytes32 name) public returns (uint256) {
        return candidateVote[name];
    }

    function kill() public {
        if (msg.sender == owner) {
            selfdestruct(owner);
        }
    }
}