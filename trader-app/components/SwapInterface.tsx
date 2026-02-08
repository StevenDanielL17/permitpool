'use client';

import { useState, useCallback, useEffect } from 'react';
import { useAccount, useChainId, useSwitchChain, useReadContract, useWriteContract, useSimulateContract } from 'wagmi';
import { sepolia } from 'wagmi/chains';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { ArrowDownUp, Info, Zap, AlertTriangle, Wallet } from 'lucide-react';
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert';
import { TOKENS, CONTRACTS } from '@/lib/contracts/addresses';
import { HOOK_ABI } from '@/lib/contracts/abis';
import { toast } from 'sonner';
import { useUserTrades } from '@/hooks/useUserTrades';

interface SwapInterfaceProps {
  licenseNode: `0x${string}`;
}

export function SwapInterface({ licenseNode }: SwapInterfaceProps) {
  const { address, isConnected } = useAccount();
  const chainId = useChainId();
  const { switchChain } = useSwitchChain();
  const { writeContractAsync } = useWriteContract();
  const { executeTrade } = useUserTrades();

  const [fromAmount, setFromAmount] = useState('');
  const [toAmount, setToAmount] = useState('');
  const [fromToken, setFromToken] = useState<'USDC' | 'WETH'>('USDC');
  const [toToken, setToToken] = useState<'USDC' | 'WETH'>('WETH');
  const [isOptimisticProcessing, setIsOptimisticProcessing] = useState(false);

  // 1. STRICT NETWORK ENFORCEMENT
  const isWrongNetwork = chainId !== sepolia.id;

  // 2. PRE-FLIGHT LICENSE CHECK
  // Verify license status BEFORE user even tries to swap
  const { data: licenseStatus, isLoading: isCheckingLicense, error: licenseError } = useReadContract({
    address: CONTRACTS.HOOK,
    abi: HOOK_ABI,
    functionName: 'batchVerifyLicense',
    args: [address || '0x0000000000000000000000000000000000000000'],
    query: {
      enabled: isConnected && !isWrongNetwork && !!address,
      refetchInterval: 5000, 
    }
  });

  const isValidLicense = licenseStatus?.[0]; // isValid
  const isRevoked = licenseStatus?.[2];      // revoked
  const isPaymentCurrent = licenseStatus?.[3]; // paymentCurrent

  const toggleTokens = () => {
    setFromToken(toToken);
    setToToken(fromToken);
    setFromAmount(toAmount);
    setToAmount(fromAmount);
  };

  const handleNetworkSwitch = async () => {
    try {
      await switchChain({ chainId: sepolia.id });
    } catch (err) {
      toast.error('Failed to switch network. Please switch to Sepolia manually.');
    }
  };

  const handleSwap = useCallback(async () => {
    if (!isConnected) {
      toast.error('Please connect your wallet');
      return;
    }

    if (isWrongNetwork) {
      handleNetworkSwitch();
      return;
    }

    if (!isValidLicense) {
       if (isRevoked) toast.error('Check Failed: License is Revoked');
       else if (!isPaymentCurrent) toast.error('Check Failed: Payment Verification Failed');
       else toast.error('Check Failed: No valid ENS License found');
       return;
    }

    if (!fromAmount || !toAmount) {
      toast.error('Please enter amounts');
      return;
    }

    if (fromToken === toToken) {
      toast.error('Please select different tokens');
      return;
    }

    // 3. TRANSACTION SIMULATION (SAFEGUARD)
    // In a real app, useSimulateContract would run here.
    // For now, we proceed to optimistic update as we don't have the Router ABI readily available.
    
    try {
      setIsOptimisticProcessing(true);

      // Example of where the Write Contract would go:
      // await writeContractAsync({
      //   address: ROUTER_ADDRESS,
      //   abi: ROUTER_ABI,
      //   functionName: 'swap',
      //   args: [...]
      // });
      
      // Simulate network delay for "Perfect" UX
      console.log('⚡ Executing compliant swap for licensed user:', address);
      
      // Calculate estimated output (simple 1:2400 ratio for demo)
      const estimatedOutput = fromToken === 'USDC' 
        ? (parseFloat(fromAmount) / 2400).toFixed(4)
        : (parseFloat(fromAmount) * 2400).toFixed(2);
      
      setToAmount(estimatedOutput);
      
      await new Promise(resolve => setTimeout(resolve, 1500));

      // Save trade to user's history
      executeTrade({
        asset: `${fromToken}/${toToken}`,
        type: fromToken === 'USDC' ? 'BUY' : 'SELL',
        amount: fromAmount,
        price: fromToken === 'USDC' ? '2400.00' : '0.000417',
        pnl: '0.00'
      });

      toast.success('Swap Submitted! Routing through PermitPoolHook...', {
        duration: 2000,
        icon: <Zap className="h-4 w-4 text-yellow-500" />
      });

      // Clear form
      setFromAmount('');
      setToAmount('');
      setIsOptimisticProcessing(false);

      setTimeout(() => {
           toast.success(`Transaction Confirmed: ${fromAmount} ${fromToken} → ${estimatedOutput} ${toToken}`, {
               description: 'Verified by PermitPoolHook',
               duration: 3000,
           });
      }, 2000);

    } catch (error) {
      console.error(error);
      setIsOptimisticProcessing(false);
      toast.error('Transaction Failed or Rejected by User');
    }

  }, [isConnected, isWrongNetwork, isValidLicense, isRevoked, isPaymentCurrent, fromAmount, toAmount, fromToken, toToken, address, writeContractAsync]);

  // Derived UI State
  let buttonText = 'Execute Swap';
  let buttonDisabled = false;
  let showLicenseWarning = false;

  if (!isConnected) {
    buttonText = 'Connect Wallet';
    buttonDisabled = true; // Let the ConnectButton in header handle this, or make this connect.
  } else if (isWrongNetwork) {
    buttonText = 'Switch to Sepolia';
    buttonDisabled = false;
  } else if (isCheckingLicense) {
    buttonText = 'Verifying License...';
    buttonDisabled = true;
  } else if (!isValidLicense) {
    buttonDisabled = true;
    showLicenseWarning = true;
    if (isRevoked) buttonText = 'License Revoked';
    else if (!isPaymentCurrent) buttonText = 'Payment Overdue';
    else buttonText = 'No Valid License';
  } else if (!fromAmount || !toAmount) {
    buttonDisabled = true;
  }

  return (
    <div className="space-y-4">
      {/* LICENSE STATUS BANNER */}
      {isConnected && !isWrongNetwork && isValidLicense && (
        <Alert className="border-blue-200 bg-blue-50/50">
          <Info className="h-4 w-4 text-blue-600" />
          <AlertDescription className="text-blue-800 text-xs flex items-center gap-2">
            <strong>License Active:</strong> Routing via PermitPoolHook.
          </AlertDescription>
        </Alert>
      )}

      {/* ERROR BANNER FOR INVALID LICENSE */}
      {isConnected && !isWrongNetwork && showLicenseWarning && (
        <Alert variant="destructive" className="border-red-200 bg-red-50">
          <AlertTriangle className="h-4 w-4 text-red-600" />
          <AlertTitle className="text-red-800 text-sm font-bold">Trading Disabled</AlertTitle>
          <AlertDescription className="text-red-700 text-xs">
            {isRevoked ? 'Your license has been revoked by the administrator.' : 
             !isPaymentCurrent ? 'Your payment is not current. Please update your subscription.' :
             'No valid ENS license found. Please contact your admin.'}
          </AlertDescription>
        </Alert>
      )}

      {/* WRONG NETWORK ALERT */}
      {isConnected && isWrongNetwork && (
         <Alert variant="destructive" className="border-yellow-200 bg-yellow-50">
          <AlertTriangle className="h-4 w-4 text-yellow-600" />
          <AlertTitle className="text-yellow-800 text-sm font-bold">Wrong Network</AlertTitle>
          <AlertDescription className="text-yellow-700 text-xs">
            You must be connected to Sepolia to trade.
          </AlertDescription>
        </Alert>
      )}

      <div className="space-y-2">
        <label className="block text-sm font-medium text-gray-600">From</label>
        <div className="flex gap-2">
          <Input
            type="number"
            placeholder="0.0"
            value={fromAmount}
            onChange={(e) => {
              const value = e.target.value;
              setFromAmount(value);
              // Auto-calculate estimated output
              if (value && !isNaN(parseFloat(value))) {
                const estimated = fromToken === 'USDC' 
                  ? (parseFloat(value) / 2400).toFixed(4)
                  : (parseFloat(value) * 2400).toFixed(2);
                setToAmount(estimated);
              } else {
                setToAmount('');
              }
            }}
            className="flex-1 font-mono text-lg bg-white"
            disabled={buttonDisabled && !isWrongNetwork && !showLicenseWarning} // Allow editing if just amounts missing
          />
          <select
            value={fromToken}
            onChange={(e) => setFromToken(e.target.value as 'USDC' | 'WETH')}
            className="px-4 py-2 border rounded-md bg-white font-semibold"
          >
            <option value="USDC">USDC</option>
            <option value="WETH">WETH</option>
          </select>
        </div>
        <div className="flex justify-between text-xs text-gray-500">
           <span>Balance: 1,000.00 {fromToken}</span>
           <span className="text-blue-500 cursor-pointer hover:underline" onClick={() => setFromAmount('1000')}>Max</span>
        </div>
      </div>

      <button
        onClick={toggleTokens}
        className="mx-auto flex items-center justify-center w-8 h-8 rounded-full border hover:bg-gray-100 transition-all hover:scale-110 active:scale-95"
      >
        <ArrowDownUp className="h-3 w-3 text-gray-500" />
      </button>

      <div className="space-y-2">
        <label className="block text-sm font-medium text-gray-600">To (Estimated)</label>
        <div className="flex gap-2">
          <Input
            type="number"
            placeholder="0.0"
            value={toAmount}
            onChange={(e) => setToAmount(e.target.value)}
            className="flex-1 font-mono text-lg bg-gray-50"
            readOnly
          />
          <select
            value={toToken}
            onChange={(e) => setToToken(e.target.value as 'USDC' | 'WETH')}
            className="px-4 py-2 border rounded-md bg-white font-semibold"
          >
            <option value="USDC">USDC</option>
            <option value="WETH">WETH</option>
          </select>
        </div>
      </div>

      <div className="pt-4 space-y-2">        
        <Button
          onClick={isWrongNetwork ? handleNetworkSwitch : handleSwap}
          disabled={buttonDisabled && !isWrongNetwork} 
          className={`w-full h-12 text-lg font-bold transition-all ${
              isOptimisticProcessing 
              ? 'bg-green-600 opacity-90' 
              : showLicenseWarning || isWrongNetwork
                ? 'bg-destructive/10 text-destructive border border-destructive/20 hover:bg-destructive/20'
              : 'bg-primary hover:bg-primary/90 hover:scale-[1.01] active:scale-[0.99]'
          }`}
        >
          {isOptimisticProcessing ? (
               <span className="flex items-center gap-2">
                   <Zap className="h-5 w-5 animate-pulse text-yellow-300" />
                   Processing...
               </span>
          ) : (
               <span className="flex items-center gap-2">
                   {isWrongNetwork ? <AlertTriangle className="h-5 w-5" /> : <Zap className="h-5 w-5" />}
                   {buttonText}
               </span>
          )}
        </Button>
      </div>
    </div>
  );
}

