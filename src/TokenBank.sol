// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 引入ERC20接口定义
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract TokenBank {
    // 状态变量
    IERC20 public token;
    mapping(address => uint256) public balances;
    
    // 事件
    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    
    // 构造函数
    constructor(address _tokenAddress) {
        token = IERC20(_tokenAddress);
    }
    
    /**
     * @dev 存入代币到银行
     * @param _amount 存入的代币数量
     */
    function deposit(uint256 _amount) public {
        require(_amount > 0, "Deposit amount must be greater than 0");
        
        // 1. 检查用户是否已经授权足够的代币给银行，用户授权token给TokenBank合约
        require(token.allowance(msg.sender, address(this)) >= _amount, "Token allowance not sufficient");
        
        // 2. 从用户账户转移代币到银行，
        require(token.transferFrom(msg.sender, address(this), _amount), "Token transfer failed");
        
        // 3. 更新用户在银行的存款余额
        balances[msg.sender] += _amount;
        
        // 4. 发出存款事件
        emit Deposited(msg.sender, _amount);
    }
    
    /**
     * @dev 从银行提取代币
     * @param _amount 提取的代币数量
     */
    function withdraw(uint256 _amount) public {
        require(_amount > 0, "Withdraw amount must be greater than 0");
        
        // 1. 检查用户在银行的存款余额是否足够
        require(balances[msg.sender] >= _amount, "Insufficient balance in bank");
        
        // 2. 更新用户在银行的存款余额
        balances[msg.sender] -= _amount;
        
        // 3. 从银行转移代币到用户账户
        require(token.transfer(msg.sender, _amount), "Token transfer failed");
        
        // 4. 发出提款事件
        emit Withdrawn(msg.sender, _amount);
    }
    
    /**
     * @dev 获取银行当前持有的总代币数量
     */
    function getTotalTokens() public view returns (uint256) {
        return token.balanceOf(address(this));
    }
}