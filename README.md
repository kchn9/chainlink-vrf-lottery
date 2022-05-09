# Chainlink VRF Lottery Game

This project is my implementation of lottery game what relies on
random numbers generated and provided by chainlink VRF.

Lottery reward is fully secured - even lottery deployer cannot withdraw it.
Also, the lottery is fully customizable, the reward, minimum participation cost and time of participation phase are being set by deployer. 
## Disclaimer

Keep in mind, to use Chainlink VRF first you need to create subscription (then pass it in .env) and after deployment you should add consumer to subscription.

For more details, go here: [Chainlink VRF docs](https://docs.chain.link/docs/chainlink-vrf/)


## Features  

- Safe random number generation (not so obvious on blockchain)

- Fully customizable (reward, minimum ticket cost, time of participation time)

- Safe for participants - reward stays out of reach of deployer

- Using @openzeppelin [counters](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Counters.sol) for safe counting participants

## Created with (dependencies)

- Truffle v5.5.11 (core: 5.5.11)
- Ganache v^7.0.4
- Solidity - ^0.8.0 (solc-js)
- Node v16.14.2
- Web3.js v1.5.3
- dotenv ^16.0.0
- @openzeppelin/contracts ^4.5.0


## Installation

Clone the chainlink-vrf-lottery

```bash
  git clone https://github.com/kchn9/chainlink-vrf-lottery.git
```

Go to the project directory

```bash
  cd chainlink-vrf-lottery
```

Install dependencies

```bash
  npm install
```

Get ready to deploy - check [.env.example](.env.example) then run

```bash
  truffle migrate --network rinkeby
```

## Authors

- [@kchn9](https://www.github.com/kchn9)


## License

[MIT](https://choosealicense.com/licenses/mit/)

