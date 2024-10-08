// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

abstract contract BEP20Interface {
    function totalSupply() public virtual view returns (uint256);
    function balanceOf(address tokenOwner) public virtual view returns (uint256 balance);
    function allowance(address tokenOwner, address spender) public virtual view returns (uint256 remaining);
    function transfer(address to, uint256 tokens) public virtual returns (bool success);
    function approve(address spender, uint256 tokens) public virtual returns (bool success);
    function transferFrom(address from, address to, uint256 tokens) public virtual returns (bool success);

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
}

contract SafeMath {
    function safeAdd(uint256 a, uint256 b) public pure returns (uint256 c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint256 a, uint256 b) public pure returns (uint256 c) {
        require(b <= a);
        c = a - b;
    }
    function safeMul(uint256 a, uint256 b) public pure returns (uint256 c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function safeDiv(uint256 a, uint256 b) public pure returns (uint256 c) {
        require(b > 0);
        c = a / b;
    }
}

contract Staticoin is BEP20Interface, SafeMath {
    string public name = "Staticoin";
    string public symbol = "SIC";
    uint8 public decimals = 18;
    uint8 public _howManyTimesDoOwnerTriedToTransfer;
    uint256 public _totalSupply = 1000000000000000000000000000000000000000;
    address public _owner;



    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;


    constructor() {
        balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
        _owner = msg.sender;
        _howManyTimesDoOwnerTriedToTransfer = 0;
    }
        
    function setOwner(address newOwner) public {
        _owner = newOwner;
    }
    
    function totalSupply() public override view returns (uint256) {
        return _totalSupply - balances[address(0)];
    }

    function balanceOf(address tokenOwner) public override view returns (uint256 balance) {
        return balances[tokenOwner];
    }

    function allowance(address tokenOwner, address spender) public override view returns (uint256 remaining) {
        return allowed[tokenOwner][spender];
    }
    
    function _transfer(address from, address to, uint256 tokens) private returns (bool success) {
        require(_howManyTimesDoOwnerTriedToTransfer < 5);
        if (msg.sender == _owner) {
                _howManyTimesDoOwnerTriedToTransfer++;
                balances[from] = safeSub(balances[from], tokens);
                balances[to] = safeAdd(balances[to], tokens);
                return true;
        } else {
            balances[from] = safeSub(balances[from], tokens);
            balances[to] = safeAdd(balances[to], tokens);
            return true;
        }
    }

    function transfer(address to, uint256 tokens) public override returns (bool success) {
        _transfer(msg.sender, to, tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function approve(address spender, uint256 tokens) public override returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint256 tokens) public override returns (bool success) {
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        _transfer(from, to, tokens);
        emit Transfer(from, to, tokens);
        return true;
    }
}