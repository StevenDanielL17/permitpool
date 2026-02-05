'use client';

import { useState, useCallback } from 'react';
import { useAccount } from 'wagmi';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { ArrowDownUp, Info } from 'lucide-react';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { TOKENS } from '@/lib/contracts/addresses';

interface SwapInterfaceProps {
  licenseNode: `0x${string}`;
}

export function SwapInterface({ licenseNode }: SwapInterfaceProps) {
  const { address, isConnected } = useAccount();
  const [fromAmount, setFromAmount] = useState('');
  const [toAmount, setToAmount] = useState('');
  const [fromToken, setFromToken] = useState<'USDC' | 'WETH'>('USDC');
  const [toToken, setToToken] = useState<'USDC' | 'WETH'>('WETH');

  const toggleTokens = () => {
    setFromToken(toToken);
    setToToken(fromToken);
    setFromAmount(toAmount);
    setToAmount(fromAmount);
  };

  const handleSwap = useCallback(() => {
    if (!isConnected) {
      alert('Please connect your wallet');
      return;
    }

    if (!fromAmount || !toAmount) {
      alert('Please enter amounts');
      return;
    }

    if (fromToken === toToken) {
      alert('Please select different tokens');
      return;
    }

    // In production: Route through Uniswap v4
    // The PermitPoolHook validates licenses on every swap
    console.log('Swap request:', {
      from: fromAmount,
      fromToken,
      to: toAmount,
      toToken,
      licenseNode,
      userAddress: address,
    });

    alert(`Swap ready to route through Uniswap v4 with your license\n\nFrom: ${fromAmount} ${fromToken}\nTo: ${toAmount} ${toToken}`);
  }, [isConnected, fromAmount, toAmount, fromToken, toToken, address, licenseNode]);

  return (
    <div className="space-y-6">
      {/* Info Alert */}
      <div className="glass rounded-xl p-4 border border-primary/30">
        <div className="flex items-start gap-3">
          <Info className="h-5 w-5 text-primary flex-shrink-0 mt-0.5" />
          <p className="text-sm text-gray-300">
            <strong className="text-primary">License Verified:</strong> Your trading license grants access to this Uniswap v4 pool. All swaps route through the PermitPoolHook for verification.
          </p>
        </div>
      </div>

      {/* From Token */}
      <div className="space-y-3">
        <label className="block text-sm font-semibold text-gray-400 uppercase tracking-wide">From</label>
        <div className="glass rounded-xl p-4 border border-white/10 hover:border-primary/50 transition-smooth">
          <div className="flex gap-3">
            <Input
              type="number"
              placeholder="0.0"
              value={fromAmount}
              onChange={(e) => setFromAmount(e.target.value)}
              className="flex-1 bg-transparent border-none text-3xl font-bold focus-visible:ring-0 focus-visible:ring-offset-0 p-0"
            />
            <select
              value={fromToken}
              onChange={(e) => setFromToken(e.target.value as 'USDC' | 'WETH')}
              className="px-4 py-2 bg-white/5 border border-white/10 rounded-lg text-white font-semibold hover:bg-white/10 transition-smooth cursor-pointer"
            >
              <option value="USDC">USDC</option>
              <option value="WETH">WETH</option>
            </select>
          </div>
          <p className="text-xs text-gray-500 mt-3 mono-number">
            Balance: 0.00 {fromToken}
          </p>
        </div>
      </div>

      {/* Swap Button */}
      <div className="flex justify-center -my-2">
        <button
          onClick={toggleTokens}
          className="p-3 glass rounded-full border border-white/10 hover:border-primary/50 hover:glow-blue-sm transition-smooth hover-lift"
        >
          <ArrowDownUp className="h-5 w-5 text-primary" />
        </button>
      </div>

      {/* To Token */}
      <div className="space-y-3">
        <label className="block text-sm font-semibold text-gray-400 uppercase tracking-wide">To</label>
        <div className="glass rounded-xl p-4 border border-white/10 hover:border-primary/50 transition-smooth">
          <div className="flex gap-3">
            <Input
              type="number"
              placeholder="0.0"
              value={toAmount}
              onChange={(e) => setToAmount(e.target.value)}
              className="flex-1 bg-transparent border-none text-3xl font-bold focus-visible:ring-0 focus-visible:ring-offset-0 p-0"
            />
            <select
              value={toToken}
              onChange={(e) => setToToken(e.target.value as 'USDC' | 'WETH')}
              className="px-4 py-2 bg-white/5 border border-white/10 rounded-lg text-white font-semibold hover:bg-white/10 transition-smooth cursor-pointer"
            >
              <option value="USDC">USDC</option>
              <option value="WETH">WETH</option>
            </select>
          </div>
          <p className="text-xs text-gray-500 mt-3 mono-number">
            Balance: 0.00 {toToken}
          </p>
        </div>
      </div>

      {/* Route Info */}
      <div className="flex justify-between text-sm pt-2">
        <span className="text-gray-500">Route:</span>
        <span className="text-gray-300 font-medium">Uniswap v4 + PermitPoolHook</span>
      </div>
      
      {/* Execute Button */}
      <Button
        onClick={handleSwap}
        disabled={!fromAmount || !toAmount || fromToken === toToken}
        className="w-full text-lg py-6 glow-blue-sm hover-lift font-bold"
        size="lg"
      >
        Execute Swap (Demo)
      </Button>

      <p className="text-xs text-center text-gray-600 mono-number">
        Demo mode - In production, this routes through Uniswap v4
      </p>
    </div>
  );
}
