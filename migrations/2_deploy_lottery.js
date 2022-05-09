require("dotenv").config({ path: "../" });

const Lottery = artifacts.require("./Lottery.sol");

module.exports = function (deployer) {
    deployer.deploy(
        Lottery, 
        process.env.PARTICIPATION_THRESHOLD, 
        process.env.PARTICIPATION_TIME, 
        process.env.VRF_SUBSCRIPTION_ID,
        {
            value: process.env.LOTTERY_REWARD
        }
    );
};