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
    <div className="space-y-4">
      <Alert className="border-blue-200 bg-blue-50">
        <Info className="h-4 w-4 text-blue-600" />
        <AlertDescription className="text-blue-800">
          <strong>License Verified:</strong> Your trading license grants access to this Uniswap v4 pool. All swaps route through the PermitPoolHook for verification.
        </AlertDescription>
      </Alert>

      <div className="space-y-2">
        <label className="block text-sm font-medium">From</label>
        <div className="flex gap-2">
          <Input
            type="number"
            placeholder="0.0"
            value={fromAmount}
            onChange={(e) => setFromAmount(e.target.value)}
            className="flex-1"
          />
          <select
            value={fromToken}
            onChange={(e) => setFromToken(e.target.value as 'USDC' | 'WETH')}
            className="px-4 py-2 border rounded-md bg-white"
          >
            <option value="USDC">USDC</option>
            <option value="WETH">WETH</option>
          </select>
        </div>
        <p className="text-xs text-gray-500">
          Balance: 0.00 {fromToken}
        </p>
      </div>

      <button
        onClick={toggleTokens}
        className="mx-auto flex items-center justify-center w-10 h-10 rounded-full border-2 hover:bg-gray-50 transition-colors"
      >
        <ArrowDownUp className="h-4 w-4" />
      </button>

      <div className="space-y-2">
        <label className="block text-sm font-medium">To</label>
        <div className="flex gap-2">
          <Input
            type="number"
            placeholder="0.0"
            value={toAmount}
            onChange={(e) => setToAmount(e.target.value)}
            className="flex-1"
          />
          <select
            value={toToken}
            onChange={(e) => setToToken(e.target.value as 'USDC' | 'WETH')}
            className="px-4 py-2 border rounded-md bg-white"
          >
            <option value="USDC">USDC</option>
            <option value="WETH">WETH</option>
          </select>
        </div>
        <p className="text-xs text-gray-500">
          Balance: 0.00 {toToken}
        </p>
      </div>

      <div className="pt-4 space-y-2">
        <div className="flex justify-between text-sm">
          <span className="text-gray-600">Route:</span>
          <span>Uniswap v4 + PermitPoolHook</span>
        </div>
        
        <Button
          onClick={handleSwap}
          disabled={!fromAmount || !toAmount || fromToken === toToken}
          className="w-full"
        >
          Execute Swap (Demo)
        </Button>

        <p className="text-xs text-center text-gray-600">
          Demo mode - In production, this routes through Uniswap v4
        </p>
      </div>
    </div>
  );
}
