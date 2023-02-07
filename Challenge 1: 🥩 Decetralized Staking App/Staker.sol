// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
  event Stake(address,uint256);
  ExampleExternalContract public exampleExternalContract;
  mapping ( address => uint256 ) public balances;
  uint256 public constant threshold = 1 ether;
  uint256 public deadline = block.timestamp + 72 hours;
  bool public openForWithdraw;
  bool internal locked;

  constructor(address exampleExternalContractAddress) {
    exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  modifier Guard() {
    require(!locked, "No re-entrancy!");
    locked = true;
    _;
    locked = false;
  }

  modifier isComplited() {
    require (!exampleExternalContract.completed(), "already completed");
    _;
  }

  function stake() public payable isComplited {
    balances[msg.sender] += msg.value;
    /*if (address(this).balance >= threshold){
      exampleExternalContract.complete{value: address(this).balance}();
      deadline = 0;
    }*/
    emit Stake(msg.sender,msg.value);
  }

  function execute() public isComplited {
    if (block.timestamp>=deadline) {
      if (address(this).balance >= threshold) {
        exampleExternalContract.complete{value: address(this).balance}();
      } else openForWithdraw = true;
    }
  }

  function withdraw() public Guard isComplited {
    require(openForWithdraw, "withdrawing is not allowed");
    uint256 amount = balances[msg.sender];
    require(amount>0,"balance is 0");
    (bool sent, ) = msg.sender.call{value: amount}("");
    require(sent, "Failed to send Ether");
    balances[msg.sender] = 0;
  }

  function timeLeft() public view returns (uint256) {
    if (block.timestamp>=deadline) return 0;
    else return deadline - block.timestamp;
  }

  receive() external payable{
    stake();
  }
}
