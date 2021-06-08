pragma solidity ^0.7.3;


contract RockPaperScissors{

    bytes32 constant ROCK = keccak256("rock");
    bytes32 constant PAPER = keccak256("paper");
    bytes32 constant SCISSOR = keccak256("scissor");

    mapping (address => bytes32) public bets;
    mapping (address=>uint256) private _balanceOf;

    address firstplayer;
    address winner;
    uint starttime;
    uint timelimit;

    //to prevent that anyone cannot withdraw their funds before the final result
    bool locked;

    constructor() public{}

    modifier balance(uint _amount){
        require(msg.value >= _amount, "not enough to bet");
        _;
    }

    function deposit() external payable balance(1 ether) {
        _balanceOf[msg.sender] = msg.value;
        locked = true;
    }


    //you have to pass the keccak256 hash for security reasons
    function bet(bytes32 move) external{
        require(_balanceOf[msg.sender] >= 1 ether, "you need to deposit founds to bet");
        require(move == ROCK || move == PAPER || move == SCISSOR);
        require(bets[msg.sender] == 0);
        if(firstplayer == address(0)){
            firstplayer = msg.sender;
            starttime = block.number;
            timelimit = starttime + 10;
        }
        bets[msg.sender] = move;
    } 

    function evaluate(address alice,address bob) external{
        require(_balanceOf[alice] >= 1 ether);
        require(_balanceOf[bob] >= 1 ether);
        uint256 prize = _balanceOf[alice] + _balanceOf[bob];

        //if the time limit is reached the prize will be given to the only player that makes his move 
        if(block.number >= timelimit){
            if(firstplayer == alice){
                _balanceOf[firstplayer] = prize;
                _balanceOf[bob] = 0;
            }else if(firstplayer == bob){
                _balanceOf[firstplayer] = prize;
                _balanceOf[alice] = 0;
            }
            locked = false;
            winner = firstplayer;
        }else{
            //is a draw and nothing happen with the balances
            if(bets[alice] == bets[bob]){
                locked = false;
                winner = address(0);
            }
            if(bets[alice] == ROCK && bets[bob] == PAPER){
                _balanceOf[bob] = prize;
                _balanceOf[alice] = 0;
                locked = false;
                winner = bob;
            }else if(bets[bob] == ROCK && bets[alice] == PAPER){
                _balanceOf[alice] = prize;
                _balanceOf[bob] = 0;
                locked = false;
                winner = alice;
            }else if(bets[alice] == SCISSOR && bets[bob] == PAPER){
                _balanceOf[alice] = prize;
                _balanceOf[bob] = 0;
                locked = false;
                winner = alice;
            }else if(bets[bob] == SCISSOR && bets[alice] == PAPER){
                _balanceOf[bob] = prize;
                _balanceOf[alice] = 0;
                locked = false;
                winner = bob;
            }else if(bets[alice] == ROCK && bets[bob] == SCISSOR){
                _balanceOf[alice] = prize;
                _balanceOf[bob] = 0;
                locked = false;
                winner = alice;
            }else if(bets[bob] == ROCK && bets[alice] == SCISSOR){
                _balanceOf[bob] = prize;
                _balanceOf[alice] = 0;
                locked = false;
                winner = bob;
            }
        }
    }

    //
    modifier isLocked{
        require(!locked);
        _;
    }

    
    function getWinner() external isLocked view returns (address){
        return winner;    
    }

    // favor pull over push
    function withdrawPrize() external isLocked{
        uint prize = _balanceOf[msg.sender];
        _balanceOf[msg.sender] = 0;
        (bool success,) = msg.sender.call{value:prize}("");
        require(success);
    }
    
}