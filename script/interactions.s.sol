//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script , console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 SEND_VALUE = 0.01 ether;
    address USER = makeAddr("USER");

    function fundFundMe (address most_recent_deployment) public {

        FundMe fundMe = FundMe(payable(most_recent_deployment));
        // vm.prank(USER);
        // vm.deal(USER , 10 ether);                  //becuase inside of a vm.broadcast() we can't use prank .
        fundMe.fund{value : SEND_VALUE}();
        
        console.log("Funded FundMe contract with ", SEND_VALUE);
    }

    function run() external {
        address most_recent_deployment = DevOpsTools.get_most_recent_deployment("FundMe" , block.chainid) ;
        vm.startBroadcast();
        fundFundMe(most_recent_deployment);
        vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script {

    function withdrawFundMe (address most_recent_deployment) public {
        FundMe fundMe = FundMe(payable(most_recent_deployment));
        // vm.startBroadcast();
        fundMe.withdraw();
        // vm.stopBroadcast();
    }

    function run() external {
        address most_recent_deployment = DevOpsTools.get_most_recent_deployment("FundMe" , block.chainid) ;
        vm.startBroadcast();
        withdrawFundMe(most_recent_deployment);
        vm.stopBroadcast();
    }
}