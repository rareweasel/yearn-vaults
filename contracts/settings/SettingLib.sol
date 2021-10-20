// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.6.12;

library SettingLib {

    struct Setting {
        uint256 uint256Value;
        address addressValue;
        bool boolValue;
        bool exists;
    }

    function set(Setting storage self, uint256 value) internal {
        requireNotExists(self);
        self.uint256Value = value;
        self.exists = true;
    }

    function set(Setting storage self, address value) internal {
        requireNotExists(self);
        self.addressValue = value;
        self.exists = true;
    }

    function set(Setting storage self, bool value) internal {
        requireNotExists(self);
        self.boolValue = value;
        self.exists = true;
    }

    function requireNotExists(Setting storage self) internal view {
        require(!self.exists, "setting_already_exists");
    }

    function requireExists(Setting storage self) internal view {
        require(self.exists, "setting_not_exists");
    }

    function remove(Setting storage self) internal {
        requireExists(self);
        self.uint256Value = 0;
        self.boolValue = false;
        self.addressValue = address(0x0);
        self.exists = false;
    }
}
