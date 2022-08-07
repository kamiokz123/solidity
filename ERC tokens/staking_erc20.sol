// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMath {
   
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

   
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

   
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
           
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

   
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

  
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

   
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

   
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

  
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }


    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

  
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

   
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

   
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}


interface IERC20upgrade{
     event Transfer(address indexed from, address indexed to, uint256 value);

   
    event Approval(address indexed owner, address indexed spender, uint256 value);

  
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

   
    function transfer(address to, uint256 amount) external returns (bool);

   
    function allowance(address owner, address spender) external view returns (uint256);

    
    function approve(address spender, uint256 amount) external returns (bool);

  
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}


contract staking{
    using SafeMath for uint256;
    struct users_data{
        uint256 amount_locked;
        uint256 claimed;
        uint256 lastreward;
    }
    event stake(address staker,uint256 lockamount);
    event unstake(address staker,uint256 lockamount);

    mapping(address=>users_data) public staker;
    uint256 public total_stake_amount;
    uint256 public apy;
    IERC20upgrade public token1;
    uint256 public total_stakers;
    address public con_owner;

    constructor(IERC20upgrade _token,uint256 _apy){
        token1=_token;
        apy=_apy;
        con_owner=msg.sender;
    }


function stake_amount(uint256 amount_)external{
    require(staker[msg.sender].amount_locked==0,"you are already staker");
    token1.transferFrom(msg.sender,address(this),amount_);
    staker[msg.sender]=users_data(
        amount_,
        0,
        block.timestamp
    );
    total_stakers++;
    total_stake_amount+=amount_;

    emit stake(msg.sender,amount_);
}


function unstake_amount()external{
    require(staker[msg.sender].amount_locked>0,"you are not staker");
    uint256 amount_= staker[msg.sender].amount_locked;
    token1.transfer(msg.sender,staker[msg.sender].amount_locked);
    staker[msg.sender].amount_locked=0;
    total_stake_amount-=amount_;
    total_stakers--;

    emit unstake(msg.sender,amount_);
}

function claimable(address _user)public view returns(uint256){
     require(staker[msg.sender].amount_locked>0,"you are not staker");

     uint256 staking_days=((block.timestamp-staker[_user].lastreward).div(1 days));
     uint256 reward_per_day=(((staker[_user].amount_locked.div(10000))*apy).div(365));
     return staking_days.mul(reward_per_day);


}

function redeem()external {
    require(staker[msg.sender].amount_locked>0,"you are not staker");
    uint256 a=claimable(msg.sender);
    token1.transfer(msg.sender,staker[msg.sender].amount_locked+a);
    staker[msg.sender].amount_locked=0;
    staker[msg.sender].claimed=a;
     staker[msg.sender].lastreward=block.timestamp;
     total_stakers--;
     total_stake_amount-=staker[msg.sender].amount_locked;

}


}