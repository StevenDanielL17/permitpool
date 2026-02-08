import { getDefaultConfig } from '@rainbow-me/rainbowkit';
import { sepolia } from 'wagmi/chains';
import { http } from 'viem';

// Suppress WalletConnect session_request warnings in console
if (typeof window !== 'undefined') {
  const originalWarn = console.warn;
  const originalError = console.error;
  
  console.warn = (...args: any[]) => {
    if (
      typeof args[0] === 'string' &&
      args[0].includes('emitting session_request')
    ) {
      return; // Suppress this specific warning
    }
    originalWarn(...args);
  };
  
  console.error = (...args: any[]) => {
    // Suppress WalletConnect proposal errors (harmless session cleanup)
    if (
      typeof args[0] === 'object' &&
      typeof args[1] === 'string' &&
      (args[1].includes('No matching key') || args[1].includes('proposal:'))
    ) {
      return; // Suppress WalletConnect proposal cleanup errors
    }
    originalError(...args);
  };
}

export const config = getDefaultConfig({
  appName: 'PermitPool Trader',
  projectId: process.env.NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID || '3a8170812b534d0ff9d794f19a901d64',
  chains: [sepolia],
  ssr: true,
  transports: {
    [sepolia.id]: http('https://eth-sepolia.g.alchemy.com/v2/pwne_tuyO5AK0JMS4_bvO'),
  },
});
