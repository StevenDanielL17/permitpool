'use client';

import { useAccount } from 'wagmi';
import { useState, useEffect } from 'react';
import { BrowserProvider } from 'ethers';

interface ENSCheckResult {
  hasENS: boolean;
  ensName: string | null;
  isLicensed: boolean;
  message: string;
}

export function useENSLicenseCheck() {
  const { address, isConnected } = useAccount();
  const [result, setResult] = useState<ENSCheckResult>({
    hasENS: false,
    ensName: null,
    isLicensed: false,
    message: 'Not connected'
  });
  const [isChecking, setIsChecking] = useState(false);

  useEffect(() => {
    async function checkENSLicense() {
      if (!isConnected || !address || !window.ethereum) {
        setResult({
          hasENS: false,
          ensName: null,
          isLicensed: false,
          message: 'Connect wallet to continue'
        });
        return;
      }

      setIsChecking(true);

      try {
        // Create provider from MetaMask
        const provider = new BrowserProvider(window.ethereum);
        
        // Lookup ENS name for connected address
        const ensName = await provider.lookupAddress(address);

        if (!ensName) {
          setResult({
            hasENS: false,
            ensName: null,
            isLicensed: false,
            message: 'No ENS name found for this wallet'
          });
          setIsChecking(false);
          return;
        }

        // Check if ENS name is a subdomain of myhedgefund-v2.eth
        const isLicenseSubdomain = ensName.endsWith('.myhedgefund-v2.eth');

        if (isLicenseSubdomain) {
          setResult({
            hasENS: true,
            ensName: ensName,
            isLicensed: true,
            message: `Licensed as ${ensName}`
          });
        } else {
          setResult({
            hasENS: true,
            ensName: ensName,
            isLicensed: false,
            message: `ENS found (${ensName}), but not a valid license`
          });
        }
      } catch (error) {
        console.error('ENS lookup error:', error);
        setResult({
          hasENS: false,
          ensName: null,
          isLicensed: false,
          message: 'Error checking ENS name'
        });
      }

      setIsChecking(false);
    }

    checkENSLicense();
  }, [address, isConnected]);

  return { ...result, isChecking };
}
