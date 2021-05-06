// SPDX-License-Identifier: Apache-2.0

/*
 * Copyright 2020, Offchain Labs, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

pragma solidity ^0.6.11;

import "@openzeppelin/contracts/utils/Create2.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

import "./IExitLiquidityProvider.sol";
import "./Inbox.sol";

import "./Outbox.sol";

contract EthERC20Bridge {
    using SafeERC20 for IERC20;

    address internal constant USED_ADDRESS = address(0x01);

    // exitNum => exitDataHash => LP
    mapping(bytes32 => address) redirectedExits;

    address public l2Address;
    IInbox public inbox;

    function initialize(address _inbox, address _l2Address) external payable {
        l2Address = _l2Address;
        inbox = IInbox(_inbox);
    }

    function fastWithdrawalFromL2(
        address liquidityProvider,
        bytes memory liquidityProof,
        address erc20,
        uint256 amount,
        uint256 exitNum
    ) public {
        IOutbox outbox = IOutbox(inbox.bridge().activeOutbox());
        address msgSender = outbox.l2ToL1Sender();

        bytes32 withdrawData =
            keccak256(abi.encodePacked(exitNum, msgSender, erc20, amount));
        require(
            redirectedExits[withdrawData] == USED_ADDRESS,
            "ALREADY_EXITED"
        );
        redirectedExits[withdrawData] = liquidityProvider;

        IExitLiquidityProvider(liquidityProvider).requestLiquidity(
            msgSender,
            erc20,
            amount,
            exitNum,
            liquidityProof
        );
    }
}
