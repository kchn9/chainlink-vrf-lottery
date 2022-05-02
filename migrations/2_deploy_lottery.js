require("dotenv").config({ path: "../" });

const Lottery = artifacts.require("./Lottery.sol");

const deploymentSettings = {
    participationMinimumValue: 100,
    lotteryParticipationTime: 300,
    lotteryReward: 10000,
}

module.exports = function (deployer) {
    deployer.deploy(
        Lottery, 
        deploymentSettings.participationMinimumValue, 
        deploymentSettings.lotteryParticipationTime, 
        process.env.VRF_SUBSCRIPTION_ID,
        {
            value: deploymentSettings.lotteryReward
        }
    );
};