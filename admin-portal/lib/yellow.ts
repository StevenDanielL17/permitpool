import { NitroliteClient, WalletStateSigner } from '@erc7824/nitrolite';
import { createPublicClient, createWalletClient, http } from 'viem';
import { privateKeyToAccount } from 'viem/accounts';
import { mainnet, sepolia, foundry } from 'viem/chains';
import { config } from './wagmi';

const account = privateKeyToAccount(process.env.YELLOW_ADMIN_PRIVATE_KEY! as `0x${string}` || '0x0000000000000000000000000000000000000000000000000000000000000001');

const currentChain = config.chains[0]; // Default to first configured chain

const publicClient = createPublicClient({
  chain: currentChain,
  transport: http()
});

const walletClient = createWalletClient({
  chain: currentChain,
  transport: http(),
  account
});

export const yellowClient = new NitroliteClient({
  publicClient,
  walletClient,
  stateSigner: new WalletStateSigner(walletClient),
  addresses: {
    custody: '0x019B65A265EB3363822f2752141b3dF16131b262',
    adjudicator: '0x7c7ccbc98469190849BCC6c926307794fDfB11F2',
  },
  chainId: currentChain.id,
  challengeDuration: 3600n,
});

export async function createPaymentSession(
  adminAddress: `0x${string}`,
  agentAddress: `0x${string}`,
  monthlyFeeUSDC: bigint
) {
  // NOTE: Simple createChannel wrapper. Real flow requires WebSocket auth/request.
  // This is a placeholder for the integration point.
  // In a real app, this would initiate the WS flow managed by a hook or service.
  return "session_placeholder"; 
}
