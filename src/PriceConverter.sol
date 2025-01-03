//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice(
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        return uint256(answer * 1e10); // as msg.value is uint256 typ , in order to compare between msg.value and USD i.e. answer here we need to typecast int into uint
        // Also answer is in USD , it has got 8 zeros after the decimal and in msg.value we have 18 zero as that is in ETH , so in order to have comparison we multiply USD by 1e10
    }

    function getversion() internal view returns (uint256) {
        AggregatorV3Interface price_feed = AggregatorV3Interface(
            0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        );
        return price_feed.version();
    }

    function getConversionRate(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed); //--> basically means to call the whole function wrtitten downside
        // AggregatorV3Interface price_feed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        // (,int256 answer,,,) = price_feed.latestRoundData();
        uint256 ethAmountinUSD = (ethAmount * ethPrice) / 1e18;
        // This is how math works :
        //-->we got 18 zeroes in both ethAmount and ethPrice for eg : ethAmount = 1_000000000000000000 ETH and ethPrice = 3000_000000000000000000
        //if we multiply both of them we get 36 zeroes , so in order to maintain 18 zeores we need to divide by 1e18
        return ethAmountinUSD;
    }
}
