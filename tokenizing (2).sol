// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/Context.sol";

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint256 private _totalPrize;
    uint8 private _decimals;
    uint256 private _mintToken;

    string private _name;
    string private _symbol;

    address private _owner;

    bool private _status;

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 mintToken_,
        uint256 totalPrize_,
        uint8 decimals_,
        address _owner_
    ) {
        _name = name_;
        _symbol = symbol_;
        _mintToken = mintToken_;
        _totalPrize = totalPrize_;
        _owner = _owner_;
        _decimals = decimals_;
        _mint();
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function totalPrize() public view returns (uint256) {
        return _totalPrize;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint() internal virtual {
        require(_owner != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), _owner, _mintToken);

        _totalSupply += _mintToken;
        unchecked {
            // Overflow not possible: balance + _mintToken is at most totalSupply + _mintToken, which is checked above.
            _balances[_owner] += _mintToken;
        }
        emit Transfer(address(0), _owner, _mintToken);

        _afterTokenTransfer(address(0), _owner, _mintToken);
    }

    //OnlyOwner
    function _mintAfterDeploy(uint256 _amount, address _tokenOwner) external {
        require(msg.sender != address(0), "ERC20: mint to the zero address");
        require(_tokenOwner == _owner, "OnlyOwner Function");
        _beforeTokenTransfer(address(0), msg.sender, _amount);

        _totalSupply += _amount;
        unchecked {
            _balances[msg.sender] += _amount;
        }
        emit Transfer(address(0), msg.sender, _amount);

        _afterTokenTransfer(address(0), msg.sender, _amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    //OnlyOwner
    function withdrawFunds(uint256 _amount, address _tokenOwner)
        external
        payable
    {
        require(
            _amount <= address(this).balance,
            "amount is greater than balance of contract"
        );
        require(_tokenOwner == _owner, "OnlyOwner Function");
        payable(_owner).transfer(_amount);
    }

    //OnlyOwner
    function banalanceOfContract(address _tokenOwner)
        external
        view
        returns (uint256)
    {
        require(_tokenOwner == _owner, "OnlyOwner Function");
        return address(this).balance;
    }

    //OnlyOwner
    function enableSell(address _tokenOwner) external {
        require(_tokenOwner == _owner, "OnlyOwner Function");
        _status = true;
    }

    //OnlyOwner
    function disableSell(address _tokenOwner) external {
        require(_tokenOwner == _owner, "OnlyOwner Function");
        _status = false;
    }

    receive() external payable {
        require(
            msg.sender != address(0),
            "zero address cant run this function"
        );
        require(_status, "Selling status should be enable");
        _approve(_owner, msg.sender, msg.value / _totalPrize);
        transferFrom(_owner, msg.sender, msg.value / _totalPrize);
    }
}

contract TokenFactory {
    mapping(address => address) public tokenMaps;

    function creatNewToken(
        string memory name_,
        string memory symbol_,
        uint256 mintToken_,
        uint256 totalPrize_,
        uint8 decimals_
    ) public {
        ERC20 token = new ERC20(
            name_,
            symbol_,
            mintToken_,
            totalPrize_,
            decimals_,
            msg.sender
        );
        tokenMaps[msg.sender] = address(token);
    }
}
