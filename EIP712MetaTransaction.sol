// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

abstract contract EIP712MetaTransaction {
    using ECDSA for bytes32;

    mapping(address => uint256) private nonces;

    bytes32 private immutable DOMAIN_SEPARATOR;
    bytes32 private constant META_TRANSACTION_TYPEHASH = keccak256(
        "MetaTransaction(uint256 nonce,address from,bytes functionSignature)"
    );

    struct MetaTransaction {
        uint256 nonce;
        address from;
        bytes functionSignature;
    }

    constructor(string memory name, string memory version) {
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name)),
                keccak256(bytes(version)),
                block.chainid,
                address(this)
            )
        );
    }

    function executeMetaTransaction(
        address userAddress,
        bytes memory functionSignature,
        bytes32 sigR,
        bytes32 sigS,
        uint8 sigV
    ) public payable returns (bytes memory) {
        MetaTransaction memory metaTx = MetaTransaction({
            nonce: nonces[userAddress],
            from: userAddress,
            functionSignature: functionSignature
        });

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(META_TRANSACTION_TYPEHASH, metaTx.nonce, metaTx.from, keccak256(metaTx.functionSignature)))
            )
        );

        require(userAddress == digest.recover(sigV, sigR, sigS), "Signature mismatch");
        
        nonces[userAddress]++;

        (bool success, bytes memory returnData) = address(this).call(
            abi.encodePacked(functionSignature, userAddress)
        );
        require(success, "Function call failed");

        return returnData;
    }

    function getNonce(address user) public view returns (uint256) {
        return nonces[user];
    }

    function _msgSender() internal view virtual returns (address sender) {
        if (msg.sender == address(this)) {
            bytes memory array = msg.data;
            uint256 index = msg.data.length;
            assembly {
                sender := mload(add(array, index))
            }
        } else {
            sender = msg.sender;
        }
        return sender;
    }
}
