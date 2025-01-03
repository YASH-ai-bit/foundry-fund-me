// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

error FundMe__notOwner();

contract FundMe {
    using PriceConverter for uint256;
    uint256 public constant MINIMUM_USD = 5e18;
    address public immutable i_owner;

    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    address[] private s_funders; //funders is array that consists of addresses of different finders
    mapping(address => uint256) private s_addresstoAmountFunded;

    function fund() public payable {
        require(
            msg.value.getConversionRate(s_priceFeed) > MINIMUM_USD,
            "not enough currency!"
        ); //1e18 --> means 1*10^18 wei = 1 eth = 1*10^9 gwei
        s_funders.push(msg.sender);
        s_addresstoAmountFunded[msg.sender] += msg.value;
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function CheaperWithdraw() public onlyOwner {
        uint256 fundersLength = s_funders.length;

        for (uint256 i; i < fundersLength; i++) {
            address funder = s_funders[i];
            s_addresstoAmountFunded[funder] = 0;
        }

        s_funders = new address[](0);
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call Failed");
    }

    function withdraw() public onlyOwner {
        for (uint256 i; i < s_funders.length; i++) {
            address funder = s_funders[i];
            s_addresstoAmountFunded[funder] = 0;
        }

        s_funders = new address[](0);
        // //transfer
        // payable(msg.sender).transfer(address(this).balance);
        // //send
        // bool sendSuccess = payable (msg.sender).send(address(this).balance);
        // require (sendSuccess , "Send Failed");
        // //call
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call Failed");
    }

    modifier onlyOwner() {
        // require(owner==msg.sender , "Failed to Withdraw") ;
        if (i_owner != msg.sender) {
            revert FundMe__notOwner();
        } // both ways are same
        _;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    function getAddresstoAmountFunded(address add)
        external
        view
        returns (uint256)
    {
        return s_addresstoAmountFunded[add];
    }

    function getFunders(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }
}
