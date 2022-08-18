//SPDX-License-Identifier: UNLICENSED

// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.8.9;

// We import this library to be able to use console.log
import "hardhat/console.sol";

// This is the main building block for smart contracts.
contract Token {
    // Some string type variables to identify the token.
    //ERC20 must have name,symbol,decimals,totalSupply,owner field.
    string public name = "ZHH Token";
    string public symbol = "ZHT";
    uint8 public decimals = 2;
    string public version = "v0.1";
    // The fixed amount of tokens stored in an unsigned integer type variable.
    uint256 public totalSupply = 1000000*decimals;

    // An address type variable is used to store ethereum accounts.
    address public owner;

    // A mapping is a key/value map. Here we store each account balance.
    mapping(address => uint256) balances;

    // The Transfer event helps off-chain aplications understand
    // what happens within your contract.
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    /**
     * Contract initialization.
     */
    constructor() {
        // The totalSupply is assigned to the transaction sender, which is the
        // account that is deploying the contract.
        balances[msg.sender] = totalSupply;
        //address(this).balance = totalSupply - 1000;

        owner = msg.sender;
        //owner.transfer(1000);
    }

    // this function is called when someone sends ether to the 
    // token contract
    receive() external payable {        
        // msg.value (in Wei) is the ether sent to the 
        // token contract
        // msg.sender is the account that sends the ether to the 
        // token contract
        // amount is the token bought by the sender
        // 1 eth buy 100 token
        uint256 amount = msg.value*100;
        // ensure you have enough tokens to sell
        require(balanceOf(owner) >= amount, 
            "Not enough tokens");
        // transfer the token to the buyer
        _transfer(owner, msg.sender, amount);
        // emit an event to inform of the transfer        
        emit Transfer(owner, msg.sender, amount);
        
        // send the ether earned to the token owner
        payable(owner).transfer(msg.value);
    }

    /*
    * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        balances[sender] = senderBalance - amount;
        balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    /**  mint `amount` tokens and assigns them to `account`,  increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        require(balances[account] + amount > balances[account], "overflow");

        totalSupply += amount;
        balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }
    /**
     * A function to transfer tokens.
     *
     * The `external` modifier makes a function *only* callable from outside
     * the contract.
     */
    function transfer(address to, uint256 amount) external {
        // Check if the transaction sender has enough tokens.
        // If `require`'s first argument evaluates to `false` then the
        // transaction will revert.
        require(to != address(0));
        require(balances[msg.sender] >= amount, "Not enough tokens");
        require(
            balances[to] + amount > balances[to],
            "negtive value not allowed"
        );
        // We can print messages and values using console.log, a feature of
        // Hardhat Network:
        console.log(
            "Transferring from %s to %s %s tokens",
            msg.sender,
            to,
            amount
        );

        // Transfer the amount.
        balances[msg.sender] -= amount;
        balances[to] += amount;

        // Notify off-chain applications of the transfer.
        emit Transfer(msg.sender, to, amount);
    }

    /**
     * Read only function to retrieve the token balance of a given account.
     *
     * The `view` modifier indicates that it doesn't modify the contract's
     * state, which allows us to call it without executing a transaction.
     */
    function balanceOf(address account)
        public
        view
        returns (uint256)
    {
        return balances[account];
    }

    //mine to account
    function mint(address payable account, uint256 value)
        external
        returns (uint256)
    {
        require(msg.sender == owner, "You are not owner");
        
        
        _mint(account, value);

        console.log("transfer to %s value %d", account, value);
        return value;
    }
}
