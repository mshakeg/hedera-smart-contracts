/*-
 *
 * Hedera Smart Contracts
 *
 * Copyright (C) 2023 Hedera Hashgraph, LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import { Contract, ethers, isAddress } from 'ethers';

/**
 * @dev get token information
 *
 * @notice execute name(), symbol()
 *
 * @param baseContract: Contract
 *
 * @param method: 'name' | 'symbol'
 *
 * @return Promise<IERCSmartContractResult>
 */
export const getERC721TokenInformation = async (
  baseContract: Contract,
  method: 'name' | 'symbol'
): Promise<IERCSmartContractResult> => {
  try {
    switch (method) {
      case 'name':
        return { name: await baseContract.name() };
      case 'symbol':
        return { symbol: await baseContract.symbol() };
    }
  } catch (err) {
    console.error(err);
    return { err };
  }
};

/**
 * @dev get token URI of the tokenId token
 *
 * @param baseContract: Contract
 *
 * @param tokenId: number
 *
 * @return Promise<IERCSmartContractResult>
 */
export const erc721TokenURI = async (
  baseContract: Contract,
  tokenId: number
): Promise<IERCSmartContractResult> => {
  if (tokenId < 0) {
    return { err: 'Invalid token amount' };
  }

  try {
    return { tokenURI: (await baseContract.tokenURI(tokenId)).toString() };
  } catch (err) {
    console.error(err);
    return { err };
  }
};

/**
 * @dev mints erc721 tokens
 *
 * @param baseContract: Contract
 *
 * @param recipientAddress: address
 *
 * @param tokenId: number
 *
 * @return Promise<IERCSmartContractResult>
 */
export const erc721Mint = async (
  baseContract: Contract,
  recipientAddress: string,
  tokenId: number
): Promise<IERCSmartContractResult> => {
  if (!isAddress(recipientAddress)) {
    return { err: 'Invalid recipient address' };
  } else if (tokenId < 0) {
    return { err: 'Invalid token amount' };
  }

  try {
    const txReceipt = await (await baseContract.mint(recipientAddress, tokenId)).wait();
    return { txHash: txReceipt.hash };
  } catch (err) {
    console.error(err);
    return { err };
  }
};

/**
 * @dev get token balance owned by `accountAddress`
 *
 * @param baseContract: Contract
 *
 * @param accountAddress: address
 *
 * @return Promise<IERCSmartContractResult>
 */
export const erc721BalanceOf = async (
  baseContract: Contract,
  accountAddress: string
): Promise<IERCSmartContractResult> => {
  if (!isAddress(accountAddress)) {
    return { err: 'Invalid account address' };
  }

  try {
    return { balanceOfRes: (await baseContract.balanceOf(accountAddress)).toString() };
  } catch (err) {
    console.error(err);
    return { err };
  }
};

/**
 * @dev gets the token owner of the `tokenId` token
 *
 * @param baseContract: Contract
 *
 * @param tokenId: number
 *
 * @return Promise<IERCSmartContractResult>
 */
export const erc721OwnerOf = async (
  baseContract: Contract,
  tokenId: number
): Promise<IERCSmartContractResult> => {
  try {
    return { ownerOfRes: (await baseContract.ownerOf(tokenId)).toString() };
  } catch (err) {
    console.error(err);
    return { err };
  }
};

/**
 * @dev integrates ERC721.approve()
 *
 * @dev integrates ERC721.getApproved()
 *
 * @param baseContract: Contract
 *
 * @param method: 'APPROVE' | 'GET_APPROVE'
 *
 * @param spenderAddress: string
 *
 * @param tokenId: number
 *
 * @return Promise<IERCSmartContractResult>
 */
export const erc721TokenApprove = async (
  baseContract: Contract,
  method: 'APPROVE' | 'GET_APPROVE',
  spenderAddress: string,
  tokenId: number
): Promise<IERCSmartContractResult> => {
  if (method === 'APPROVE' && !isAddress(spenderAddress)) {
    return { err: 'Invalid account address' };
  }

  try {
    switch (method) {
      case 'APPROVE':
        const approveReceipt = await (await baseContract.approve(spenderAddress, tokenId)).wait();
        return { txHash: approveReceipt.hash };
      case 'GET_APPROVE':
        return { approvedAccountRes: await baseContract.getApproved(tokenId) };
    }
  } catch (err) {
    console.error(err);
    return { err };
  }
};

/**
 * @dev integrates ERC721.setApprovalForAll()
 *
 * @dev integrates ERC721.isApprovedForAll()
 *
 * @param baseContract: Contract
 *
 * @param method: 'SET_APPROVAL' | 'IS_APPROVAL'
 *
 * @param ownerAddress: string
 *
 * @param operatorAddress: string
 *
 * @param approvalStatus: boolean
 *
 * @return Promise<IERCSmartContractResult>
 */
export const erc721TokenApproval = async (
  baseContract: Contract,
  method: 'SET_APPROVAL' | 'IS_APPROVAL',
  ownerAddress: string,
  operatorAddress: string,
  approvalStatus: boolean
): Promise<IERCSmartContractResult> => {
  if (method === 'IS_APPROVAL' && !isAddress(ownerAddress)) {
    return { err: 'Invalid owner address' };
  } else if (!isAddress(operatorAddress)) {
    return { err: 'Invalid operator address' };
  }

  try {
    switch (method) {
      case 'SET_APPROVAL':
        const approveReceipt = await (
          await baseContract.setApprovalForAll(operatorAddress, approvalStatus)
        ).wait();
        return { txHash: approveReceipt.hash };
      case 'IS_APPROVAL':
        return {
          approvalStatusRes: await baseContract.isApprovedForAll(ownerAddress, operatorAddress),
        };
    }
  } catch (err) {
    console.error(err);
    return { err };
  }
};

/**
 * @dev handle executing APIs relate to Token Transfer
 *
 * @dev integrates ERC721.transferFrom()
 *
 * @dev integrates ERC721.safeTransferFrom()
 *
 * @param baseContract: Contract
 *
 * @param method: "TRANSFER_FROM" | "SAFE_TRANSFER_FROM"
 *
 * @param senderAddress: string
 *
 * @param recipientAddress: string
 *
 * @param tokenId: number
 *
 * @param data: string
 *
 * @return Promise<IERCSmartContractResult>
 */
export const erc721Transfers = async (
  baseContract: Contract,
  method: 'TRANSFER_FROM' | 'SAFE_TRANSFER_FROM',
  senderAddress: string,
  recipientAddress: string,
  tokenId: number,
  data: string
): Promise<IERCSmartContractResult> => {
  if (!isAddress(senderAddress)) {
    return { err: 'Invalid sender address' };
  } else if (!isAddress(recipientAddress)) {
    return { err: 'Invalid recipient address' };
  } else if (tokenId < 0) {
    return { err: 'Invalid tokenId' };
  }

  try {
    switch (method) {
      case 'TRANSFER_FROM':
        const transferReceipt = await (
          await baseContract.transferFrom(senderAddress, recipientAddress, tokenId)
        ).wait();
        return { txHash: transferReceipt.hash };

      case 'SAFE_TRANSFER_FROM':
        // Typed function signature to specify the safeTransferFrom function
        // @logic there are two safeTransferFrom functions with different params, without specifying the function signature =>`TypeError: ambiguous function description`
        const safeTransferFromFunctionSignature = 'safeTransferFrom(address,address,uint256,bytes)';

        const safeTransferReceipt = await (
          await baseContract[safeTransferFromFunctionSignature](
            senderAddress,
            recipientAddress,
            tokenId,
            ethers.toUtf8Bytes(data)
          )
        ).wait();
        return { txHash: safeTransferReceipt.hash };
    }
  } catch (err: any) {
    console.error(err);
    return { err, txHash: err.receipt && err.receipt.hash };
  }
};
