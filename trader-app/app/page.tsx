'use client';

import { useAccount, useReadContract } from 'wagmi';
import { useEffect, useState } from 'react';
import { CONTRACTS } from '@/lib/contracts/addresses';
import { LICENSE_MANAGER_ABI } from '@/lib/contracts/abis';
import { ConnectButton } from '@/components/ConnectButton';
import { Shield, CheckCircle2, AlertCircle, TrendingUp, Activity, BarChart3 } from 'lucide-react';
import Link from 'next/link';
import { Button } from '@/components/ui/button';

export default function TraderDashboard() {
  const { address, isConnected } = useAccount();
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  // CHECK: Does this wallet have a license from PermitPool?
  const { data: hasLicense, isLoading } = useReadContract({
    address: CONTRACTS.LICENSE_MANAGER,
    abi: LICENSE_MANAGER_ABI,
    functionName: 'hasValidLicense',
    args: address ? [address] : undefined,
    query: {
      enabled: isConnected && !!address,
    }
  });

  if (!mounted) return null;

  if (!isConnected) {
    return (
      <div className="min-h-screen flex flex-col items-center justify-center relative overflow-hidden">
        <div className="absolute inset-0 bg-grid-white/[0.02] -z-10" />
        <div className="max-w-xl text-center p-8 glass rounded-2xl border border-white/10 glow-blue">
          <h1 className="text-5xl font-bold mb-6 bg-clip-text text-transparent bg-gradient-to-r from-blue-400 to-purple-600">
            PermitPool Trading
          </h1>
          <p className="text-xl text-gray-400 mb-8">
            Connect your licensed wallet to access institutional DeFi pools.
          </p>
          <div className="flex justify-center">
            <ConnectButton />
          </div>
        </div>
      </div>
    );
  }

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="animate-spin h-8 w-8 border-4 border-blue-500 border-t-transparent rounded-full" />
        <span className="ml-3 text-lg font-medium">Verifying license...</span>
      </div>
    );
  }

  if (!hasLicense) {
    return (
      <div className="min-h-screen flex items-center justify-center p-4">
        <div className="max-w-md w-full glass p-8 rounded-2xl border border-red-500/30 shadow-lg shadow-red-500/10">
          <div className="flex flex-col items-center text-center">
            <div className="bg-red-500/10 p-4 rounded-full mb-6">
                <AlertCircle className="w-12 h-12 text-red-500" />
            </div>
            <h2 className="text-2xl font-bold text-white mb-2">No Trading License</h2>
            <p className="text-gray-400 mb-6">
              Wallet <span className="font-mono text-xs bg-black/50 p-1 rounded text-red-300">{address}</span> is not licensed.
            </p>
            <p className="text-sm text-gray-500 border-t border-white/10 pt-4 w-full">
              Contact your administrator to request access.
            </p>
          </div>
        </div>
      </div>
    );
  }

  // Licensed trader - show dashboard
  return (
    <div className="min-h-screen container mx-auto px-6 py-12 animate-fade-in">
      <header className="mb-12 flex flex-col md:flex-row justify-between items-start md:items-center gap-6">
        <div>
          <h1 className="text-4xl font-bold mb-2">Welcome, Trader</h1>
          <p className="text-gray-400">Institutional Access Granted</p>
        </div>
        
        <div className="glass px-6 py-3 rounded-full border border-green-500/30 flex items-center gap-3 bg-green-500/5">
          <Shield className="w-5 h-5 text-green-500" />
          <span className="font-semibold text-green-400">License Active</span>
          <div className="w-2 h-2 rounded-full bg-green-500 animate-pulse" />
        </div>
      </header>

      {/* Dashboard Grid */}
      <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6 mb-12">
        {/* Market Access Card */}
        <div className="glass p-6 rounded-xl border border-white/10 hover:border-blue-500/50 transition-colors group">
            <div className="bg-blue-500/10 p-3 rounded-lg w-fit mb-4 group-hover:bg-blue-500/20 transition-colors">
                <TrendingUp className="w-6 h-6 text-blue-400" />
            </div>
            <h3 className="text-xl font-bold mb-2">Uniswap v4 Pools</h3>
            <p className="text-gray-400 text-sm mb-4">Access permissioned liquidity pools with institutional compliance.</p>
            <Link href="/trade">
                <Button className="w-full">Trade Now</Button>
            </Link>
        </div>

        {/* Portfolio Card */}
        <div className="glass p-6 rounded-xl border border-white/10 hover:border-purple-500/50 transition-colors group">
            <div className="bg-purple-500/10 p-3 rounded-lg w-fit mb-4 group-hover:bg-purple-500/20 transition-colors">
                <BarChart3 className="w-6 h-6 text-purple-400" />
            </div>
            <h3 className="text-xl font-bold mb-2">Portfolio</h3>
            <p className="text-gray-400 text-sm mb-4">View your positions, performance metrics, and history.</p>
            <Link href="/dashboard/portfolio">
                <Button variant="secondary" className="w-full">View Portfolio</Button>
            </Link>
        </div>

        {/* Activity Card */}
        <div className="glass p-6 rounded-xl border border-white/10 hover:border-orange-500/50 transition-colors group">
            <div className="bg-orange-500/10 p-3 rounded-lg w-fit mb-4 group-hover:bg-orange-500/20 transition-colors">
                <Activity className="w-6 h-6 text-orange-400" />
            </div>
            <h3 className="text-xl font-bold mb-2">Compliance Log</h3>
            <p className="text-gray-400 text-sm mb-4">Your trading activity is automatically recorded for audit.</p>
            <Link href="/dashboard/transactions">
                <Button variant="outline" className="w-full">View Logs</Button>
            </Link>
        </div>
      </div>
      
      <div className="glass rounded-xl p-8 border border-white/10">
          <div className="flex items-center gap-3 mb-6">
              <CheckCircle2 className="w-6 h-6 text-green-500" />
              <h2 className="text-2xl font-bold">Verification Status</h2>
          </div>
          <div className="grid md:grid-cols-2 gap-8">
              <div>
                  <h4 className="font-semibold text-gray-300 mb-2">ENS License</h4>
                  <div className="flex items-center gap-2 text-green-400 bg-green-950/30 p-3 rounded-lg border border-green-500/20">
                      <span className="font-mono text-sm">Valid (Soulbound)</span>
                  </div>
              </div>
              <div>
                  <h4 className="font-semibold text-gray-300 mb-2">Arc Identity</h4>
                  <div className="flex items-center gap-2 text-green-400 bg-green-950/30 p-3 rounded-lg border border-green-500/20">
                      <span className="font-mono text-sm">Verified (DID)</span>
                  </div>
              </div>
          </div>
      </div>
    </div>
  );
}
