## Chainlink Time-based ERC20 Payment Automation

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

This project:

- Has an ERC20 token called PayToken
- Pays the token to users in a payment list using Chainlink's time-based upkeep

Improvements:
- Currently, all users are paid in intervals, regardless of when they were last paid
- An improvement would be to have personalised payment times
- This project was aimed to simply provide experience using Chainlink upkeep, so I wanted to make as simple as possible