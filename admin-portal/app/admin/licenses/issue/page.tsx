'use client';

import { useState } from 'react';
import { useWriteContract, useWaitForTransactionReceipt } from 'wagmi';
import { ArcKYCModal } from '@/components/ArcKYCModal';
import { toast } from 'sonner';
import { CONTRACTS } from '@/lib/contracts/addresses';
import { LICENSE_MANAGER_ABI } from '@/lib/contracts/abis';
import { ArrowLeft } from 'lucide-react';
import Link from 'next/link';

export default function IssueLicense() {
  const [traderAddress, setTraderAddress] = useState('');
  const [subdomain, setSubdomain] = useState('');
  const [showKYC, setShowKYC] = useState(false);
  const [arcCredential, setArcCredential] = useState('');

  const { writeContract, data: hash } = useWriteContract();
  const { isSuccess } = useWaitForTransactionReceipt({ hash });

  // Step 1: Admin clicks "Start KYC"
  const handleStartKYC = () => {
    if (!traderAddress || !subdomain) {
      toast.error('Fill all fields');
      return;
    }
    setShowKYC(true);
  };

  // Step 2: Arc verification completes
  const handleKYCComplete = (credential: string) => {
    setArcCredential(credential);
    setShowKYC(false);
    toast.success('KYC verified! Review and issue license.');
  };

  // Step 3: Admin signs transaction in MetaMask
  const handleIssueLicense = async () => {
    if (!arcCredential) {
      toast.error('Complete KYC first');
      return;
    }

    try {
      // PERMITPOOL ISSUES LICENSE (on-chain, permanent)
      writeContract({
        address: CONTRACTS.LICENSE_MANAGER,
        abi: LICENSE_MANAGER_ABI,
        functionName: 'issueLicense',
        args: [
          traderAddress as `0x${string}`,
          subdomain,
          arcCredential
        ]
      });

      toast.success('License issuance transaction submitted!');
    } catch (error) {
      console.error(error);
      toast.error('Transaction failed');
    }
  };

  if (isSuccess) {
    toast.success('✅ LICENSE ISSUED ON-CHAIN!');
    // No auto-reset here to let admin see confirmation, but can clear manually or via useEffect
  }

  return (
    <div className="container mx-auto p-8">
      <div className="mb-6">
          <Link href="/admin" className="text-sm text-gray-500 hover:text-white flex items-center gap-1">
            <ArrowLeft className="w-4 h-4" /> Back to Dashboard
          </Link>
      </div>

      <h1 className="text-4xl font-bold mb-8">Issue Trading License</h1>

      <div className="space-y-6 max-w-2xl glass p-8 rounded-xl border border-white/10">
        <div>
          <label className="block text-sm font-medium mb-2">Trader Wallet Address</label>
          <input
            className="w-full bg-black/50 border border-white/20 rounded-lg p-3 focus:ring-2 focus:ring-blue-500 outline-none"
            value={traderAddress}
            onChange={(e) => setTraderAddress(e.target.value)}
            placeholder="0x..."
          />
        </div>

        <div>
          <label className="block text-sm font-medium mb-2">Subdomain</label>
          <div className="flex items-center gap-2">
            <input
              className="flex-1 bg-black/50 border border-white/20 rounded-lg p-3 focus:ring-2 focus:ring-blue-500 outline-none"
              value={subdomain}
              onChange={(e) => setSubdomain(e.target.value)}
              placeholder="alice"
            />
            <span className="text-gray-500">.myhedgefund.eth</span>
          </div>
          <p className="text-sm text-gray-500 mt-2">
            Will create: <span className="text-blue-400">{subdomain || 'alice'}.myhedgefund.eth</span>
          </p>
        </div>

        <div className="pt-4">
            {!arcCredential ? (
            <button 
                onClick={handleStartKYC} 
                className="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 px-4 rounded-lg transition-colors flex items-center justify-center gap-2"
            >
                Start KYC Verification
            </button>
            ) : (
            <div className="space-y-4">
                <div className="bg-green-500/10 border border-green-500/30 p-4 rounded-lg flex items-center gap-2">
                    <span className="text-green-500">✅ KYC Verified</span>
                    <span className="text-xs text-gray-400 truncate flex-1">{arcCredential}</span>
                </div>
                <button 
                    onClick={handleIssueLicense} 
                    className="w-full bg-green-600 hover:bg-green-700 text-white font-bold py-3 px-4 rounded-lg transition-colors flex items-center justify-center gap-2"
                >
                Issue License (Sign in MetaMask)
                </button>
            </div>
            )}
        </div>
      </div>

      <ArcKYCModal
        isOpen={showKYC}
        onClose={() => setShowKYC(false)}
        onComplete={handleKYCComplete}
        userAddress={traderAddress}
      />
    </div>
  );
}
