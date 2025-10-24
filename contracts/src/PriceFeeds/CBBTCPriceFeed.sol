// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import "./MainnetPriceFeedBase.sol";

/// @notice Price feed for the cbBTC collateral branch. Uses the Chainlink cbBTC/USD oracle directly.
contract CBBTCPriceFeed is MainnetPriceFeedBase {
    constructor(address _cbBtcUsdOracle, uint256 _stalenessThreshold, address _borrowerOperations)
        MainnetPriceFeedBase(_cbBtcUsdOracle, _stalenessThreshold, _borrowerOperations)
    {
        _fetchPricePrimary();

        // Ensure oracle was live at deployment
        assert(priceSource == PriceSource.primary);
    }

    function fetchPrice() public returns (uint256, bool) {
        if (priceSource == PriceSource.primary) return _fetchPricePrimary();
        // During shutdown continue returning the last good price
        assert(priceSource == PriceSource.lastGoodPrice);
        return (lastGoodPrice, false);
    }

    function fetchRedemptionPrice() external returns (uint256, bool) {
        return fetchPrice();
    }

    function _fetchPricePrimary() internal returns (uint256, bool) {
        assert(priceSource == PriceSource.primary);
        (uint256 price, bool oracleDown) = _getOracleAnswer(ethUsdOracle);
        if (oracleDown) return (_shutDownAndSwitchToLastGoodPrice(address(ethUsdOracle.aggregator)), true);

        lastGoodPrice = price;
        return (price, false);
    }
}
