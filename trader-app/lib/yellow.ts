import { YellowClient } from '@yellow-network/nitrolite-sdk';

export const yellowClient = new YellowClient({
  nodeUrl: process.env.NEXT_PUBLIC_YELLOW_NODE_URL || 'https://testnet.yellow.org',
  chainId: parseInt(process.env.NEXT_PUBLIC_CHAIN_ID || '11155111')
});

export async function createPaymentSession(
  adminAddress: `0x${string}`,
  agentAddress: `0x${string}`,
  monthlyFeeUSDC: bigint
) {
  const session = await yellowClient.createSession({
    participants: [adminAddress, agentAddress],
    token: '0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238', // USDC Sepolia
    amount: monthlyFeeUSDC,
    duration: 30 * 24 * 60 * 60, // 30 days
    recurring: true,
    onChainSettlement: {
      contract: process.env.NEXT_PUBLIC_PAYMENT_MANAGER_ADDRESS!,
      method: 'settleSession'
    }
  });
  
  return session.id;
}

export async function checkSessionStatus(sessionId: string) {
  return await yellowClient.getSessionStatus(sessionId);
}
