import { NextApiRequest, NextApiResponse } from 'next';
import { RpcProvider, Account, Contract } from 'starknet';
import { getCompiledCode } from '@/lib/utils1';

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  if (req.method !== 'POST') {
    return res.status(405).json({ message: 'Method not allowed' });
  }

  try {
    const privateKey = process.env.OZ_ACCOUNT_PRIVATE_KEY;
    const accountAddress = process.env.ACCOUNT_ADDRESS;

    if (!privateKey || !accountAddress) {
      return res.status(500).json({ 
        error: 'Missing environment variables' 
      });
    }

    const provider = new RpcProvider({ 
      nodeUrl: process.env.STARKNET_PROVIDER_URL || 'https://starknet-sepolia.infura.io/v3/354ffdd7ccf94ab6a02cdfdeabdfd331' 
    });

    const account = new Account(provider, accountAddress, privateKey);

    // Get compiled code
    const { sierraCode, casmCode } = await getCompiledCode("defi");

    // Declare contract
    const declareResponse = await account.declare({
      contract: sierraCode,
      casm: casmCode,
    });

    // Wait for transaction
    await provider.waitForTransaction(declareResponse.transaction_hash);

    // Deploy contract
    const deployResponse = await account.deployContract({ 
      classHash: declareResponse.class_hash 
    });
    await provider.waitForTransaction(deployResponse.transaction_hash);

    // Get contract ABI
    const { abi } = await provider.getClassByHash(declareResponse.class_hash);
    if (!abi) {
      throw new Error('No ABI found');
    }

    const contract = new Contract(abi, deployResponse.contract_address, provider);

    return res.status(200).json({
      success: true,
      contractAddress: contract.address,
      classHash: declareResponse.class_hash,
      transactionHash: deployResponse.transaction_hash
    });

  } catch (error) {
    console.error('Contract deployment error:', error);
    return res.status(500).json({
      error: 'Contract deployment failed',
      details: error instanceof Error ? error.message : 'Unknown error'
    });
  }
}