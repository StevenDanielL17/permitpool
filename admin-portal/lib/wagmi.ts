import { getDefaultConfig } from '@rainbow-me/rainbowkit';
import { mainnet, sepolia, foundry } from 'wagmi/chains';
import { http } from 'viem';
import { createStorage } from 'wagmi';

// Suppress WalletConnect session_request warnings in console
if (typeof window !== 'undefined') {
  const originalWarn = console.warn;
  console.warn = (...args: any[]) => {
    if (
      typeof args[0] === 'string' &&
      args[0].includes('emitting session_request')
    ) {
      return; // Suppress this specific warning
    }
    originalWarn(...args);
  };
}

// Optimize Sepolia RPC for faster responses
const sepoliaOptimized = {
  ...sepolia,
  rpcUrls: {
    default: {
      http: [
        'https://sepolia.drpc.org',
        'https://eth-sepolia-public.unifra.io',
      ],
    },
  },
};

export const config = getDefaultConfig({
  appName: 'PermitPool',
  projectId: process.env.NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID || '02d8a49c5627c022e8f5bf13e32d5f37',
  chains: [mainnet, sepoliaOptimized, foundry],
  ssr: true,
  // Enable persistent wallet connections
  storage: createStorage({
    storage: typeof window !== 'undefined' ? window.localStorage : undefined,
    key: 'permitpool.wallet', // Unique key for this app
  }),
  transports: {
    [mainnet.id]: http(),
    [sepoliaOptimized.id]: http(),
    [foundry.id]: http(),
  },
});
