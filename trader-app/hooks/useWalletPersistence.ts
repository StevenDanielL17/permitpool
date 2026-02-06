'use client';

import { useEffect } from 'react';
import { useAccount, useReconnect } from 'wagmi';

/**
 * Hook to manage wallet persistence and auto-reconnection
 * 
 * Features:
 * - Automatically reconnects wallet on page load
 * - Detects when wallet connection state changes
 * - Works with wagmi's built-in storage system
 * 
 * Usage:
 * ```tsx
 * const { isReconnecting, address } = useWalletPersistence();
 * ```
 */
export function useWalletPersistence() {
  const { address, isConnected, isConnecting } = useAccount();
  const { reconnect, isPending: isReconnecting, connectors } = useReconnect();

  // Auto-reconnect on mount if there's a stored connection
  useEffect(() => {
    // Only attempt reconnect if not already connecting/connected
    // wagmi automatically checks localStorage for previous connection
    if (!isConnected && !isConnecting && connectors.length > 0) {
      // Call reconnect without parameters - wagmi handles the rest
      reconnect();
    }
  }, [isConnected, isConnecting, connectors, reconnect]);

  return {
    address,
    isConnected,
    isReconnecting,
    isConnecting,
  };
}
