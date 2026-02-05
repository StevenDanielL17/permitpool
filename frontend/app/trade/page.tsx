'use client';

import { useEffect, useState, useMemo } from 'react';
import { useAccount, useReadContract } from 'wagmi';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { CheckCircle2, AlertCircle } from 'lucide-react';
import { SwapInterface } from '@/components/SwapInterface';
import { CONTRACTS } from '@/lib/contracts/addresses';
import { HOOK_ABI } from '@/lib/contracts/abis';

const LICENSE_CACHE = new Map<string, { node: string; timestamp: number }>();
const CACHE_TTL = 5 * 60 * 1000; // 5 minutes

export default function TradingPage() {
  const { address, isConnected } = useAccount();
  const [licenseNode, setLicenseNode] = useState<`0x${string}` | null>(null);
  const [cacheHit, setCacheHit] = useState(false);

  // Check cache first
  const cachedNode = useMemo(() => {
    if (!address) return null;
    const cached = LICENSE_CACHE.get(address.toLowerCase());
    if (cached && Date.now() - cached.timestamp < CACHE_TTL) {
      setCacheHit(true);
      return cached.node;
    }
    return null;
  }, [address]);

  // Check if user has a license - skip if cached
  const { data: nodeData, isLoading } = useReadContract({
    address: CONTRACTS.HOOK,
    abi: HOOK_ABI,
    functionName: 'getENSNodeForAddress',
    args: address && !cachedNode ? [address] : undefined,
  });

  useEffect(() => {
    // Use cached node if available
    if (cachedNode) {
      setLicenseNode(cachedNode as `0x${string}`);
      return;
    }

    if (nodeData && nodeData !== '0x0000000000000000000000000000000000000000000000000000000000000000') {
      const node = nodeData as `0x${string}`;
      setLicenseNode(node);
      // Cache the result
      if (address) {
        LICENSE_CACHE.set(address.toLowerCase(), {
          node,
          timestamp: Date.now(),
        });
      }
    } else {
      setLicenseNode(null);
    }
  }, [nodeData, cachedNode, address]);

  if (!isConnected) {
    return (
      <div className="container mx-auto p-8 text-center">
        <h1 className="text-4xl font-bold mb-4">Trading Interface</h1>
        <p className="text-xl text-gray-600">Please connect your wallet to continue</p>
      </div>
    );
  }

  if (isLoading && !cacheHit) {
    return (
      <div className="container mx-auto p-8 text-center">
        <h1 className="text-4xl font-bold mb-4">Checking License...</h1>
      </div>
    );
  }

  if (!licenseNode) {
    return (
      <div className="container mx-auto p-8">
        <Alert variant="destructive" className="max-w-2xl mx-auto">
          <AlertCircle className="h-4 w-4" />
          <AlertDescription className="ml-2">
            <h3 className="font-semibold mb-2">No Trading License Found</h3>
            <p>You need a valid trading license to use this pool.</p>
            <p className="mt-2">Please contact your administrator to request access.</p>
          </AlertDescription>
        </Alert>
      </div>
    );
  }

  return (
    <div className="container mx-auto p-8">
      <Alert className="max-w-2xl mx-auto mb-8 border-green-200 bg-green-50">
        <CheckCircle2 className="h-4 w-4 text-green-600" />
        <AlertDescription className="ml-2">
          <span className="font-semibold text-green-900">✓ License Verified</span>
          <p className="text-sm text-green-800 mt-1">
            You are authorized to trade on this pool
          </p>
        </AlertDescription>
      </Alert>

      <Card className="max-w-2xl mx-auto">
        <CardHeader>
          <CardTitle>Execute Trade</CardTitle>
        </CardHeader>
        <CardContent>
          <SwapInterface licenseNode={licenseNode} />
        </CardContent>
      </Card>
    </div>
  );
}
