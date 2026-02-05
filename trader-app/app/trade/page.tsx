'use client';

import { useEffect, useState, useCallback, useMemo } from 'react';
import { useAccount, useReadContract } from 'wagmi';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { CheckCircle2, AlertCircle, RotateCcw } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { SwapInterface } from '@/components/SwapInterface';
import { CONTRACTS } from '@/lib/contracts/addresses';
import { HOOK_ABI } from '@/lib/contracts/abis';

export default function TradingPage() {
  const { address, isConnected } = useAccount();
  const [licenseNode, setLicenseNode] = useState<`0x${string}` | null>(null);
  const [lastRefresh, setLastRefresh] = useState(Date.now());

  // Check if user has a license (optimized for performance)
  const { data: nodeData, isLoading, refetch } = useReadContract({
    address: CONTRACTS.HOOK,
    abi: HOOK_ABI,
    functionName: 'getENSNodeForAddress',
    args: address ? [address] : undefined,
    query: {
      enabled: !!address, // Only fetch when address exists
      staleTime: 60000, // 60s - Increased from 2s to reduce refetches
      gcTime: 300000, // 5min - Better caching
      retry: 1, // Reduced from 3 for faster failure
      retryDelay: 1000, // Fixed delay
      refetchOnWindowFocus: false, // Disabled for performance
      refetchOnReconnect: true,
      // Removed aggressive 3s auto-refetch interval
    },
  });

  // Force refetch when address changes (optimized)
  useEffect(() => {
    if (address) {
      refetch();
    }
  }, [address, refetch]);

  // Watch for license data and sync state
  useEffect(() => {
    if (nodeData && nodeData !== '0x0000000000000000000000000000000000000000000000000000000000000000') {
      setLicenseNode(nodeData as `0x${string}`);
    } else {
      setLicenseNode(null);
    }
  }, [nodeData]);

  // Manual refresh handler - for user to manually trigger instant check
  const handleManualRefresh = useCallback(async () => {
    setLastRefresh(Date.now());
    await refetch();
  }, [refetch]);

  if (!isConnected) {
    return (
      <div className="container mx-auto p-8 text-center animate-fade-in">
        <div className="max-w-2xl mx-auto py-20">
          <h1 className="text-5xl font-bold mb-6">Trading Interface</h1>
          <p className="text-xl text-gray-400 mb-8">Connect your wallet to access institutional DeFi trading</p>
        </div>
      </div>
    );
  }

  if (isLoading) {
    return (
      <div className="container mx-auto p-8 text-center animate-fade-in">
        <div className="max-w-2xl mx-auto py-20">
          <div className="animate-pulse-glow inline-block px-8 py-4 glass rounded-xl">
            <h1 className="text-3xl font-bold">Verifying License...</h1>
          </div>
        </div>
      </div>
    );
  }

  if (!licenseNode) {
    return (
      <div className="container mx-auto p-8 animate-fade-in">
        <div className="max-w-2xl mx-auto py-12">
          <div className="glass rounded-2xl p-10 border border-red-500/30">
            <div className="flex items-start gap-4 mb-6">
              <AlertCircle className="h-8 w-8 text-red-500 flex-shrink-0 mt-1" />
              <div>
                <h3 className="text-2xl font-bold mb-3">No Trading License Found</h3>
                <p className="text-gray-400 mb-2">You need a valid trading license to use this pool.</p>
                <p className="text-gray-400">Please contact your administrator to request access.</p>
              </div>
            </div>
            <Button 
              onClick={handleManualRefresh}
              disabled={isLoading}
              className="mt-6 glow-blue-sm hover-lift"
              size="lg"
            >
              <RotateCcw className={`mr-2 h-5 w-5 ${isLoading ? 'animate-spin' : ''}`} />
              {isLoading ? 'Checking License...' : 'Refresh License Status'}
            </Button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="container mx-auto p-8 animate-fade-in">
      {/* License Verified Badge */}
      <div className="max-w-3xl mx-auto mb-8">
        <div className="glass rounded-xl p-6 border border-green-500/30 glow-blue-sm">
          <div className="flex items-center gap-3">
            <CheckCircle2 className="h-6 w-6 text-green-500" />
            <div>
              <span className="font-bold text-green-500">License Verified</span>
              <p className="text-sm text-gray-400 mt-1">
                You are authorized to trade on this pool
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Trading Card */}
      <Card className="max-w-3xl mx-auto glass border-dashed-sui glow-blue">
        <CardHeader>
          <div className="flex items-center gap-3">
            <div className="mono-number text-sm text-gray-500">01</div>
            <CardTitle className="text-3xl">Execute Trade</CardTitle>
          </div>
        </CardHeader>
        <CardContent>
          <SwapInterface licenseNode={licenseNode} />
        </CardContent>
      </Card>
    </div>
  );
}
