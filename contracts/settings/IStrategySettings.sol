// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

/**
 * @title Yearn Strategy Settings
 * @author yearn.finance
 */
interface IStrategySettings {

    function setSettings(bytes32 name, address value) external;

    function setSettings(bytes32 name, uint256 value) external;

    function setSettings(bytes32 name, bool value) external;

    function removeSettings(bytes32 name) external;

    /** View Functions */
    function getAddressSettingsValue(bytes32 name) external view returns (address);

    function getUint256SettingsValue(bytes32 name) external view returns (uint256);

    function getBoolSettingsValue(bytes32 name) external view returns (bool);

    function requireAddressSettingsEqual(bytes32 name, address value) external view;

    function isAddressSettingsEqual(bytes32 name, address value) external view returns (bool);

    function isUint256SettingsEqual(bytes32 name, uint256 value) external view returns (bool);

    function isBoolSettingsEqual(bytes32 name, bool value) external view returns (bool);

    function requireAddressSettings(bytes32 name) external view;

    function requireUint256Settings(bytes32 name) external view;

    /** Events */

    event Uint256ValueSet(bytes32 indexed key, uint256 value);
    event AddressValueSet(bytes32 indexed key, address value);
    event BoolValueSet(bytes32 indexed key, bool value);
    event ValueRemoved(bytes32 indexed key);
}
