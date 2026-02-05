'use client';

import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { WagmiProvider } from 'wagmi';
import { RainbowKitProvider } from '@rainbow-me/rainbowkit';
import { config } from '@/lib/wagmi';
import { useState } from 'react';
import '@rainbow-me/rainbowkit/styles.css';

export function Providers({ children }: { children: React.ReactNode }) {
  const [queryClient] = useState(() => new QueryClient({
    defaultOptions: {
      queries: {
        staleTime: 60000, // 60s - Increased from 5s to reduce unnecessary refetches
        gcTime: 300000, // 5min - Increased from 30s for better caching
        retry: 1, // Reduced from 3 to fail faster and reduce latency
        retryDelay: 1000, // Fixed 1s delay instead of exponential backoff
        refetchOnWindowFocus: false, // Disabled to prevent unnecessary refetches
        refetchOnReconnect: true, // Keep for connection recovery
        refetchOnMount: false, // Disabled to use cached data on mount
        networkMode: 'online', // Only fetch when online
      },
    },
  }));

  return (
    <WagmiProvider config={config}>
      <QueryClientProvider client={queryClient}>
        <RainbowKitProvider>
          {children}
        </RainbowKitProvider>
      </QueryClientProvider>
    </WagmiProvider>
  );
}
