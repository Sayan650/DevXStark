/* eslint-disable @typescript-eslint/no-unused-vars */
import { RpcProvider, Account, Contract, json, stark, uint256, shortString } from 'starknet';
import fs from 'fs';

// connect provider
const provider = new RpcProvider({ nodeUrl: 'http://127.0.0.1:5050/rpc' });
// connect your account. To adapt to your own account:
const privateKey0 = process.env.OZ_ACCOUNT_PRIVATE_KEY;
if (!privateKey0) {
    throw new Error('OZ_ACCOUNT_PRIVATE_KEY is not defined');
  }
  
const account0Address: string = '0x123....789';

const account0 = new Account(provider, account0Address, privateKey0);

// Declare Test contract in devnet
const compiledTestSierra = json.parse(
  fs.readFileSync('./compiledContracts/test.sierra').toString('ascii')
);
const compiledTestCasm = json.parse(
  fs.readFileSync('./compiledContracts/test.casm').toString('ascii')
);
const declareResponse = await account0.declare({
  contract: compiledTestSierra,
  casm: compiledTestCasm,
});

console.log('Test Contract declared with classHash =', declareResponse.class_hash);
await provider.waitForTransaction(declareResponse.transaction_hash);
console.log('✅ Test Completed.');

const deployResponse = await account0.deployContract({ classHash: declareResponse.class_hash });
await provider.waitForTransaction(deployResponse.transaction_hash);

// read abi of Test contract
const { abi: testAbi } = await provider.getClassByHash(declareResponse.class_hash);
if (testAbi === undefined) {
  throw new Error('no abi.');
}

// Connect the new contract instance:
const myTestContract = new Contract(testAbi, deployResponse.contract_address, provider);
console.log('✅ Test Contract connected at =', myTestContract.address);

