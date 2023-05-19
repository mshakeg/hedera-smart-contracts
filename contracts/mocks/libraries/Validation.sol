// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.9;

import '../../../contracts/hts-precompile/HederaResponseCodes.sol';

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
}
