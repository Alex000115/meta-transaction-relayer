import { ethers } from "ethers";

async function signMetaTx(
    privateKey: string,
    contractAddress: string,
    chainId: number,
    functionSignature: string,
    nonce: number
) {
    const wallet = new ethers.Wallet(privateKey);
    const domain = {
        name: "MetaTxApp",
        version: "1",
        chainId: chainId,
        verifyingContract: contractAddress
    };

    const types = {
        MetaTransaction: [
            { name: "nonce", type: "uint256" },
            { name: "from", type: "address" },
            { name: "functionSignature", type: "bytes" }
        ]
    };

    const value = {
        nonce: nonce,
        from: wallet.address,
        functionSignature: functionSignature
    };

    const signature = await wallet.signTypedData(domain, types, value);
    return ethers.Signature.from(signature);
}

export { signMetaTx };
