// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.9;

import '../../hts-precompile/IHederaTokenService.sol';

interface IHtsPrecompileMock is IHederaTokenService {

    struct TokenConfig {
        bool explicit; // true if it was explicitly set to value
        bool value;
    }

}
