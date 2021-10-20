// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;

import {SafeMath} from "@openzeppelin/contracts/math/SafeMath.sol";
import {VaultAPI} from "../BaseStrategy.sol";
import {SettingLib} from "./SettingLib.sol";
import {IStrategySettings} from "./IStrategySettings.sol";
import {StrategySettingsConsts} from "./StrategySettingsConsts.sol";

/**
 * @title Yearn Base Strategy
 * @author yearn.finance
 * @notice
 *  StrategySettings implements all of the required functionality to allow strategies
 *  set/get/require settings. 
 *  These settings are per strategy exclusively (1-to-1 relationship). However,
 *  it can be shared between multiply strategies if they need to have the same settings.
 *
 *  The settings can be updated by the strategist or the governance. See `_onlyAuthorized()`
 *  internal function. The initial strategist is the deployer account.
 */
contract StrategySettings is IStrategySettings, StrategySettingsConsts {
    using SafeMath for uint256;
    using SettingLib for SettingLib.Setting;

    VaultAPI public vault;

    mapping(bytes32 => SettingLib.Setting) internal settings;

    constructor(address _vault) public {
        _initialize(_vault, msg.sender, msg.sender, msg.sender);
    }

    /**
     * @notice
     *  Initializes the contract, this is called only once, when the
     *  contract is deployed.
     * @dev `_vault` should implement `VaultAPI`.
     * @param _vault The address of the Vault responsible for this Strategy.
     * @param _strategist The address to assign as `strategist`.
     * The strategist is able to change the reward address
     * @param _rewards  The address to use for pulling rewards.
     * @param _keeper The adddress of the _keeper. _keeper
     * can harvest and tend a strategy.
     */
    function _initialize(
        address _vault,
        address _strategist,
        address _rewards,
        address _keeper
    ) internal {
        require(address(vault) == address(0), "already_initialized");

        vault = VaultAPI(_vault);
        
        _setSettings(STRATEGIST_ADDRESS, _strategist);
        _setSettings(REWARDS_ADDRESS, _rewards);
        _setSettings(KEEPER_ADDRESS, _keeper);
        _setSettings(MIN_REPORT_DELAY_UINT256, 0);
        _setSettings(MAX_REPORT_DELAY_UINT256, 86400);
        _setSettings(PROFIT_FACTOR_UINT256, 100);
        _setSettings(DEBT_THRESHOLD_UINT256, 0);
    }

    function setSettings(bytes32 name, address value) external override {
        _onlyAuthorized();
        _setSettings(name, value);
    }

    function setSettings(bytes32 name, uint256 value) external override {
        _onlyAuthorized();
        _setSettings(name, value);
    }

    function setSettings(bytes32 name, bool value) external override {
        _onlyAuthorized();
        _setSettings(name, value);
    }

    function removeSettings(bytes32 name) external override {
        _onlyAuthorized();
        settings[name].remove();
        emit ValueRemoved(name);
    }

    /** View Functions */

    function getAddressSettingsValue(bytes32 name) external override view returns (address){
        return settings[name].addressValue;
    }

    function getUint256SettingsValue(bytes32 name) external override view returns (uint256){
        return settings[name].uint256Value;
    }

    function getBoolSettingsValue(bytes32 name) external override view returns (bool){
        return settings[name].boolValue;
    }

    function requireAddressSettingsEqual(bytes32 name, address value) public override view {
        require(
            settings[name].addressValue == value,
            "!eq_address_value"
        );
    }

    function isAddressSettingsEqual(bytes32 name, address value) public override view returns (bool) {
        return settings[name].addressValue == value;
    }

    function isUint256SettingsEqual(bytes32 name, uint256 value) external override view returns (bool) {
        return settings[name].uint256Value == value;
    }

    function isBoolSettingsEqual(bytes32 name, bool value) external override view returns (bool) {
        return settings[name].boolValue == value;
    }

    function requireAddressSettings(bytes32 name) external override view {
        require(
            settings[name].addressValue != address(0x0),
            "settings_required"
        );
    }

    function requireUint256Settings(bytes32 name) external override view {
        require(
            settings[name].uint256Value != 0,
            "settings_required"
        );
    }

    /** Internal Functions */

    function _getSettings(bytes32 name) internal view returns (address, uint256, bool) {
        return (
            settings[name].addressValue,
            settings[name].uint256Value,
            settings[name].boolValue
        );
    }

    function _setSettings(bytes32 name, address value) internal {
        settings[name].set(value);
        emit AddressValueSet(name, value);
    }

    function _setSettings(bytes32 name, uint256 value) internal {
        settings[name].set(value);
        emit Uint256ValueSet(name, value);
    }

    function _setSettings(bytes32 name, bool value) internal {
        settings[name].set(value);
        emit BoolValueSet(name, value);
    }

    function _requireSettings(bytes32 name) internal view {
        require(
            settings[name].addressValue != address(0x0) ||
            settings[name].uint256Value != 0 ||
            !settings[name].boolValue,
            "Settings required"
        );
    }

    /**
     * Resolve governance address from Vault contract, used to make assertions
     * on protected functions in the contract.
     */
    function _governance() internal view returns (address) {
        return vault.governance();
    }

    function _onlyAuthorized() internal view {
        require(isAddressSettingsEqual(STRATEGIST_ADDRESS, msg.sender) || msg.sender == _governance());
    }
}
