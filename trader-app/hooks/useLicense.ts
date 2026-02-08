'use client';

import { useState, useEffect } from 'react';
import { useAccount, usePublicClient } from 'wagmi';
import { namehash } from 'viem';

// Hardcoded addresses
const NAME_WRAPPER = '0x0635513f179D50A207757E05759CbD106d7dFcE8' as `0x${string}`;
const PARENT_DOMAIN = 'hedgefund-v3.eth';

export function useLicense() {
  const { address } = useAccount();
  const publicClient = usePublicClient();
  const [hasLicense, setHasLicense] = useState(false);
  const [licenseName, setLicenseName] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function checkLicense() {
      if (!address || !publicClient) {
        setHasLicense(false);
        setLoading(false);
        return;
      }
      
      setLoading(true);
      
      try {
        console.log('🔍 Checking license for:', address);
        
        // Check well-known license names
        const licenseNames = ['dexter', 'whale', 'trader1', 'alpha'];
        let foundLicense = false;
        
        for (const name of licenseNames) {
          const fullName = `${name}.${PARENT_DOMAIN}`;
          const node = namehash(fullName);
          
          console.log(`🔎 Checking ${fullName}...`);
          
          // Check if this wallet owns this ENS name (ERC1155 token in NameWrapper)
          const balance = await publicClient.readContract({
            address: NAME_WRAPPER,
            abi: [{
              name: 'balanceOf',
              type: 'function',
              stateMutability: 'view',
              inputs: [
                { name: 'account', type: 'address' },
                { name: 'id', type: 'uint256' }
              ],
              outputs: [{ name: 'balance', type: 'uint256' }]
            }],
            functionName: 'balanceOf',
            args: [address, BigInt(node)]
          });
          
          if (balance > 0n) {
            console.log(`✅ FOUND LICENSE: ${fullName}`);
            setHasLicense(true);
            setLicenseName(fullName);
            foundLicense = true;
            break;
          }
        }
        
        if (!foundLicense) {
          console.log('❌ No license found');
          setHasLicense(false);
          setLicenseName(null);
        }
      } catch (error) {
        console.error('❌ Error checking license:', error);
        setHasLicense(false);
        setLicenseName(null);
      }
      
      setLoading(false);
    }
    
    checkLicense();
  }, [address, publicClient]);

  return { 
    hasLicense, 
    licenseName,
    isLoading: loading 
  };
}
