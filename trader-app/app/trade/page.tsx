'use client';

import { useEffect, useState, useCallback, useMemo } from 'react';
import { useQueryClient } from '@tanstack/react-query';
import { useAccount, useReadContract } from 'wagmi';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { CheckCircle2, AlertCircle, RotateCcw, Loader2 } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { SwapInterface } from '@/components/SwapInterface';
import { CONTRACTS } from '@/lib/contracts/addresses';
import { HOOK_ABI } from '@/lib/contracts/abis';
import { useWalletPersistence } from '@/hooks/useWalletPersistence';
import { ConnectButton } from '@rainbow-me/rainbowkit';

export default function TradingPage() {
  const { address, isConnected } = useAccount();
  const { isReconnecting } = useWalletPersistence();
  const queryClient = useQueryClient();
  const [licenseNode, setLicenseNode] = useState<`0x${string}` | null>(null);
  const [lastRefresh, setLastRefresh] = useState(Date.now());

  // Debug: Log contract addresses on mount
  useEffect(() => {
    console.log('📋 Contract Configuration:', {
      HOOK: CONTRACTS.HOOK,
      LICENSE_MANAGER: CONTRACTS.LICENSE_MANAGER,
    });
  }, []);

  // Check if user has a license (aggressive refetch settings for real-time updates)
  const { data: nodeData, isLoading, refetch, error, isError } = useReadContract({
    address: CONTRACTS.HOOK,
    abi: HOOK_ABI,
    functionName: 'getEnsNodeForAddress',
    args: address ? [address] : undefined,
    query: {
      enabled: !!address && !!CONTRACTS.HOOK,
      staleTime: 2000, // 2s - very fresh for instant updates
      gcTime: 15000, // 15s cache window
      retry: 3,
      retryDelay: attemptIndex => Math.min(1000 * 2 ** attemptIndex, 30000),
      refetchInterval: 3000, // Auto-refetch every 3s for real-time license updates
      refetchIntervalInBackground: false,
    },
  });

  // Log any errors
  useEffect(() => {
    if (isError) {
      console.error('❌ Error fetching license:', error);
    }
  }, [isError, error]);

  // Force refetch when address changes
  useEffect(() => {
    if (address) {
      refetch();
      // Invalidate and clear cache for clean fresh start
      queryClient.removeQueries({
        queryKey: ['readContract'],
      });
    }
  }, [address, refetch, queryClient]);

  // Watch for license data and sync state
  useEffect(() => {
    console.log('🔍 License Check Debug:', {
      nodeData,
      address,
      isLoading,
      hookAddress: CONTRACTS.HOOK,
    });
    
    if (nodeData && nodeData !== '0x0000000000000000000000000000000000000000000000000000000000000000') {
      console.log('✅ Valid license node found:', nodeData);
      setLicenseNode(nodeData as `0x${string}`);
    } else {
      console.log('❌ No license node found or zero value');
      setLicenseNode(null);
    }
  }, [nodeData, address, isLoading]);

  // Manual refresh handler - for user to manually trigger instant check
  const handleManualRefresh = useCallback(async () => {
    setLastRefresh(Date.now());
    await refetch();
  }, [refetch]);

  // Show loading state while reconnecting
  if (isReconnecting) {
    return (
      <div className="container mx-auto p-8 flex items-center justify-center min-h-[60vh]">
        <div className="text-center">
          <Loader2 className="h-12 w-12 animate-spin text-primary mx-auto mb-4" />
          <h2 className="text-2xl font-bold mb-2">Reconnecting Wallet...</h2>
          <p className="text-gray-400">Restoring your previous session</p>
        </div>
      </div>
    );
  }

  if (!isConnected) {
    return (
      <div className="container mx-auto p-8 flex items-center justify-center min-h-[60vh]">
        <div className="text-center glass rounded-xl p-12 border-dashed-sui max-w-lg">
          <AlertCircle className="h-16 w-16 text-primary mx-auto mb-6" />
          <h2 className="text-3xl font-bold mb-4">Connect Your Wallet</h2>
          <p className="text-gray-400 mb-8">
            Please connect your wallet to access the trading interface
          </p>
          <ConnectButton />
        </div>
      </div>
    );
  }

  if (isLoading) {
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
            <Button 
              onClick={handleManualRefresh}
              disabled={isLoading}
              className="mt-4 gap-2"
              variant="default"
              size="sm"
            >
              <RotateCcw className={`h-4 w-4 ${isLoading ? 'animate-spin' : ''}`} />
              {isLoading ? 'Checking License...' : 'Refresh License Status'}
            </Button>
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
