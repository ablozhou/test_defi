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

