'use client';

import { useState } from 'react';
import { useAccount, useWriteContract, useWaitForTransactionReceipt } from 'wagmi';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { ArcKYCModal } from '@/components/ArcKYCModal';
import { CONTRACTS } from '@/lib/contracts/addresses';
import { LICENSE_MANAGER_ABI } from '@/lib/contracts/abis';
import { toast } from 'sonner';
import { ArrowLeft, Shield, Wallet, FileText } from 'lucide-react';
import Link from 'next/link';

export default function IssueLicensePage() {
  const { address, isConnected } = useAccount();
  const [subdomain, setSubdomain] = useState('');
  const [traderName, setTraderName] = useState('');
  const [agentAddress, setAgentAddress] = useState('');
  const [monthlyFee, setMonthlyFee] = useState('50');
  const [department, setDepartment] = useState('');
  const [showKYCModal, setShowKYCModal] = useState(false);
  const [credentialHash, setCredentialHash] = useState('');
  const [isProcessing, setIsProcessing] = useState(false);

  const { writeContract, data: hash, isPending, reset } = useWriteContract();
  
  // Non-blocking confirmation watch - runs in background
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({
    hash,
    query: {
      enabled: !!hash, // Only watch if hash exists
    }
  });

  const handleStartIssuance = async () => {
    if (!subdomain || !agentAddress || !traderName) {
      toast.error('Please fill all required fields');
      return;
    }

    // Validate Ethereum address
    if (!/^0x[a-fA-F0-9]{40}$/.test(agentAddress)) {
      toast.error('Invalid Ethereum address');
      return;
    }

    // Open KYC modal
    setShowKYCModal(true);
  };

  const handleKYCComplete = async (credential: string) => {
    setCredentialHash(credential);
    setShowKYCModal(false);
    setIsProcessing(true);

    // Issue license on-chain
    try {
      await writeContract({
        address: CONTRACTS.LICENSE_MANAGER,
        abi: LICENSE_MANAGER_ABI,
        functionName: 'issueLicense',
        args: [agentAddress as `0x${string}`, subdomain, credential],
        gas: BigInt(500000),
      });

      // Transaction submitted successfully - show optimistic success
      toast.success(`Transaction submitted for ${traderName}! Waiting for blockchain confirmation...`, {
        duration: 5000,
      });

      // Reset form immediately (optimistic update - don't wait for confirmation)
      setTimeout(() => {
        setSubdomain('');
        setTraderName('');
        setAgentAddress('');
        setMonthlyFee('50');
        setDepartment('');
        setIsProcessing(false);
        reset(); // Reset writeContract state
      }, 1000);

    } catch (error: any) {
      console.error('Error issuing license:', error);
      setIsProcessing(false);
      
      // Handle specific error types
      if (error?.message?.includes('User rejected') || error?.message?.includes('user rejected')) {
        toast.error('Transaction rejected by user.');
      } else if (error?.message?.includes('insufficient funds')) {
        toast.error('Insufficient ETH for gas fees.');
      } else if (error?.message?.includes('network')) {
        toast.error('Network error. Please try again.');
      } else {
        toast.error(`Transaction failed: ${error?.message || 'Unknown error'}`);
      }
    }
  };

  // Background notification when transaction confirms
  if (isSuccess && hash) {
    toast.success(`✅ License confirmed on blockchain!`, {
      id: hash, // Prevent duplicate toasts
      duration: 3000,
    });
  }

  if (!isConnected) {
    return (
      <div className="container mx-auto p-8 text-center animate-fade-in">
        <div className="max-w-2xl mx-auto py-20">
          <h1 className="text-5xl font-bold mb-6">Issue License</h1>
          <p className="text-xl text-gray-400 mb-8">Connect your wallet to issue trading licenses</p>
        </div>
      </div>
    );
  }

  return (
    <div className="container mx-auto p-8 animate-fade-in">
      {/* Header */}
      <div className="mb-8">
        <Link href="/admin">
          <Button variant="ghost" className="mb-4">
            <ArrowLeft className="mr-2 h-4 w-4" />
            Back to Dashboard
          </Button>
        </Link>
        <h1 className="text-5xl font-bold mb-3">Issue New License</h1>
        <p className="text-gray-400">Create a non-transferable trading license with Arc KYC verification</p>
      </div>

      {/* Form Card */}
      <div className="max-w-3xl">
        {/* Info Banner */}
        <div className="mb-6 glass rounded-lg p-4 border border-primary/30">
          <div className="flex items-start gap-3">
            <Shield className="h-5 w-5 text-primary mt-0.5 flex-shrink-0" />
            <div>
              <h3 className="font-semibold text-primary mb-1">How License Issuance Works</h3>
              <ol className="text-sm text-gray-400 space-y-1 list-decimal list-inside">
                <li>Fill in the trader details below</li>
                <li>Click "Start Arc KYC Verification" to begin the process</li>
                <li>Complete the Arc KYC verification in the modal</li>
                <li><strong className="text-white">Approve the transaction in your wallet when prompted</strong></li>
                <li>Wait for blockchain confirmation</li>
              </ol>
              <p className="text-xs text-yellow-500 mt-2">
                ⚠️ Make sure you have enough ETH in your wallet for gas fees
              </p>
            </div>
          </div>
        </div>

        <Card className="glass border-dashed-sui glow-blue">
          <CardHeader>
            <div className="flex items-center gap-3">
              <div className="mono-number text-sm text-gray-500">01</div>
              <CardTitle className="text-2xl">License Details</CardTitle>
            </div>
            <CardDescription className="text-gray-400">
              Enter trader information and configure license parameters
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-6">
            {/* Trader Name */}
            <div>
              <label className="block text-sm font-semibold text-gray-400 uppercase tracking-wide mb-2">
                Trader Name *
              </label>
              <Input
                placeholder="John Doe"
                value={traderName}
                onChange={(e) => setTraderName(e.target.value)}
                disabled={isProcessing}
                className="bg-white/5 border-white/10"
              />
            </div>

            {/* Subdomain */}
            <div>
              <label className="block text-sm font-semibold text-gray-400 uppercase tracking-wide mb-2">
                Subdomain *
              </label>
              <Input
                placeholder="trader1"
                value={subdomain}
                onChange={(e) => setSubdomain(e.target.value.toLowerCase().replace(/[^a-z0-9]/g, ''))}
                disabled={isProcessing}
                className="bg-white/5 border-white/10"
              />
              <div className="mt-2 p-3 glass rounded-lg border border-primary/30">
                <p className="text-sm text-gray-400">Preview:</p>
                <p className="text-lg font-bold mono-number text-primary">
                  {subdomain || 'trader'}.fund.eth
                </p>
              </div>
            </div>

            {/* Wallet Address */}
            <div>
              <label className="block text-sm font-semibold text-gray-400 uppercase tracking-wide mb-2">
                Wallet Address *
              </label>
              <div className="flex gap-2">
                <Wallet className="h-10 w-10 text-gray-500 flex-shrink-0 mt-1" />
                <Input
                  placeholder="0x..."
                  value={agentAddress}
                  onChange={(e) => setAgentAddress(e.target.value)}
                  disabled={isProcessing}
                  className="bg-white/5 border-white/10 font-mono"
                />
              </div>
            </div>

            {/* Monthly Fee */}
            <div>
              <label className="block text-sm font-semibold text-gray-400 uppercase tracking-wide mb-2">
                Monthly Fee (USDC)
              </label>
              <Input
                type="number"
                placeholder="50"
                value={monthlyFee}
                onChange={(e) => setMonthlyFee(e.target.value)}
                disabled={isProcessing}
                className="bg-white/5 border-white/10"
              />
              <p className="text-xs text-gray-500 mt-1">Default: $50 USDC per month</p>
            </div>

            {/* Department (Optional) */}
            <div>
              <label className="block text-sm font-semibold text-gray-400 uppercase tracking-wide mb-2">
                Department / Role (Optional)
              </label>
              <Input
                placeholder="Trading Desk, Hedge Fund, etc."
                value={department}
                onChange={(e) => setDepartment(e.target.value)}
                disabled={isProcessing}
                className="bg-white/5 border-white/10"
              />
            </div>

            {/* Issue Button */}
            <div className="pt-4">
              <Button
                onClick={handleStartIssuance}
                disabled={isProcessing || !subdomain || !agentAddress || !traderName}
                className="w-full text-lg py-6 glow-blue-sm hover-lift font-bold"
                size="lg"
              >
                <Shield className="mr-2 h-5 w-5" />
                {isProcessing ? 'Processing Transaction...' : 'Start Arc KYC Verification'}
              </Button>
            </div>

            {/* Transaction Link */}
            {hash && (
              <div className="glass rounded-lg p-4 border border-green-500/30">
                <div className="flex items-center gap-2 mb-2">
                  <FileText className="h-4 w-4 text-green-500" />
                  <span className="text-sm font-semibold text-green-500">Transaction Submitted</span>
                </div>
                <a
                  href={`https://sepolia.etherscan.io/tx/${hash}`}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-sm text-primary hover:underline mono-number"
                >
                  {hash.slice(0, 20)}...{hash.slice(-18)}
                </a>
              </div>
            )}
          </CardContent>
        </Card>
      </div>

      {/* Arc KYC Modal */}
      <ArcKYCModal
        isOpen={showKYCModal}
        onClose={() => setShowKYCModal(false)}
        onComplete={handleKYCComplete}
        userAddress={agentAddress}
      />
    </div>
  );
}
