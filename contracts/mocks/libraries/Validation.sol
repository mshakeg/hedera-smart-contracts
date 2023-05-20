// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.9;

import '../../../contracts/hts-precompile/HederaResponseCodes.sol';
import '../hts-precompile/HederaFungibleToken.sol';
import '../interfaces/IHtsPrecompileMock.sol';

library Validation {

    /// checks if token exists and has not been deleted and returns appropriate response code
    function _validateToken(
        address token,
        mapping(address => bool) storage _tokenDeleted,
        mapping(address => bool) storage _isFungible,
        mapping(address => bool) storage _isNonFungible
    ) internal view returns (bool success, int64 responseCode) {

        if (_tokenDeleted[token]) {
            return (false, HederaResponseCodes.TOKEN_WAS_DELETED);
        }

        if (!_isFungible[token] && !_isNonFungible[token]) {
            return (false, HederaResponseCodes.INVALID_TOKEN_ID);
        }

        success = true;
        responseCode = HederaResponseCodes.SUCCESS;
    }

    function _validateIsFungible(
        address token,
        mapping(address => bool) storage _isFungible
    ) internal view returns (bool success, int64 responseCode) {

        if (!_isFungible[token]) {
            return (false, HederaResponseCodes.INVALID_TOKEN_ID);
        }

        success = true;
        responseCode = HederaResponseCodes.SUCCESS;
    }

    function _validateIsNonFungible(
        address token,
        mapping(address => bool) storage _isNonFungible
    ) internal view returns (bool success, int64 responseCode) {
        if (!_isNonFungible[token]) {
            return (false, HederaResponseCodes.INVALID_TOKEN_ID);
        }

        success = true;
        responseCode = HederaResponseCodes.SUCCESS;
    }

    function _validateAdminKey(bool validKey, bool noKey) internal pure returns (bool success, int64 responseCode) {
        if (noKey) {
            return (false, HederaResponseCodes.TOKEN_IS_IMMUTABLE);
        }

        if (!validKey) {
            return (false, HederaResponseCodes.INVALID_ADMIN_KEY);
        }

        success = true;
        responseCode = HederaResponseCodes.SUCCESS;
    }

    function _validateFreezeKey(bool validKey, bool noKey) internal pure returns (bool success, int64 responseCode) {

        if (noKey) {
            return (false, HederaResponseCodes.TOKEN_HAS_NO_FREEZE_KEY);
        }

        if (!validKey) {
            return (false, HederaResponseCodes.INVALID_FREEZE_KEY);
        }

        success = true;
        responseCode = HederaResponseCodes.SUCCESS;
    }

    function _validatePauseKey(bool validKey, bool noKey) internal pure returns (bool success, int64 responseCode) {
        if (noKey) {
            return (false, HederaResponseCodes.TOKEN_HAS_NO_PAUSE_KEY);
        }

        if (!validKey) {
            return (false, HederaResponseCodes.INVALID_PAUSE_KEY);
        }

        success = true;
        responseCode = HederaResponseCodes.SUCCESS;
    }

    function _validateKycKey(bool validKey, bool noKey) internal pure returns (bool success, int64 responseCode) {
        if (noKey) {
            return (false, HederaResponseCodes.TOKEN_HAS_NO_KYC_KEY);
        }

        if (!validKey) {
            return (false, HederaResponseCodes.INVALID_KYC_KEY);
        }

        success = true;
        responseCode = HederaResponseCodes.SUCCESS;
    }

    function _validateSupplyKey(bool validKey, bool noKey) internal pure returns (bool success, int64 responseCode) {
        if (noKey) {
            return (false, HederaResponseCodes.TOKEN_HAS_NO_SUPPLY_KEY);
        }

        if (!validKey) {
            return (false, HederaResponseCodes.INVALID_SUPPLY_KEY);
        }

        success = true;
        responseCode = HederaResponseCodes.SUCCESS;
    }

    function _validateTreasuryKey(bool validKey, bool noKey) internal pure returns (bool success, int64 responseCode) {
        if (noKey) {
            return (false, HederaResponseCodes.AUTHORIZATION_FAILED);
        }

        if (!validKey) {
            return (false, HederaResponseCodes.AUTHORIZATION_FAILED);
        }

        success = true;
        responseCode = HederaResponseCodes.SUCCESS;
    }

    function _validateAccountKyc(bool kycPass) internal pure returns (bool success, int64 responseCode) {

        if (!kycPass) {
            return (false, HederaResponseCodes.ACCOUNT_KYC_NOT_GRANTED_FOR_TOKEN);
        }

        success = true;
        responseCode = HederaResponseCodes.SUCCESS;

    }

    function _validateAccountFrozen(bool frozenPass) internal pure returns (bool success, int64 responseCode) {

        if (!frozenPass) {
            return (false, HederaResponseCodes.ACCOUNT_FROZEN_FOR_TOKEN);
        }

        success = true;
        responseCode = HederaResponseCodes.SUCCESS;

    }

    function _validateNftOwnership(
        address token,
        address expectedOwner,
        uint serialNumber,
        mapping(address => bool) storage _isNonFungible,
        mapping(address => mapping(int64 => IHtsPrecompileMock.PartialNonFungibleTokenInfo)) storage _partialNonFungibleTokenInfos
    ) internal view returns (bool success, int64 responseCode) {
        if (_isNonFungible[token]) {
            int64 _serialNumber = int64(uint64(serialNumber));
            IHtsPrecompileMock.PartialNonFungibleTokenInfo memory partialNonFungibleTokenInfo = _partialNonFungibleTokenInfos[token][_serialNumber];

            if (partialNonFungibleTokenInfo.ownerId != expectedOwner) {
                return (false, HederaResponseCodes.SENDER_DOES_NOT_OWN_NFT_SERIAL_NO);
            }
        }

        success = true;
        responseCode = HederaResponseCodes.SUCCESS;
    }

    function _validateFungibleBalance(
        address token,
        address owner,
        uint amount,
        mapping(address => bool) storage _isFungible
    ) internal view returns (bool success, int64 responseCode) {
        if (_isFungible[token]) {
            HederaFungibleToken hederaFungibleToken = HederaFungibleToken(token);

            bool sufficientBalance = hederaFungibleToken.balanceOf(owner) >= uint64(amount);

            if (!sufficientBalance) {
                return (false, HederaResponseCodes.INSUFFICIENT_TOKEN_BALANCE);
            }
        }

        success = true;
        responseCode = HederaResponseCodes.SUCCESS;
    }

    function _validateTokenSufficiency(
        address token,
        address owner,
        int64 amount,
        int64 serialNumber,
        mapping(address => bool) storage _isFungible,
        mapping(address => bool) storage _isNonFungible,
        mapping(address => mapping(int64 => IHtsPrecompileMock.PartialNonFungibleTokenInfo)) storage _partialNonFungibleTokenInfos
    ) internal view returns (bool success, int64 responseCode) {

        if (_isFungible[token]) {
            uint256 amountU256 = uint64(amount);
            return _validateFungibleBalance(token, owner, amountU256, _isFungible);
        }

        if (_isNonFungible[token]) {
            uint256 serialNumberU256 = uint64(serialNumber);
            return _validateNftOwnership(token, owner, serialNumberU256, _isNonFungible, _partialNonFungibleTokenInfos);
        }
    }

    function _validateTokenAssociation(
        address token,
        address account,
        mapping(address => mapping(address => bool)) storage _association
    ) internal view returns (bool success, int64 responseCode) {
        if (!_association[token][account]) {
            return (false, HederaResponseCodes.TOKEN_NOT_ASSOCIATED_TO_ACCOUNT);
        }

        success = true;
        responseCode = HederaResponseCodes.SUCCESS;
    }
}
