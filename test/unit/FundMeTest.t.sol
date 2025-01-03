//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    DeployFundMe deployFundMe;
    address USER = makeAddr("USER");
    uint256 SEND_VALUE = 0.1 ether ;
    uint256 STARTING_BALANCE = 10 ether ;
    uint256 GAS_PRICE = 1; 

    function setUp() public {
        deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER , STARTING_BALANCE);
    }

    function testMINIMUMDollarisFive() public view{
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerismsgSender() public view{
        assertEq(fundMe.i_owner(), /*msg.sender*/ msg.sender); //here us -> FundMeTest ->FundMe
        //actually FundMeTest is calling FundMe , so owner is FundMeTest not msg.sender instead use address(this)
    }

    function testVersionisAccurate() public view {
        uint256 Version = fundMe.getVersion();
        assertEq(Version, 4);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value : SEND_VALUE}() ;
        _;
    }

    function testFundUpdates() public funded {
        uint256 amountFunded;
        amountFunded = fundMe.getAddresstoAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testFunderAddedOrNot() public funded {
        address funder = fundMe.getFunders(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw()public {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdrawBySingleFunder() public funded{

        //Arrange
        uint256 startingBalnceOfOwner = fundMe.getOwner().balance ;
        uint256 startingBalanceOfFundMe = address(fundMe).balance ;

        //Act
        // uint256 gasStart = gasleft();
        vm.prank(fundMe.getOwner()); //withdraw can be done by owner only
        fundMe.withdraw();
        // vm.txGasPrice(GAS_PRICE);
        // uint256 gasEnd = gasleft();
        // uint256 gasUsed = (gasStart - gasEnd)*tx.gasprice;          //tx.gasprice != txGasPrice (tx.gasprice is gas price at that moment in chain , whereas txGasPrice sets that fake gas price)


        //Assert
        uint256 endingBalanceOfOwner = fundMe.getOwner().balance ;
        uint256 endingBalanceOfFundMe = address(fundMe).balance ;
        assertEq(endingBalanceOfOwner, startingBalnceOfOwner + startingBalanceOfFundMe);
        assertEq(endingBalanceOfFundMe, 0);
    }

    function testWithdrawByMultipleFunders() public funded{

        //Arrange
        uint160 numberOfFunders = 10 ;
        uint160 startingFunderIndex = 1;    
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            //vm.prank new address
            //vm.deal new address
            //address()
            hoax(address(i) , SEND_VALUE);
            fundMe.fund{value : SEND_VALUE}();
        }
        uint256 startingBalnceOfOwner = fundMe.getOwner().balance ;
        uint256 startingBalanceOfFundMe = address(fundMe).balance ;

        //Act
        vm.startPrank(fundMe.getOwner()); //withdraw can be done by owner only   
        fundMe.withdraw();
        vm.stopPrank();

        //assert
        assertEq(address(fundMe).balance , 0);
        assertEq(fundMe.getOwner().balance, startingBalnceOfOwner + startingBalanceOfFundMe);
    }

        function testWithdrawByMultipleFunderscheaper() public funded{

        //Arrange
        uint160 numberOfFunders = 10 ;
        uint160 startingFunderIndex = 1;    
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            //vm.prank new address
            //vm.deal new address
            //address()
            hoax(address(i) , SEND_VALUE);
            fundMe.fund{value : SEND_VALUE}();
        }
        uint256 startingBalnceOfOwner = fundMe.getOwner().balance ;
        uint256 startingBalanceOfFundMe = address(fundMe).balance ;

        //Act
        vm.startPrank(fundMe.getOwner()); //withdraw can be done by owner only   
        fundMe.CheaperWithdraw();
        vm.stopPrank();

        //assert
        assertEq(address(fundMe).balance , 0);
        assertEq(fundMe.getOwner().balance, startingBalnceOfOwner + startingBalanceOfFundMe);
    }
}
