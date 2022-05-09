// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

/**
 * @title Chainlink VRF Lottery
 * @notice Implementation of simple lottery game. Creator deploys lottery contract with msg.value that is lottery reward. 
 * @notice After lottery starts - participation phase begins - deployer decides how long should it be.
 * @notice Anyone who satisfies minimum participation cost - deployer also sets it - can join the lottery.
 * @notice Then after participation phase ends anyone can call drawWinner() to find the winner and send him money.
 * @notice Reward is locked until someone wins it. Deployer may only withdraw lottery ticket earnings.
 * @author @kchn9
 */
contract Lottery is Ownable, VRFConsumerBaseV2 {
    /// @dev Using @openzeppelin counters for safe lottery participants counting
    using Counters for Counters.Counter;

    /// @notice Emitted whenever lottery founds the winner
    event WinnerFound(address winner, uint256 rewardSent);

    /// @notice Keep track of users id
    Counters.Counter participantCounter;
    /// @dev Mapping user id -> address
    mapping ( uint => address ) participants;

    /// @notice Keep track of contract balance
    uint256 private _balance;

    VRFCoordinatorV2Interface immutable private _coordinator;
    uint64 immutable private _VRFSubId;

    /// @custom:disclaimer - IT'S VALID ONLY FOR RINKEBY - PLEASE CHANGE THAT IF PLANNING MAINNET DEPLOYMENT
    address private _coordinatorAddress = 0x6168499c0cFfCaCD319c818142124B7A15E857ab;
    bytes32 private _keyHash = 0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc;

    /// @notice Lottery configuration
    uint256 immutable public reward;
    /// @notice Minimum cost to join lottery
    uint256 immutable public minParticipate;
    /// @notice UNIX timestamp when the participation phase ends and drawWinner() is not locked
    uint256 immutable private _endsAt;

    /// @dev Prevents re-entrancy
    bool isExectued;

    /**
     * @dev Creates new Lottery, and sets VRFCoordinator contract
     * @param _minParticipate minimum cost for user to join the lottery
     * @param _endsIn time in seconds to end the participation phase from now
     * @param _VRFSubscriptionId id of VRF subscription -> go https://vrf.chain.link/ for more
     */
    constructor(uint256 _minParticipate, uint64 _endsIn, uint64 _VRFSubscriptionId) VRFConsumerBaseV2(_coordinatorAddress) payable {
        require(msg.value > 0, "Lottery: Reward cannot be 0.");
        reward = msg.value;
        minParticipate = _minParticipate;
        _coordinator = VRFCoordinatorV2Interface(_coordinatorAddress);
        _VRFSubId = _VRFSubscriptionId;
        _endsAt = block.timestamp + _endsIn;
    }

    /// @notice Allow user to participate if all requirements are satisfied
    function participate() public payable {
        require(msg.value >= minParticipate, "Lottery: Lottery participation threshold not reached.");
        require(getTimeLeft() != 0, "Lottery: Lottery is closed.");
        _balance += msg.value;
        participants[participantCounter.current()] = msg.sender;
        participantCounter.increment();
    }

    /// @notice Finds the lottery winner using Chainlink VRF and then sends ETH to winner
    function drawWinner() public {
        require(getTimeLeft() == 0, "Lottery: Lottery is not closed yet.");
        require(!isExectued, "Lottery: Lottery has found winner already.");
        isExectued = true; // prevent re-entrancy
        _requestRandomWords();
    }

    /// @notice VRF requirement - coordinator finds the random word
    function _requestRandomWords() internal {
        _coordinator.requestRandomWords(_keyHash, _VRFSubId, 3, 100000, 1); // reqConfs = 3, gasCallLimit = 100 000, reqWords = 1
    }

    /// @notice VRF requirement - what happends after we got random word
    function fulfillRandomWords(uint256 /* requestId */, uint256[] memory _randWords) internal override {
        uint256 winnerIdx = _randWords[0] % (participantCounter.current() + 1);
        _sendRewardToWinner(winnerIdx);
    }

    /**
     * @notice Sends reward to lottery winner
     * @param _winnerIdx lottery winner id
     */ 
    function _sendRewardToWinner(uint256 _winnerIdx) internal {
        address winner = participants[_winnerIdx];
        emit WinnerFound(winner, reward);        
        (bool sent, /* data */) = winner.call{ value: reward }("");
        require(sent, "Lottery: ETH transfer failed.");

    } 

    /// @notice Allows lottery deployer to withdraw ONLY ticket earning - reward stays safe
    function withdraw() public onlyOwner {
        (bool sent, /* data */) = owner().call{ value: _balance }(""); // unable to withdraw lottery reward
        _balance = 0;
        require(sent, "Lottery: ETH transfer failed.");
    }

    /// @notice Getter for time left before participation part ends
    function getTimeLeft() public view returns(uint) {
        if (block.timestamp >= _endsAt) return 0;
        return _endsAt - block.timestamp;
    }

    /// @notice Getter for current contract balance
    function getBalance() public view returns(uint) {
        return address(this).balance;
    }

}