'use client';

import { useState } from 'react';
import { useENSLicenseCheck } from '@/hooks/useENSLicenseCheck';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { ArrowDownUp, Shield } from 'lucide-react';
import { TOKENS } from '@/lib/contracts/addresses';

interface SwapInterfaceProps {
  licenseNode: `0x${string}`;
}

export function SwapInterface(props: SwapInterfaceProps) {
  const { hasENS, ensName, isLicensed, message } = useENSLicenseCheck();
  const [fromAmount, setFromAmount] = useState('');
  const [toAmount, setToAmount] = useState('');
  const [fromToken, setFromToken] = useState<'USDC' | 'WETH'>('USDC');
  const [toToken, setToToken] = useState<'USDC' | 'WETH'>('WETH');
  const [isSwapping, setIsSwapping] = useState(false);
  const [swapStatus, setSwapStatus] = useState<string>('');

  const handleSwap = async () => {
    setIsSwapping(true);
    setSwapStatus('Preparing swap...');
    
    // Simulate swap (in production, call actual Uniswap contract)
    setTimeout(() => {
      setSwapStatus('Swap executed successfully!');
      setIsSwapping(false);
      setFromAmount('');
      setToAmount('');
    }, 2000);
  };

  const toggleTokens = () => {
    setFromToken(toToken);
    setToToken(fromToken);
    setFromAmount(toAmount);
    setToAmount(fromAmount);
  };

  return (
    <div className="space-y-4">
      {/* ENS License Badge */}
      {isLicensed && ensName && (
        <div className="bg-green-500/10 border border-green-500/30 rounded-lg p-3 flex items-center gap-2">
          <Shield className="h-5 w-5 text-green-500" />
          <div className="flex-1">
            <p className="text-sm font-medium text-green-400">Licensed Trader</p>
            <p className="text-xs text-gray-400">{ensName}</p>
          </div>
          <div className="w-2 h-2 rounded-full bg-green-500 animate-pulse" />
        </div>
      )}
      {!isLicensed && message && (
        <div className="bg-yellow-500/10 border border-yellow-500/30 rounded-lg p-3">
          <p className="text-sm text-yellow-400">{message}</p>
        </div>
      )}
      
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
            className="px-4 py-2 border rounded-md"
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
            className="px-4 py-2 border rounded-md"
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
          <span className="text-gray-600">Slippage Tolerance:</span>
          <span>0.5%</span>
        </div>
        
        {swapStatus && (
          <div className="text-sm text-center py-2 text-green-600">
            {swapStatus}
          </div>
        )}
        
        <Button
          onClick={handleSwap}
          disabled={!fromAmount || !toAmount || fromToken === toToken || isSwapping}
          className="w-full"
        >
          {isSwapping ? 'Swapping...' : 'Execute Swap'}
        </Button>
      </div>
    </div>
  );
}
