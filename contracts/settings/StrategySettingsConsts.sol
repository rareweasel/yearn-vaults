// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.7.0;

contract StrategySettingsConsts {
    /**
     *  The `keeper` is the only address that may call `tend()` or `harvest()`,
     *  other than `governance()` or `strategist`. However, unlike
     *  `governance()` or `strategist`, `keeper` may *only* call `tend()`
     *  and `harvest()`, and no other authorized functions, following the
     *  principle of least privilege.
     */
    bytes32 public constant KEEPER_ADDRESS = "KEEPER_ADDRESS";

    bytes32 public constant STRATEGIST_ADDRESS = "STRATEGIST_ADDRESS";

    bytes32 public constant REWARDS_ADDRESS = "REWARDS_ADDRESS";

    /**
     *  The `metadataURI` is used to store the URI
     *  of the file describing the strategy.
     */
    bytes32 public constant METADATA_URI_STRING = "METADATA_URI_STRING";

    /**
     *  The `minReportDelay` is the minimum number
     *  of blocks that should pass for `harvest()` to be called.
     *
     *  For external keepers (such as the Keep3r network), this is the minimum
     *  time between jobs to wait. (see `harvestTrigger()`
     *  for more details.)
     */
    bytes32 public constant MIN_REPORT_DELAY_UINT256 = "MIN_REPORT_DELAY_UINT256";

    /**
     *  The `maxReportDelay` is the maximum number
     *  of blocks that should pass for `harvest()` to be called.
     *
     *  For external keepers (such as the Keep3r network), this is the maximum
     *  time between jobs to wait. (see `harvestTrigger()`
     *  for more details.)
     */
    bytes32 public constant MAX_REPORT_DELAY_UINT256 = "MAX_REPORT_DELAY_UINT256";

    /**
     *  The `profitFactor` is used to determine
     *  if it's worthwhile to harvest, given gas costs. (See `harvestTrigger()`
     *  for more details.)
     */
    bytes32 public constant PROFIT_FACTOR_UINT256 = "PROFIT_FACTOR_UINT256";

    /**
     *  It defines how far the Strategy can go into loss without a harvest and report
     *  being required.
     *
     *  By default this is 0, meaning any losses would cause a harvest which
     *  will subsequently report the loss to the Vault for tracking. (See
     *  `harvestTrigger()` for more details.)
     */
    bytes32 public constant DEBT_THRESHOLD_UINT256 = "DEBT_THRESHOLD_UINT256";

    // See note on `BaseStrategy#setEmergencyExit()`.
    bytes32 public constant EMERGENCY_EXIT_BOOL = "EMERGENCY_EXIT_BOOL";

}
