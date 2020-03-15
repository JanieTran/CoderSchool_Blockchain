pragma solidity ^0.4.18;


contract VirtLotto {
    // PROPERTIES
    // Ticket
    struct Ticket {
        address player;
        uint256 betAmount;
        uint256 number;
    }

    // Bet and calls
    uint256 public minBet;
    uint256 public maxCalls;
    uint256 public currentCalls;
    uint256 public currentBet;
    
    // List of player addresses
    address[] public players;
    address[] public winners;

    // List of tickets
    Ticket[] public tickets;
    
    // CONSTRUCTOR
    function VirtLotto(uint256 _minBet, uint256 _maxCalls) public {
        if (_minBet > 0) {
            minBet = _minBet;
        }
        maxCalls = _maxCalls;
        currentCalls = 0;
        currentBet = 0;
    }
    
    // GAME FUNCTIONS
    // Bet a number
    function pickNumber(uint256 number) public payable {
        // // Check if valid bet
        require(number >= 1 && number <= 10);
        require(msg.value >= minBet);
        require(isValidPlayer(msg.sender));

        // Player info
        address player = msg.sender;
        uint256 bet = msg.value;
        Ticket memory ticket = Ticket(player, bet, number);
        
        // Add player to list
        if (!listContain(players, player)) {
            players.push(player);
        }

        // Add bet to dictionary
        tickets.push(ticket);
        
        // Update bet and calls
        currentCalls++;
        currentBet += bet;
        
        // Finish round if calls are sufficient
        if (currentCalls >= maxCalls) {
            finishRound();
        }
    }
    
    // Finish round
    function finishRound() public {
        uint256 winningNumber = random();
        reward(winningNumber);

        // Reset bet amount, calls
        currentBet = 0;
        currentCalls = 0;

        // Remove all players
        players.length = 0;
        tickets.length = 0;
    }
    
    // Reward
    function reward(uint256 winningNumber) public {
        // Number of winners
        uint256 count = 1;

        // Find winners
        for (uint128 i = 0; i < tickets.length; i++) {
            address playerAddress = tickets[i].player;
            if (tickets[i].number == winningNumber) {
                count++;
                if (!listContain(winners, playerAddress)) {
                    winners.push(playerAddress);
                }
            }

            delete tickets[i];
        }

        // Calculate prize
        uint256 prize = currentBet / count;

        // Distribute prize
        for (uint128 j = 0; j < count - 1; j++) {
            // Check if valid address
            if (winners[j] != address(0)) {
                winners[j].transfer(prize);
            }
        }
    }

    // HELPER FUNCTIONS
    // Check if player still has tickets
    function isValidPlayer(address player) public returns (bool) {
        uint256 count = 0;
        for (uint256 i = 0; i < tickets.length; i++) {
            if (tickets[i].player == player) {
                count++;
            }
        }
        
        return count < 4;
    }

    // Check if list contains value
    function listContain(address[] list, address value) public returns (bool) {
        for (uint128 i = 0; i < list.length; i++) {
            if (list[i] == value) {
                return true;
            }
        }

        return false;
    }

    // Generate random number
    function random() public returns (uint256) {
        return uint256(keccak256(block.timestamp, block.difficulty)) % 10;
    }

    function lenTickets() public returns (uint) {
        return tickets.length;
    }
}