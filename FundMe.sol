// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "PriceConverter.sol";

contract FundMe {
    // Logic to use library in smart contract
    using PriceConverter for uint256;

    uint256 minimumUSD = 50 * 1e18;
    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;
    address public owner;

    // It execute only one time---
    constructor () {
        owner = msg.sender;
    }

    function Fund() public payable {
        require(msg.value.getPriceConversion() >= minimumUSD, "You didn't send enough money!!");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        for(uint256 fundersIndex = 0; fundersIndex < funders.length; fundersIndex++) {
            address funder = funders[fundersIndex];
            addressToAmountFunded[funder] = 0;

            // Reset funders array
            funders = new address[](0);

            // Transfer ether to the account
            (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
            require(callSuccess, "Transaction failed!!");
        }
    }

    modifier onlyOwner {
        // Only contract owner can withdraw money
        require(msg.sender == owner, "You're not the owner");
        // This means execute the rest code after checking the condition
        _;
    }
}