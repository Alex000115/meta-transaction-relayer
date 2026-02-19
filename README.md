# Meta-Transaction Relayer

This repository provides a professional framework for building "Gasless" decentralized applications. By utilizing EIP-712 structured data signing, users can authorize contract actions with their private keys while a relayer pays the actual gas fee in ETH.

## Technical Workflow
1. **User Sign:** The user signs a structured data object (typed data) following EIP-712 standards.
2. **Relay:** The signed message and signature are sent to an off-chain relayer API.
3. **Execute:** The relayer calls the `executeMetaTransaction` function on-chain.
4. **Validation:** The contract recovers the signer's address from the signature and executes the logic as if the signer called it directly.



## Key Features
* **EIP-712 Compliance:** Uses domain separators to prevent cross-contract and cross-chain replay attacks.
* **Nonce Management:** Built-in replay protection to ensure each signature is used exactly once.
* **Flexible Logic:** Can be integrated into existing tokens, marketplaces, or voting systems.

## Usage
1. Inherit `EIP712MetaTransaction.sol` in your main contract.
2. Use `msgSender()` instead of `msg.sender` to support both direct and meta-calls.
