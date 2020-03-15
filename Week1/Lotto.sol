pragma solidity 0.4.20; // version

contract Lotto {
    // PROPERTIES
    
    // owner of contract
    address public owner;
    
    // minimum allowed bet
    uint256 minimumBet = 100 finney; // 0.1 Ether
    
    // total bet so far
    uint256 public totalBet = 0;
    
    // total number of bets so far
    uint256 public numberOfBets = 0;
    
    // maximum number of bets
    uint256 public constant maxNumberOfBets = 10;
    
    // range of bet amount
    uint256 public constant range = 10;
    
    // list of players
    address [] public players;
    
    struct Bet {
        uint256 amountBet;
        uint256 numberSelected;
    }
    
    mapping(address => Bet) public playerInfo;
    
    // FUNCTIONS
    
    // constructor
    function Lotto(uint256 _minimumBet) public {
        if (minimumBet > 0) {
            minimumBet = _minimumBet;
        }
        owner = msg.sender;
    }
    
    // place a bet
    function bet(uint256 numberSelected) public payable {
        // payable: have to send some ether along when call
        
        require(numberSelected >= 1 && numberSelected <= range);
        require(msg.value >= minimumBet);
        require(!checkPlayerExists(msg.sender));
        
        playerInfo[msg.sender].amountBet = msg.value;
        playerInfo[msg.sender].numberSelected = numberSelected;
        
        players.push(msg.sender);
        
        totalBet += msg.value;
        numberOfBets++;
        
        if (numberOfBets >= maxNumberOfBets) {
            generateWinner();
        }
    }
    
    // check if player exists
    function checkPlayerExists(address player) public returns (bool) {
        for (uint256 i = 0; i < players.length; i++) {
            if (players[i] == player) {
                return true;
            }
        }
        return false;
    }
    
    // generate winner 
    function generateWinner() public {
        uint256 winningNumber = (block.number % range) + 1;
        
        distributePrize(winningNumber);
    }
    
    // distribute prize
    function distributePrize(uint256 winningNumber) public {
        address[maxNumberOfBets] memory winners;
        
        // number of winners
        uint256 count = 0;
        
        // filter the winners
        for (uint256 i = 0; i < players.length; i++) {
            address playerAddress = players[i];
            if (playerInfo[playerAddress].numberSelected == winningNumber) {
                winners[count] = playerAddress;
                count ++;
            }
            
            // remove players
            delete playerInfo[playerAddress];
        }
        
        // remove players
        players.length = 0;
        
        // calculate prize
        uint256 winnerEtherAmount = totalBet / count;
        
        // distribute prize
        for (uint256 j = 0; i < count; j++) {
            if (winners[j] != address(0)) { // check if valid address
                winners[j].transfer(winnerEtherAmount);
            }
        }
        
        // reset bet amount 
        totalBet = 0;
    }
}