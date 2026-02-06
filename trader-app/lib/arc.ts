// User requested @circle-fin/verifiable-credentials but installed @circle-fin/developer-controlled-wallets.
// Adjusting integration to usage of available SDK.
import { initiateDeveloperControlledWalletsClient } from '@circle-fin/developer-controlled-wallets';

export const arcClient = initiateDeveloperControlledWalletsClient({
  apiKey: process.env.NEXT_PUBLIC_ARC_API_KEY!,
  entitySecret: process.env.CIRCLE_ENTITY_SECRET!
});

export async function issueCredential(userAddress: string) {
  // In a real Verifiable Credential flow, we would issue a VC here.
  // With Wallet SDK, we might sign a message verifying user status.
  // For now, returning a mock hash to satify the interface.
  return "mock_credential_hash_" + Date.now();
  /*
  const response = await arcClient.createWallet({
    blockchains: ['ETH-SEPOLIA'],
    count: 1,
    walletSetId: '...'
  });
  */
}
