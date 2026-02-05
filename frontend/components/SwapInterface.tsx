'use client';

import { useState, useCallback, memo } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { ArrowDownUp } from 'lucide-react';
import { TOKENS } from '@/lib/contracts/addresses';

interface SwapInterfaceProps {
  licenseNode: `0x${string}`;
}

const SwapInterfaceComponent = memo(function SwapInterface(props: SwapInterfaceProps) {
  const [fromAmount, setFromAmount] = useState('');
  const [toAmount, setToAmount] = useState('');
  const [fromToken, setFromToken] = useState<'USDC' | 'WETH'>('USDC');
  const [toToken, setToToken] = useState<'USDC' | 'WETH'>('WETH');
  const [isSwapping, setIsSwapping] = useState(false);
  const [swapStatus, setSwapStatus] = useState<string>('');

  const handleSwap = useCallback(async () => {
    setIsSwapping(true);
    setSwapStatus('Preparing swap...');
    
    // Simulate swap (in production, call actual Uniswap contract)
    setTimeout(() => {
      setSwapStatus('Swap executed successfully!');
      setIsSwapping(false);
      setFromAmount('');
      setToAmount('');
    }, 2000);
  }, []);

  const handleFromAmountChange = useCallback((e: React.ChangeEvent<HTMLInputElement>) => {
    setFromAmount(e.target.value);
  }, []);

  const handleToAmountChange = useCallback((e: React.ChangeEvent<HTMLInputElement>) => {
    setToAmount(e.target.value);
  }, []);

  const handleFromTokenChange = useCallback((e: React.ChangeEvent<HTMLSelectElement>) => {
    setFromToken(e.target.value as 'USDC' | 'WETH');
  }, []);

  const handleToTokenChange = useCallback((e: React.ChangeEvent<HTMLSelectElement>) => {
    setToToken(e.target.value as 'USDC' | 'WETH');
  }, []);

  const toggleTokens = useCallback(() => {
    setFromToken(toToken);
    setToToken(fromToken);
    setFromAmount(toAmount);
    setToAmount(fromAmount);
  }, [fromToken, toToken, fromAmount, toAmount]);

  return (
    <div className="space-y-4">
      <div className="space-y-2">
        <label className="block text-sm font-medium">From</label>
        <div className="flex gap-2">
          <Input
            type="number"
            placeholder="0.0"
            value={fromAmount}
            onChange={handleFromAmountChange}
            className="flex-1"
          />
          <select
            value={fromToken}
            onChange={handleFromTokenChange}
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
            onChange={handleToAmountChange}
            className="flex-1"
          />
          <select
            value={toToken}
            onChange={handleToTokenChange}
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
});

export const SwapInterface = SwapInterfaceComponent;
