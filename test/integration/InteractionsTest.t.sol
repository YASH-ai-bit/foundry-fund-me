//SPDX-license-Identifier: MIT
pragma solidity ^0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe , WithdrawFundMe} from "../../script/interactions.s.sol";

contract FundMeTestIntegration is Test {
    FundMe fundMe;
    DeployFundMe deployFundMe;
    address USER = makeAddr("USER");
    uint256 STARTING_BALANCE = 10 ether ;
    uint256 GAS_PRICE = 1; 
    uint256 SEND_VALUE = 0.01 ether;

    function setUp() public {
        deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER , STARTING_BALANCE);
    }

    function testUserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        // vm.prank(USER);
        // vm.deal(USER, STARTING_BALANCE);
        fundFundMe.fundFundMe(address(fundMe));
        // uint256 balance = address(fundMe).balance;
        // assert(balance == SEND_VALUE) ;

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        // vm.prank(address(this));
        withdrawFundMe.withdrawFundMe(address(fundMe));
        assert(address(fundMe).balance == 0);
    }
}