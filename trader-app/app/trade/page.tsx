'use client';

import { useEffect, useState } from 'react';
import { useAccount, useReadContract } from 'wagmi';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { CheckCircle2, AlertCircle } from 'lucide-react';
import { SwapInterface } from '@/components/SwapInterface';
import { CONTRACTS } from '@/lib/contracts/addresses';
import { HOOK_ABI } from '@/lib/contracts/abis';

export default function TradingPage() {
  const { address, isConnected } = useAccount();
  const [licenseNode, setLicenseNode] = useState<`0x${string}` | null>(null);

  // Check if user has a license
  const { data: nodeData, isLoading } = useReadContract({
    address: CONTRACTS.HOOK,
    abi: HOOK_ABI,
    functionName: 'getENSNodeForAddress',
    args: address ? [address] : undefined,
  });

  useEffect(() => {
    if (nodeData && nodeData !== '0x0000000000000000000000000000000000000000000000000000000000000000') {
      setLicenseNode(nodeData as `0x${string}`);
    } else {
      setLicenseNode(null);
    }
  }, [nodeData]);

  if (!isConnected) {
    return (
      <div className="container mx-auto p-8 text-center">
        <h1 className="text-4xl font-bold mb-4">Trading Interface</h1>
        <p className="text-xl text-gray-600">Please connect your wallet to continue</p>
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
