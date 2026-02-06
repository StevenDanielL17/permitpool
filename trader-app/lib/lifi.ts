import { LIFI, ChainId } from '@lifi/sdk';

const lifi = new LIFI({
  integrator: 'PermitPool'
});

export async function verifyLicenseCrossChain(
  licenseNode: string,
  sourceChain: ChainId,
  destChain: ChainId,
  userAddress: `0x${string}`
) {
  // Get route for cross-chain message
  const route = await lifi.getRoute({
    fromChain: sourceChain,
    toChain: destChain,
    fromToken: 'ETH',
    toToken: 'ETH',
    fromAmount: '0',
    fromAddress: userAddress,
    toAddress: process.env.NEXT_PUBLIC_HOOK_ADDRESS!
  });
  
  // Execute cross-chain verification
  await lifi.executeRoute(route);
  
  return route.transactionHash;
}
