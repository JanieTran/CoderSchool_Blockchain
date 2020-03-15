pragma solidity ^0.4.18;


contract Voting {
    address public owner;
    bytes32[] public candidateList;
    
    // function Voting() public {
    //     owner = msg.sender;
    // }
    struct Candidate {
        uint256 voteCount;
    }
    
    mapping (bytes32=>Candidate) candidateInfo;

    function Voting(bytes32[] candidateNames) public {
        candidateList = candidateNames;
    }

    function kill() public {
        if (msg.sender == owner) selfdestruct(owner);
    }

    function validCandidate(bytes32 candidate) public returns (bool) {
        for (uint256 i = 0; i < candidateList.length; i++) {
            if (candidateList[i] != candidate) {
                return true;
            }
        }
        return false;
    }

    function voteForCandidate(bytes32 candidate) payable {
        require(candidate.length != 0);
        // require(validCandidate(candidate));
        candidateInfo[candidate].voteCount = candidateInfo[candidate].voteCount+1;
    }

    function totalVotesFor(bytes32 candidate) public returns (uint256) {
        require(candidate.length != 0);
        return candidateInfo[candidate].voteCount;
    }

    function candidateList() public returns (bytes32[]) {
        return candidateList;
    }

    function contractOwner() public returns (address) {
        return owner;      
    }



    
}