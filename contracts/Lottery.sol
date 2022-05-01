// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

contract Lottery is Ownable, VRFConsumerBaseV2 {
    using Counters for Counters.Counter;

    Counters.Counter participantCounter;
    mapping ( uint => address ) participants;

    uint256 private _balance;

    VRFCoordinatorV2Interface immutable private _coordinator;
    uint64 immutable private _VRFSubId;

    // valid for Rinkeby
    address private _coordinatorAddress = 0x6168499c0cFfCaCD319c818142124B7A15E857ab;
    bytes32 private _keyHash = 0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc;

    uint256 immutable public reward;
    uint256 immutable public minParticipate;
    uint256 immutable private _endsAt;

    constructor(uint256 _minParticipate, uint64 _endsIn, uint64 _VRFSubscriptionId) VRFConsumerBaseV2(_coordinatorAddress) payable {
        require(msg.value > 0, "Lottery: Reward cannot be 0.");
        reward = msg.value;
        minParticipate = _minParticipate;
        _coordinator = VRFCoordinatorV2Interface(_coordinatorAddress);
        _VRFSubId = _VRFSubscriptionId;
        _endsAt = block.timestamp + _endsIn;
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
        _requestRandomWords();
    }

    function _requestRandomWords() internal {
        _coordinator.requestRandomWords(_keyHash, _VRFSubId, 3, 100000, 1); // reqConfs, gasCallLimit, reqWords
    }

    function fulfillRandomWords(uint256 /* requestId */, uint256[] memory _randWords) internal override {
    }

    function withdraw() public onlyOwner {
        (bool sent, /* data */) = owner().call{ value: _balance }(""); // unable to withdraw lottery reward
        _balance = 0;
        require(sent, "Lottery: ETH transfer failed.");
    }

    function getTimeLeft() public view returns(uint) {
        if (block.timestamp >= _endsAt) return 0;
        return _endsAt - block.timestamp;
    }

    function getBalance() public view returns(uint) {
        return address(this).balance;
    }

}