pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
  uint256 public constant tokensPerEth = 100;

  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
  event SellTokens(address seller, uint256 amountOfTokens, uint256 amountOfETH);

  YourToken public yourToken;

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

  function buyTokens() public payable {
    uint256 amount = msg.value*tokensPerEth;
    yourToken.transfer(msg.sender,amount);
    emit BuyTokens(msg.sender, msg.value, amount);
  }

  function sellTokens(uint256 amount) public {
    uint256 amountEth = amount/tokensPerEth;
    yourToken.transferFrom(msg.sender,address(this),amount);
    (bool sent, ) = msg.sender.call{value: amountEth}("");
    require (sent,"Failed to send Ether");
    emit SellTokens(msg.sender, amount, amountEth);
  }

  function withdraw() public onlyOwner {
    require (address(this).balance>0, "balance is 0");
    (bool sent, ) = owner().call{value: address(this).balance}("");
    require (sent,"Failed to send Ether");
  }
}
