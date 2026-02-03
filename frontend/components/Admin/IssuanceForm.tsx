'use client';

import { useState } from 'react';
import { useWriteContract, useWaitForTransactionReceipt } from 'wagmi';
import { keccak256, toHex } from 'viem';
import { LICENSE_MANAGER_ADDRESS, LICENSE_MANAGER_ABI } from '@/lib/contracts/definitions';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';

export function IssuanceForm() {
  const [label, setLabel] = useState('');
  const [address, setAddress] = useState('');
  const [credentialHash, setCredentialHash] = useState('');
  const [isKYCProcessing, setIsKYCProcessing] = useState(false);

  const { data: hash, writeContract, isPending, error } = useWriteContract();
  
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({
    hash,
  });

  const handleKYC = async () => {
    setIsKYCProcessing(true);
    // Simulate Arc KYC delay
    await new Promise((resolve) => setTimeout(resolve, 1500));
    // Generate a mock hash (in reality, this comes from Arc API)
    const mockHash = keccak256(toHex(Date.now()));
    setCredentialHash(mockHash);
    setIsKYCProcessing(false);
  };

  const handleIssue = () => {
    if (!label || !address || !credentialHash) return;
    
    writeContract({
      address: LICENSE_MANAGER_ADDRESS,
      abi: LICENSE_MANAGER_ABI,
      functionName: 'issueLicense',
      args: [address as `0x${string}`, label, credentialHash],
    });
  };

  return (
    <Card>
      <CardHeader>
        <CardTitle>Issue New License</CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        <div className="space-y-2">
          <label className="text-sm font-medium">Licensee Address</label>
          <Input 
            placeholder="0x..." 
            value={address} 
            onChange={(e) => setAddress(e.target.value)} 
          />
        </div>
        
        <div className="space-y-2">
          <label className="text-sm font-medium">ENS Subdomain Label</label>
          <div className="flex items-center gap-2">
            <Input 
              placeholder="alice" 
              value={label} 
              onChange={(e) => setLabel(e.target.value)} 
            />
            <span className="text-muted-foreground">.fund.eth</span>
          </div>
        </div>

        {!credentialHash ? (
          <Button 
            variant="outline" 
            onClick={handleKYC} 
            disabled={isKYCProcessing || !address}
            className="w-full"
          >
            {isKYCProcessing ? 'Verifying Identity...' : '1. Perform Arc KYC Verification'}
          </Button>
        ) : (
          <div className="p-3 bg-muted rounded-md border text-sm break-all">
            <span className="font-semibold text-green-600">✓ Identity Verified</span>
            <br />
            Credential Hash: {credentialHash}
          </div>
        )}

        <Button 
          onClick={handleIssue} 
          disabled={!credentialHash || isPending || isConfirming}
          className="w-full"
        >
          {isPending ? 'Confirming...' : isConfirming ? 'Minting License...' : '2. Issue License'}
        </Button>

        {isSuccess && (
          <div className="p-3 bg-green-100 text-green-800 rounded-md text-sm">
            License Successfully Issued!
          </div>
        )}
        {error && (
          <div className="p-3 bg-red-100 text-red-800 rounded-md text-sm">
            Error: {error.message.split('\n')[0]}
          </div>
        )}
      </CardContent>
    </Card>
  );
}
