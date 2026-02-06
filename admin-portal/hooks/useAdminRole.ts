'use client';

import { useMemo } from 'react';
import { useAccount } from 'wagmi';

/**
 * Hook to detect if the connected wallet is the admin wallet
 * 
 * Features:
 * - Compares connected address with OWNER_ADDRESS from environment
 * - Case-insensitive comparison (addresses are normalized)
 * - Returns admin status and connection state
 * 
 * Usage:
 * ```tsx
 * const { isAdmin, isConnected, address } = useAdminRole();
 * if (isAdmin) {
 *   // Show admin dashboard
 * } else {
 *   // Show access denied
 * }
 * ```
 */
export function useAdminRole() {
  const { address, isConnected } = useAccount();

  // Get owner address from environment
  const ownerAddress = process.env.NEXT_PUBLIC_OWNER_ADDRESS?.toLowerCase();

  const isAdmin = useMemo(() => {
    if (!isConnected || !address || !ownerAddress) {
      return false;
    }
    return address.toLowerCase() === ownerAddress;
  }, [address, isConnected, ownerAddress]);

  return {
    isAdmin,
    isConnected,
    address,
    ownerAddress,
  };
}
