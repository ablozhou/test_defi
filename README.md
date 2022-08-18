# Lock defi

This project demonstrates a Defi use case. It comes with a Lock and a Token contract,  and a script that deploys them. 
The front end of this project was bootstrapped with [Create React App](https://github.com/facebook/create-react-app).

# hardhat
Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
GAS_REPORT=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.ts
```

# front end
In the project directory, you can run:

### `npm start`

Runs the app in the development mode.\
Open [http://localhost:3000](http://localhost:3000) to view it in the browser.

The page will reload if you make edits.

# abstract
This is a demo project to show how to develop a simple defi project with smart contract and react front interactiving with wallet and user.

# env
- Solidity for writing smart contracts.
- Hardhat for running local networks, deploying and testing smart contracts.
- React for building a frontend, using many useful pre-made components and hooks.
- Ethers.js for interacting with deployed smart contracts and the frontend
- Ant for your UI. But can be easily changed to Bootstrap or some other library you prefer.
- Scaffold-eth Scaffold-eth is not a product itself but more of a combination or stack of other great products. It allows you to quickly build and iterate over your smart contracts and frontends. this demo dose not using scaffold-eth for start from scratch.
- openzeppelin A library for secure smart contract development. Build on a solid foundation of community-vetted code. this demo does not using openzeppelin for understanding. Some solidity code is references to openzeppelin lib.

## setting npm mirror in China
```
zhh@svr:~$ npm config set registry https://registry.npm.taobao.org --global
zhh@svr:~$ npm config set disturl https://npm.taobao.org/dist --global
zhh@svr:~$ npm config get registry
https://registry.npm.taobao.org/
zhh@svr:~$ npm config get disturl  
https://npm.taobao.org/dist
```

```
zhh@svr:~/git/test_defi$ npx create-react-app dapp --template typescript
zhh@svr:~/git/test_defi/dapp$ yarn start
```
或者用npm或yarn 创建react项目
```
npm init react-app dapp
yarn create react-app dapp
```

使用npm或者yarn安装ethers.js和hardhat。
```
zhh@svr:~/git/test_defi/react-dapp$ npm install ethers hardhat   chai @nomiclabs/hardhat-ethers ts-node @nomicfoundation/hardhat-toolbox @nomicfoundation/hardhat-chai-matchers
@nomicfoundation/hardhat-network-helpers @nomiclabs/hardhat-etherscan @typechain/hardhat typechain hardhat-gas-reporter solidity-coverage @typechain/ethers-v5
```
or
```
zhh@svr:~/git/test_defi/dapp$ yarn add ethers hardhat   chai @nomiclabs/hardhat-ethers
```
## Init hardhat
先将readme.md 和tsconfig.json改名，否则会报错
```
npx hardhat 
```
语言也选择typescript.

会生成 contracts/Lock.sol

```sol
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


```
新加入token.sol
产品一般使用openzipplin 安全库，这里为了方便理解，采用硬写。
```
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

```

### 修改hardhat.config.ts
```
const config: HardhatUserConfig = {
  solidity: "0.8.9",
  paths: {
    artifacts: './src/artifacts',
  },
  networks: {
    hardhat: {
      chainId: 1337
    }
  }
};
```
### 编译
```
zhh@svr:~/git/test_defi/dapp$ npx hardhat compile

```
会生成src/artifacts/contracts/Lock.sol/Lock.json
src/artifacts/contracts/Token.sol/Token.json

里面包含ABI信息。可以在js中引入和使用
```
import Lock from './artifacts/contracts/Lock.sol/Lock.json'
console.log("Lock ABI: ", Lock.abi)
```

## 部署智能合约

### deploy.ts
```
import { ethers, artifacts } from "hardhat";
//我们智能合约中的代码被编译为称为字节码和ABI的“工件”(artifacts)。
import { BigNumber } from "@ethersproject/bignumber"
import * as path from "path"
async function main() {
  const currentTimestampInSeconds = Math.round(Date.now() / 1000);
  const ONE_YEAR_IN_SECS = 365 * 24 * 60 * 60;
  const TWO_MIN = 2 * 60;
  const unlockTimeYear = currentTimestampInSeconds + ONE_YEAR_IN_SECS;
  const unlockTime = currentTimestampInSeconds + TWO_MIN;
  const etherAmount = "100"
  const lockedAmount: BigNumber = ethers.utils.parseEther(etherAmount);

  const Lock = await ethers.getContractFactory("Lock");
  const lock = await Lock.deploy(unlockTime, { value: lockedAmount });

  await lock.deployed();

  console.log("Lock with %d ETH deployed to: %s", lockedAmount, lock.address);

  const [deployer] = await ethers.getSigners();

  console.log(
    "Deploying contracts with the account:",
    deployer.address
  );

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const Token = await ethers.getContractFactory("Token");
  const token = await Token.deploy();
  await token.deployed();
  console.log("Token was deployed to address: %s", token.address);

  //saveFrontendFiles(token);
}

function saveFrontendFiles(token: any) {
  const fs = require("fs");
  const contractsDir = path.join(__dirname, "..", "src", "artifacts", "contracts");

  if (!fs.existsSync(contractsDir)) {
    fs.mkdirSync(contractsDir);
  }

  fs.writeFileSync(
    path.join(contractsDir, "contract-address.json"),
    JSON.stringify({ Token: token.address }, undefined, 2)
  );

  const TokenArtifact = artifacts.readArtifactSync("Token");

  fs.writeFileSync(
    path.join(contractsDir, "Token.json"),
    JSON.stringify(TokenArtifact, null, 2)
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

```
## 启动本地hardhat节点
```
zhh@svr:~/git/test_defi/react-dapp$ npx hardhat node
Started HTTP and WebSocket JSON-RPC server at http://127.0.0.1:8545/

Accounts
========

WARNING: These accounts, and their private keys, are publicly known.
Any funds sent to them on Mainnet or any other live network WILL BE LOST.

Account #0: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 (10000 ETH)
Private Key: 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

Account #1: 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 (10000 ETH)
Private Key: 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
```

## 用metamask连接
在设置的高级里打开显示测试网络。切换到localhost:8545
添加上述账号，可以看到有10000个ETH。

## 部署测试网
```
zhh@svr:~/git/test_defi/dapp$ npx hardhat compile
Generating typings for: 1 artifacts in dir: typechain-types for target: ethers-v5
Successfully generated 6 typings!
Compiled 1 Solidity file successfully
zhh@svr:~/git/test_defi/dapp$ npx hardhat run scripts/deploy.ts --network localhost
Lock with 100000000000000000000 ETH deployed to: 0x5FbDB2315678afecb367f032d93F642f64180aa3
Deploying contracts with the account: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
Account balance: 9899999412368375000000
Token was deployed to address: 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
```
保存好该地址，我们的前端程序将要使用该地址与智能合约进行交互。
--network 指定用什么网络。缺省是主网。

# 与前端一起工作

```
import React from 'react';

//import logo from './logo.svg';
import './App.css';
import { useState } from 'react';
import { ethers } from 'ethers'
//import { BigNumber } from "@ethersproject/bignumber"
import Lock from './artifacts/contracts/Lock.sol/Lock.json'
import Token from './artifacts/contracts/Token.sol/Token.json'

function App() {
  //Account #0: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 (10000 ETH)
  //Private Key: 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

  //Account #1: 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 (10000 ETH)
  //Private Key: 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
  let lockAddr = '0x5FbDB2315678afecb367f032d93F642f64180aa3'
  const tokenAddress = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512"
  const [supplyValue, setSupply] = useState<string>('1000')
  const [userAccount, setUserAccount] = useState<string>()
  const [amount, setAmount] = useState<string>('1000')
  const [withdrawAmount, setWithdrawAmount] = useState<string>((100 * 10 ** 18).toString())
  // request account from metamask
  async function requestAccount() {
    await window.ethereum.request({ method: 'eth_requestAccounts' });
  }

  async function getLockBalance() {
    if (typeof window.ethereum !== 'undefined') {
      const provider = new ethers.providers.Web3Provider(window.ethereum)
      const contract = new ethers.Contract(lockAddr, Lock.abi, provider)

      try {
        const data = await contract.getContractBalance();
        console.log('data: %s', data.div((10 ** 18).toString()).toString())
      } catch (err) {
        console.log("Error: ", err)
      }
    } else {
      console.error("Link the wallet at first.")
    }
  }
  async function withdraw() {
    if (typeof window.ethereum !== 'undefined') {
      await requestAccount()
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner()
      const contract = new ethers.Contract(lockAddr, Lock.abi, signer)

      try {
        await contract.withdraw(withdrawAmount);
        console.log('withdraw: %s', withdrawAmount)
      } catch (err) {
        console.log("Error: ", err)
      }
    } else {
      console.error("Link the wallet at first.")
    }
  }
  
  async function supply() {
    if (!supplyValue) return
    if (typeof window.ethereum !== 'undefined') {
      await requestAccount()
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner()
      const contract = new ethers.Contract(lockAddr, Lock.abi, signer)
      const transaction = await contract.pay(supplyValue)
      await transaction.wait()
      getLockBalance()
    }
  }
  async function sendCoins() {
    if (typeof window.ethereum !== 'undefined') {
      await requestAccount()
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner();
      const contract = new ethers.Contract(tokenAddress, Token.abi, signer);
      const transation = await contract.transfer(userAccount, amount);
      await transation.wait();
      console.log(`${amount} Coins successfully sent to ${userAccount}`);
    }
  }
  async function getBalance() {
    if (typeof window.ethereum !== 'undefined') {
      const [account] = await window.ethereum.request({ method: 'eth_requestAccounts' })
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const contract = new ethers.Contract(tokenAddress, Token.abi, provider)
      const balance = await contract.balanceOf(account);
      console.log("Balance: ", balance.toString());
    }
  }
  return (
    <div className="App">
      <header className="App-header">

        <button onClick={getLockBalance}>获取锁仓余额</button>
        <button onClick={withdraw}>取回</button>
        <input onChange={e => setWithdrawAmount(e.target.value)} placeholder="withdraw" />
        <br />
        <button onClick={supply}>锁仓</button>
        <input onChange={e => setSupply(e.target.value)} placeholder="supply" />
        <br />
        <button onClick={getBalance}>获取Token余额</button>
        <button onClick={sendCoins}>转让币 </button>
        <div>0x70997970C51812dc3A010C7d01b50e0d17dc79C8</div>
        <input onChange={e => setUserAccount(e.target.value)} placeholder="Account ID" />
        <input onChange={e => setAmount(e.target.value)} placeholder="amount" />

        
      </header>
    </div>
  );
}

export default App;
```
如果要动币，就会启动metamask签名。
只是查询的话，可以在浏览器的console看到相关结果。

# 参考
https://create-react-app.dev/docs/getting-started/

https://docs.openzeppelin.com/contracts/3.x/erc20

https://github.com/OpenZeppelin/openzeppelin-contracts

https://docs.chain.link/docs/any-api/get-request/examples/large-responses/

https://github.com/scaffold-eth/scaffold-eth.git

https://github.com/scaffold-eth/scaffold-eth/tree/challenge-1-decentralized-staking

[Create React App documentation](https://facebook.github.io/create-react-app/docs/getting-started)

[React documentation](https://reactjs.org/)