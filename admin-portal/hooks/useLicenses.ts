'use client';

import { useEffect, useState } from 'react';
import { usePublicClient } from 'wagmi';
import { createPublicClient, http } from 'viem';
import { sepolia } from 'viem/chains';
import { CONTRACTS } from '@/lib/contracts/addresses';
import { LICENSE_MANAGER_ABI } from '@/lib/contracts/abis';

export interface License {
  subdomain: string;
  owner: string;
  node: `0x${string}`;
  arcCredential: string;
  blockNumber: bigint;
  transactionHash: `0x${string}`;
  timestamp?: number;
}

export function useLicenses() {
  const [licenses, setLicenses] = useState<License[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);
  
  const wagmiClient = usePublicClient();

  useEffect(() => {
    async function fetchLicenses() {
      try {
        setIsLoading(true);
        setError(null);

        // Create a direct client using drpc.org (no rate limits)
        const publicClient = createPublicClient({
          chain: sepolia,
          transport: http('https://sepolia.drpc.org'),
        });

        // Get current block
        const currentBlock = await publicClient.getBlockNumber();
        
        // Query last 50,000 blocks (about 1 week on Sepolia) in chunks
        const fromBlock = currentBlock > 50000n ? currentBlock - 50000n : 0n;
        const CHUNK_SIZE = 10000n; // 10K blocks per query
        
        let allLogs: any[] = [];
        
        // Query in chunks to avoid timeouts
        for (let start = fromBlock; start <= currentBlock; start += CHUNK_SIZE) {
          const end = start + CHUNK_SIZE > currentBlock ? currentBlock : start + CHUNK_SIZE;
          
          try {
            const logs = await publicClient.getLogs({
              address: CONTRACTS.LICENSE_MANAGER,
              event: {
                type: 'event',
                name: 'LicenseIssued',
                inputs: [
                  { name: 'licensee', type: 'address', indexed: true },
                  { name: 'subnode', type: 'bytes32', indexed: true },
                  { name: 'subdomain', type: 'string', indexed: false },
                ],
              },
              fromBlock: start,
              toBlock: end,
            });
            
            allLogs = [...allLogs, ...logs];
          } catch (chunkError) {
            console.warn(`Skipping chunk ${start}-${end}:`, chunkError);
            // Continue with next chunk even if one fails
          }
        }

        // Parse the logs into License objects
        const parsedLicenses: License[] = allLogs.map((log) => {
          const { licensee, subnode, subdomain } = log.args as {
            licensee: `0x${string}`;
            subnode: `0x${string}`;
            subdomain: string;
          };

          return {
            subdomain: subdomain,
            owner: licensee,
            node: subnode,
            arcCredential: '', // Not in event, fetch separately if needed
            blockNumber: log.blockNumber,
            transactionHash: log.transactionHash,
          };
        });

        // Deduplicate by node (keep the most recent one per unique node)
        const uniqueLicenses = parsedLicenses.reduce((acc, license) => {
          const existing = acc.find(l => l.node === license.node);
          if (!existing || license.blockNumber > existing.blockNumber) {
            // Replace if we found a newer version, or add if new
            return existing 
              ? acc.map(l => l.node === license.node ? license : l)
              : [...acc, license];
          }
          return acc;
        }, [] as License[]);

        // Sort by block number (most recent first)
        uniqueLicenses.sort((a, b) => Number(b.blockNumber - a.blockNumber));

        setLicenses(uniqueLicenses);
      } catch (err) {
        console.error('Error fetching licenses:', err);
        setError(err instanceof Error ? err : new Error('Failed to fetch licenses'));
      } finally {
        setIsLoading(false);
      }
    }

    fetchLicenses();
  }, [wagmiClient]);

  return { licenses, isLoading, error, refetch: () => {} };
}
