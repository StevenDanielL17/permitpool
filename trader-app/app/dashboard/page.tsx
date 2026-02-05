'use client';

import { useAccount, useReadContract } from 'wagmi';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { TrendingUp, TrendingDown, Activity, DollarSign, CheckCircle2, Clock, ArrowRight } from 'lucide-react';
import Link from 'next/link';
import { CONTRACTS } from '@/lib/contracts/addresses';
import { HOOK_ABI } from '@/lib/contracts/abis';

export default function TraderDashboard() {
  const { address, isConnected } = useAccount();

  // Fetch license status - optimized with 60s stale time
  const { data: licenseNode } = useReadContract({
    address: CONTRACTS.HOOK,
    abi: HOOK_ABI,
    functionName: 'getENSNodeForAddress',
    args: address ? [address] : undefined,
    query: {
      enabled: !!address,
      staleTime: 60000, // 60s - maintain low latency
      gcTime: 300000, // 5min cache
      retry: 1,
    },
  });

  // Mock data - in production, fetch from blockchain/indexer
  const portfolioData = {
    totalValue: 125430.50,
    todayPnL: 2340.25,
    todayPnLPercent: 1.9,
    openPositions: 5,
    daysRemaining: 23,
    nextPaymentDate: '2026-03-01',
    paymentAmount: 50,
  };

  const recentTrades = [
    { id: 1, pair: 'USDC → WETH', amount: '$5,200', time: '2 hours ago', profit: '+$120' },
    { id: 2, pair: 'WETH → USDC', amount: '$3,800', time: '5 hours ago', profit: '+$85' },
    { id: 3, pair: 'USDC → WETH', amount: '$8,500', time: '1 day ago', profit: '+$210' },
    { id: 4, pair: 'WETH → USDC', amount: '$4,200', time: '1 day ago', profit: '-$45' },
    { id: 5, pair: 'USDC → WETH', amount: '$6,700', time: '2 days ago', profit: '+$155' },
  ];

  if (!isConnected) {
    return (
      <div className="container mx-auto p-8 text-center animate-fade-in">
        <div className="max-w-2xl mx-auto py-20">
          <h1 className="text-5xl font-bold mb-6">Dashboard</h1>
          <p className="text-xl text-gray-400 mb-8">Connect your wallet to view your trading dashboard</p>
        </div>
      </div>
    );
  }

  const hasLicense = licenseNode && licenseNode !== '0x0000000000000000000000000000000000000000000000000000000000000000';

  return (
    <div className="container mx-auto p-8 animate-fade-in">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-5xl font-bold mb-3">Dashboard</h1>
        <p className="text-gray-400">Your institutional trading overview</p>
      </div>

      {/* License Status Banner */}
      {hasLicense ? (
        <div className="mb-6 glass rounded-xl p-6 border border-green-500/30 glow-blue-sm">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <CheckCircle2 className="h-6 w-6 text-green-500" />
              <div>
                <span className="font-bold text-green-500">License Active</span>
                <p className="text-sm text-gray-400 mt-1">
                  {portfolioData.daysRemaining} days remaining until renewal
                </p>
              </div>
            </div>
            <Link href="/license">
              <Button variant="outline" size="sm">
                View Details
              </Button>
            </Link>
          </div>
        </div>
      ) : (
        <div className="mb-6 glass rounded-xl p-6 border border-red-500/30">
          <div className="flex items-center gap-3">
            <Clock className="h-6 w-6 text-red-500" />
            <div>
              <span className="font-bold text-red-500">No Active License</span>
              <p className="text-sm text-gray-400 mt-1">
                Contact your administrator to request trading access
              </p>
            </div>
          </div>
        </div>
      )}

      {/* Metrics Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        {/* Portfolio Value */}
        <Card className="glass border-dashed-sui hover-lift transform-gpu">
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-gray-400">Portfolio Value</CardTitle>
            <DollarSign className="h-5 w-5 text-primary" />
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold mono-number">
              ${portfolioData.totalValue.toLocaleString()}
            </div>
            <p className="text-xs text-gray-500 mt-1">Total assets</p>
          </CardContent>
        </Card>

        {/* Today's P&L */}
        <Card className="glass border-dashed-sui hover-lift transform-gpu">
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-gray-400">Today's P&L</CardTitle>
            {portfolioData.todayPnLPercent > 0 ? (
              <TrendingUp className="h-5 w-5 text-green-500" />
            ) : (
              <TrendingDown className="h-5 w-5 text-red-500" />
            )}
          </CardHeader>
          <CardContent>
            <div className={`text-3xl font-bold mono-number ${portfolioData.todayPnLPercent > 0 ? 'text-green-500' : 'text-red-500'}`}>
              {portfolioData.todayPnLPercent > 0 ? '+' : ''}${portfolioData.todayPnL.toLocaleString()}
            </div>
            <p className="text-xs text-gray-500 mt-1">
              {portfolioData.todayPnLPercent > 0 ? '+' : ''}{portfolioData.todayPnLPercent}%
            </p>
          </CardContent>
        </Card>

        {/* Open Positions */}
        <Card className="glass border-dashed-sui hover-lift transform-gpu">
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-gray-400">Open Positions</CardTitle>
            <Activity className="h-5 w-5 text-primary" />
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold mono-number">{portfolioData.openPositions}</div>
            <p className="text-xs text-gray-500 mt-1">Active holdings</p>
          </CardContent>
        </Card>

        {/* Next Payment */}
        <Card className="glass border-dashed-sui hover-lift transform-gpu">
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-gray-400">Next Payment</CardTitle>
            <Clock className="h-5 w-5 text-yellow-500" />
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold mono-number">${portfolioData.paymentAmount}</div>
            <p className="text-xs text-gray-500 mt-1">{portfolioData.nextPaymentDate}</p>
          </CardContent>
        </Card>
      </div>

      {/* Quick Actions & Recent Trades */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Quick Actions */}
        <Card className="glass border-dashed-sui">
          <CardHeader>
            <CardTitle className="text-xl">Quick Actions</CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            <Link href="/trade">
              <Button className="w-full glow-blue-sm hover-lift" size="lg" disabled={!hasLicense}>
                <Activity className="mr-2 h-5 w-5" />
                Trade Now
              </Button>
            </Link>
            <Link href="/portfolio">
              <Button variant="outline" className="w-full" size="lg">
                <DollarSign className="mr-2 h-5 w-5" />
                View Portfolio
              </Button>
            </Link>
            <Link href="/transactions">
              <Button variant="outline" className="w-full" size="lg">
                <Activity className="mr-2 h-5 w-5" />
                Transaction History
              </Button>
            </Link>
            <Link href="/payment">
              <Button variant="outline" className="w-full" size="lg">
                <Clock className="mr-2 h-5 w-5" />
                Payment Status
              </Button>
            </Link>
          </CardContent>
        </Card>

        {/* Recent Trades */}
        <Card className="lg:col-span-2 glass border-dashed-sui">
          <CardHeader className="flex flex-row items-center justify-between">
            <div>
              <CardTitle className="text-xl">Recent Trades</CardTitle>
              <p className="text-sm text-gray-400 mt-1">Your last 5 transactions</p>
            </div>
            <Link href="/transactions">
              <Button variant="ghost" size="sm" className="gap-1">
                View All
                <ArrowRight className="h-4 w-4" />
              </Button>
            </Link>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {recentTrades.map((trade) => (
                <div
                  key={trade.id}
                  className="flex items-center justify-between p-3 rounded-lg hover:bg-white/5 transition-smooth"
                >
                  <div className="flex items-center gap-3">
                    <Activity className="h-4 w-4 text-primary" />
                    <div>
                      <p className="text-sm font-medium">{trade.pair}</p>
                      <p className="text-xs text-gray-500">{trade.time}</p>
                    </div>
                  </div>
                  <div className="text-right">
                    <p className="text-sm font-medium mono-number">{trade.amount}</p>
                    <p className={`text-xs mono-number ${trade.profit.startsWith('+') ? 'text-green-500' : 'text-red-500'}`}>
                      {trade.profit}
                    </p>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
