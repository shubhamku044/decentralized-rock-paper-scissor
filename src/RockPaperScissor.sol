// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract RockPaperScissor {
    enum Move {
        Rock,
        Paper,
        Scissors
    }

    struct Game {
        address player;
        Move playerMove;
        Move computerMove;
        string result;
        uint256 timestamp;
    }

    mapping(address => uint256) public wins;
    mapping(address => uint256) public losses;
    mapping(address => uint256) public draws;

    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    event GamePlayed(
        address indexed player,
        Move playerMove,
        Move computerMove,
        string result,
        uint256 timestamp
    );

    function playGame(uint8 _playerMove) public payable {
        require(msg.value >= 0 ether, "Insufficient funds to play the game");
        require(
            _playerMove <= 2,
            "Invalid move. Choose 0 (Rock), 1 (Paper), or 2 (Scissors)"
        );

        Move playerMove = Move(_playerMove);
        Move computerMove = getRandomMove(msg.sender);

        string memory result = determineWinner(playerMove, computerMove);
        uint256 amountWon = 0;

        if (keccak256(abi.encodePacked(result)) == keccak256("Win")) {
            uint256 reward = msg.value + (msg.value * 25) / 100;
            if (address(this).balance >= reward) {
                amountWon = reward;
                payable(msg.sender).transfer(reward);
            } else {
                amountWon = address(this).balance;
                payable(msg.sender).transfer(address(this).balance);
            }
            wins[msg.sender]++;
        } else if (keccak256(abi.encodePacked(result)) == keccak256("Lose")) {
            losses[msg.sender]++;
        } else {
            draws[msg.sender]++;
            payable(msg.sender).transfer(msg.value);
        }

        emit GamePlayed(
            msg.sender,
            playerMove,
            computerMove,
            result,
            block.timestamp
        );
    }

    function getRandomMove(address _player) private view returns (Move) {
        uint256 random = uint256(
            keccak256(abi.encodePacked(block.timestamp, _player))
        ) % 3;
        return Move(random);
    }

    function determineWinner(
        Move _playerMove,
        Move _computerMove
    ) private pure returns (string memory) {
        if (_playerMove == _computerMove) {
            return "Draw";
        } else if (
            (_playerMove == Move.Rock && _computerMove == Move.Scissors) ||
            (_playerMove == Move.Paper && _computerMove == Move.Rock) ||
            (_playerMove == Move.Scissors && _computerMove == Move.Paper)
        ) {
            return "Win";
        } else {
            return "Lose";
        }
    }

    function getStats(
        address _player
    ) public view returns (uint256 win, uint256 loss, uint256 draw) {
        return (wins[_player], losses[_player], draws[_player]);
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function withdraw(uint256 _amount) public onlyOwner {
        require(
            _amount <= address(this).balance,
            "Insufficient contract balance"
        );
        payable(owner).transfer(_amount);
    }

    receive() external payable {}
}
