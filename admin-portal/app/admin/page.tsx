'use client';

import { useState } from 'react';
import { useAccount, useWriteContract, useWaitForTransactionReceipt } from 'wagmi';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { ArcKYCModal } from '@/components/ArcKYCModal';
import { LicenseList } from '@/components/LicenseList';
import { CONTRACTS } from '@/lib/contracts/addresses';
import { LICENSE_MANAGER_ABI } from '@/lib/contracts/abis';
import { toast } from 'sonner';

export default function AdminDashboard() {
  const { address, isConnected } = useAccount();
  const [subdomain, setSubdomain] = useState('');
  const [agentAddress, setAgentAddress] = useState('');
  const [showKYCModal, setShowKYCModal] = useState(false);
  const [credentialHash, setCredentialHash] = useState('');

  const { writeContract, data: hash, isPending } = useWriteContract();
  
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({
    hash,
  });

  const handleIssueLicense = async () => {
    if (!subdomain || !agentAddress) {
      toast.error('Please fill all fields');
      return;
    }

    // Open KYC modal
    setShowKYCModal(true);
  };

  const handleKYCComplete = async (credential: string) => {
    setCredentialHash(credential);
    setShowKYCModal(false);

    // Issue license on-chain
    try {
      writeContract({
        address: CONTRACTS.LICENSE_MANAGER,
        abi: LICENSE_MANAGER_ABI,
        functionName: 'issueLicense',
        args: [agentAddress as `0x${string}`, subdomain, credential],
      });

      toast.success('License issuance transaction submitted');
    } catch (error) {
      console.error('Error issuing license:', error);
      toast.error('Failed to issue license');
    }
  };

  if (isSuccess) {
    toast.success('License issued successfully!');
    setSubdomain('');
    setAgentAddress('');
  }

  if (!isConnected) {
    return (
      <div className="container mx-auto p-8 text-center">
        <h1 className="text-4xl font-bold mb-4">Admin Dashboard</h1>
        <p className="text-xl text-gray-600">Please connect your wallet to continue</p>
      </div>
    );
  }

  return (
    <div className="container mx-auto p-8">
      <h1 className="text-4xl font-bold mb-8">License Management</h1>

      <Card className="mb-8">
        <CardHeader>
          <CardTitle>Issue New License</CardTitle>
          <CardDescription>
            Create a non-transferable trading license for an agent
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div>
            <label className="block text-sm font-medium mb-2">Subdomain</label>
            <Input
              placeholder="agent1"
              value={subdomain}
              onChange={(e) => setSubdomain(e.target.value)}
              disabled={isPending || isConfirming}
            />
            <p className="text-sm text-gray-500 mt-1">
              Will create: {subdomain || 'agent'}.fund.eth
            </p>
          </div>

          <div>
            <label className="block text-sm font-medium mb-2">Agent Address</label>
            <Input
              placeholder="0x..."
              value={agentAddress}
              onChange={(e) => setAgentAddress(e.target.value)}
              disabled={isPending || isConfirming}
            />
          </div>

          <Button
            onClick={handleIssueLicense}
            disabled={isPending || isConfirming || !subdomain || !agentAddress}
            className="w-full"
          >
            {isPending || isConfirming ? 'Issuing License...' : 'Issue License'}
          </Button>

          {hash && (
            <div className="text-sm text-gray-600">
              Transaction:{' '}
              <a
                href={`https://sepolia.etherscan.io/tx/${hash}`}
                target="_blank"
                rel="noopener noreferrer"
                className="text-blue-600 hover:underline"
              >
                {hash.slice(0, 10)}...{hash.slice(-8)}
              </a>
            </div>
          )}
        </CardContent>
      </Card>

      <LicenseList />

      <ArcKYCModal
        isOpen={showKYCModal}
        onClose={() => setShowKYCModal(false)}
        onComplete={handleKYCComplete}
        userAddress={agentAddress}
      />
    </div>
  );
}
