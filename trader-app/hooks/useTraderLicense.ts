'use client';

import { useMemo, useEffect, useState } from 'react';
import { useAccount, useReadContract } from 'wagmi';
import { CONTRACTS } from '@/lib/contracts/addresses';
import { HOOK_ABI } from '@/lib/contracts/abis';

/**
 * Hook to detect if the connected wallet has a valid trading license
 * 
 * Features:
 * - Checks on-chain license ownership via ENS subdomain
 * - Validates license is not expired/revoked
 * - Returns license status and connection state
 * 
 * Usage:
 * ```tsx
 * const { hasLicense, isLoading, isConnected } = useTraderLicense();
 * if (hasLicense) {
 *   // Show trader dashboard
 * } else {
 *   // Show no license message
 * }
 * ```
 */
export function useTraderLicense() {
  const { address, isConnected } = useAccount();
  const [hasLicense, setHasLicense] = useState<boolean>(false);
  const [isCheckingLicense, setIsCheckingLicense] = useState<boolean>(false);

  // TODO: Implement actual on-chain license check
  // This should check if the wallet owns a valid ENS subdomain license
  // For now, we'll use a placeholder that can be replaced with actual contract calls
  
  // On-chain license check
  const { data: licenseData, isLoading: isReading } = useReadContract({
    address: CONTRACTS.HOOK,
    abi: HOOK_ABI,
    functionName: 'batchVerifyLicense',
    args: address ? [address] : undefined,
    query: {
      enabled: !!address,
      staleTime: 60_000, // Cache for 1 minute
    }
  });

  useEffect(() => {
    if (!isConnected || !address) {
      setHasLicense(false);
      return;
    }

    if (licenseData) {
      // licenseData returns [isValid, node, revoked, paymentCurrent]
      // We check isValid (index 0)
      const isValid = licenseData[0];
      setHasLicense(isValid);
    } else {
      // Fallback for dev/demo if contracts aren't connected
      // This allows testing UI flows without blockchain if needed
      const storedLicense = typeof window !== 'undefined' 
        ? localStorage.getItem(`permitpool.license.${address.toLowerCase()}`) 
        : null;
      
      if (storedLicense === 'valid') {
        setHasLicense(true);
      } else {
        setHasLicense(false);
      }
    }
  }, [address, isConnected, licenseData]);

  const isLoading = isCheckingLicense || isReading;

  return {
    hasLicense,
    isLoading: isCheckingLicense,
    isConnected,
    address,
  };
}

/**
 * Grant a license to the connected wallet (for testing/demo purposes)
 * In production, this would be done through the admin portal and on-chain
 */
export function grantLicenseForTesting(address: string) {
  if (typeof window !== 'undefined') {
    localStorage.setItem(`permitpool.license.${address.toLowerCase()}`, 'valid');
  }
}

/**
 * Revoke a license (for testing/demo purposes)
 */
export function revokeLicenseForTesting(address: string) {
  if (typeof window !== 'undefined') {
    localStorage.removeItem(`permitpool.license.${address.toLowerCase()}`);
  }
}
