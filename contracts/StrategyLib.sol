// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import {SafeMath} from "@openzeppelin/contracts/math/SafeMath.sol";
import {IStrategySettings} from "./settings/IStrategySettings.sol";
import {StrategySettingsConsts} from "./settings/StrategySettingsConsts.sol";
import {StrategyParams, VaultAPI, StrategyAPI} from "./BaseStrategy.sol";

library StrategyLib {
    using SafeMath for uint256;

    function internalHarvestTrigger(
        address vault,
        address strategy,
        uint256 callCost,
        IStrategySettings settings
    ) public view returns (bool) {
        StrategyParams memory params = VaultAPI(vault).strategies(strategy);
        // Should not trigger if Strategy is not activated
        if (params.activation == 0) {
            return false;
        }
        uint256 minReportDelay = settings.getUint256SettingsValue(StrategySettingsConsts(strategy).MIN_REPORT_DELAY_UINT256());
        uint256 maxReportDelay = settings.getUint256SettingsValue(StrategySettingsConsts(strategy).MAX_REPORT_DELAY_UINT256());
        uint256 debtThreshold = settings.getUint256SettingsValue(StrategySettingsConsts(strategy).DEBT_THRESHOLD_UINT256());
        uint256 profitFactor = settings.getUint256SettingsValue(StrategySettingsConsts(strategy).PROFIT_FACTOR_UINT256());

        // Should not trigger if we haven't waited long enough since previous harvest
        if (block.timestamp.sub(params.lastReport) < minReportDelay) return false;

        // Should trigger if hasn't been called in a while
        if (block.timestamp.sub(params.lastReport) >= maxReportDelay) return true;

        // If some amount is owed, pay it back
        // NOTE: Since debt is based on deposits, it makes sense to guard against large
        //       changes to the value from triggering a harvest directly through user
        //       behavior. This should ensure reasonable resistance to manipulation
        //       from user-initiated withdrawals as the outstanding debt fluctuates.
        uint256 outstanding = VaultAPI(vault).debtOutstanding();
        if (outstanding > debtThreshold) return true;

        // Check for profits and losses
        uint256 total = StrategyAPI(strategy).estimatedTotalAssets();
        // Trigger if we have a loss to report
        if (total.add(debtThreshold) < params.totalDebt) return true;

        uint256 profit = 0;
        if (total > params.totalDebt) profit = total.sub(params.totalDebt); // We've earned a profit!

        // Otherwise, only trigger if it "makes sense" economically (gas cost
        // is <N% of value moved)
        uint256 credit = VaultAPI(vault).creditAvailable();
        return (profitFactor.mul(callCost) < credit.add(profit));
    }

    function internalSetRewards(address newRewards, address strategy, address vault, IStrategySettings settings) public {
        require(newRewards != address(0));
        address oldRewards = settings.getAddressSettingsValue(StrategySettingsConsts(strategy).REWARDS_ADDRESS());
        VaultAPI(vault).approve(oldRewards, 0);
        
        settings.setSettings(StrategySettingsConsts(strategy).REWARDS_ADDRESS(), newRewards);

        VaultAPI(vault).approve(newRewards, type(uint256).max);
    }
}
