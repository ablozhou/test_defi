// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Import this file to use console.log
import "hardhat/console.sol";

/*Account #0: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 (10000 ETH)
Private Key: 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

Account #1: 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 (10000 ETH)
Private Key: 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
*/

contract Lock {
    //存储类型：
    //所有的复杂类型，即数组和结构类型，都有一个额外属性，“数据位置”
    //说明数据是保存在 内存memory 中还是 存储storage 中。大多数时候数据有默认的位置，但也可以通过在类型名后增加关键字 storage 或 memory 进行修改
    //函数参数（包括返回的参数）的数据位置默认是 memory， 局部变量的数据位置默认是 storage，状态变量的数据位置强制是 storage
    //第三种数据位置calldata

    //这是一块只读的，且不会永久存储的位置，用来存储函数参数。
    //外部函数的参数（非返回参数）的数据位置被强制指定为 calldata ，效果跟 memory 差不多。
    uint256 public unlockTime;

    //只有payable修饰的才能调用.transfer()和.send()
    //address payable 可以隐式转为 address，address转为address payable 需要先转化为整数类型（如unit160）
    //solidity的内置变量中，一下都是address payable

    //    msg.sender
    //    tx.origin
    //    block.coinbase
    address payable public owner;

    event Withdrawal(uint256 amount, uint256 when);

    //锁仓初始化，发送锁仓时间和金额，但直接放到msg.value里，不用做任何处理，直接转到合约账户。、
    //payable  当一个函数被 payable 修饰，表示调用这个函数时，可以附加发送一些 ETH（当然也可以不发）。

    //没有加 payable 的函数，则没有方法接受 ETH， 附加 ETH 调用会出错。
    constructor(uint256 _unlockTime) payable {
        require(
            block.timestamp < _unlockTime,
            "Unlock time should be in the future"
        );

        unlockTime = _unlockTime;
        owner = payable(msg.sender);
    }

    //获取合约地址
    function getContractAddr() public view returns (address) {
        return address(this);
    }

    //view 修饰的函数 ，是constant的别名，只能读取storage变量的值，不能写入。修改变量，产生事件，调用发送以太币，调用任何没有view或pure的函数，创建其他合约等都是写入。
    //获取所有者地址
    function getOwner() public view returns (address) {
        return owner;
    }

    //获取锁仓时间
    function getUnlockTime() public view returns (uint256) {
        return unlockTime;
    }

    //获取合约余额
    function getContractBalance() public view returns (uint256) {
        require(msg.sender == owner, "You aren't the owner");
        console.log("balance is %d", address(this).balance);
        return address(this).balance;
    }

    //1.ETH不能直接转账至合约账户，如果接受者为合约，我们需要定义一个支付函数
    //给合约转账，不需要设置transfer，直接在web3中添加msg.value
    //contact.methods.pay().send({msg.sender:myaddress,gas:2000000,value:10*10**18}).then();
    //value为转账金额，以太精度为10**18
    //2. 当接收方为账户时，发送方可以是账户，也可以是合约。区别在于有没有传递msg.value.
    //提供了则是提供的账户转接收账户，没有提供则直接从合约转账户。
    //但如果同时要从账户和合约转呢？
    //msg.value是大数，除2后为整数，实现一半转账户account1，另一半转给合约本身。msg.value大于要转给账户的值时，多余的会转给合约。
    //function pay()payable{
    //  acount1.transfer(msg.value / 2);
    //}
    // /public修饰的变量和函数，任何用户或者合约都能调用和访问。
    //private修饰的变量和函数，只能在其所在的合约中调用和访问，即使是其子合约也没有权限访问。
    //internal 和 private 类似，不过， 如果某个合约继承自其父合约，这个合约即可以访问父合约中定义的“内部”函数。
    // /external 与public 类似，只不过这些函数只能在合约之外调用 - 它们不能被合约内的其他函数调用。
    function pay() external payable {}

    //1. 匿名函数：没有函数名，没有参数，没有返回值的函数，就是匿名函数
    //2. 当调用一个不存在的方法时，合约会默认的去调用匿名函数
    //3. 匿名函数一般用来给合约转账，因为费用低
    // receive或fallback用于缺省充值调用函数
    receive() external payable {}

    function withdraw(uint256 amount) public {
        // Uncomment this line to print a log in your terminal
        console.log(
            "Unlock time is %o and block timestamp is %o",
            unlockTime,
            block.timestamp
        );

        require(block.timestamp >= unlockTime, "You can't withdraw yet");
        require(msg.sender == owner, "You aren't the owner");
        require(amount <= address(this).balance, "insufficent funds.");

        if (amount == 0) {
            amount = address(this).balance;
        }

        emit Withdrawal(amount, block.timestamp);

        //由合约向owner 转账
        //1. 转账的时候单位是wei
        //2. 1 ether = 10 ^18 wei （10的18次方）
        //3. 向谁转钱，就用谁调用tranfer函数
        //4. 花费的是合约的钱
        //5. 如果金额不足，transfer函数会抛出异常
        owner.transfer(amount);
    }
}
