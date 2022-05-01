// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Lottery is Ownable {
    using Counters for Counters.Counter;

    Counters.Counter participantCounter;
    mapping ( uint => address ) participants;
    uint256 private _balance;

    uint256 immutable public reward;
    uint256 immutable minParticipate;
    uint256 immutable endsAt;

    constructor(uint256 _minParticipate, uint64 endsIn) payable {
        reward = msg.value;
        minParticipate = _minParticipate;
        endsAt = block.timestamp + endsIn;
    }

    function participate() public payable {
        require(msg.value >= minParticipate, "Lottery: Lottery participation threshold not reached.");
        require(getTimeLeft() != 0, "Lottery: Lottery is closed.");
        _balance += msg.value;
        participants[participantCounter.current()] = msg.sender;
        participantCounter.increment();
    }

    function drawWinner() public {
        require(getTimeLeft() == 0, "Lottery: Lottery is not closed yet.");
        // todo
    }

    function withdraw() public onlyOwner {
        (bool sent, /* data */) = owner().call{ value: _balance }(""); // unable to withdraw lottery reward
        _balance = 0;
        require(sent, "Lottery: ETH transfer failed.");
    }

    function getTimeLeft() public view returns(uint) {
        if (block.timestamp >= endsAt) return 0;
        return endsAt - block.timestamp;
    }

    function getBalance() public view returns(uint) {
        return address(this).balance;
    }

}