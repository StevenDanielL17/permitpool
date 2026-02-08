'use client';

import { useState, useMemo } from 'react';
import { useAccount } from 'wagmi';
import { useUserTrades } from '@/hooks/useUserTrades';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { TrendingUp, TrendingDown, DollarSign, AlertCircle } from 'lucide-react';
import { ConnectButton } from '@rainbow-me/rainbowkit';
import { EmptyStateGuide } from '@/components/dashboard/EmptyStateGuide';

type TimeRange = '7d' | '30d' | '90d';

export default function PortfolioPage() {
  const [timeRange, setTimeRange] = useState<TimeRange>('30d');
  const { isConnected } = useAccount();
  const { trades, stats, loading } = useUserTrades();

  // Calculate real portfolio data from trades
  const portfolioData = useMemo(() => {
    const totalVolume = parseFloat(stats.totalVolume);
    const totalPnL = parseFloat(stats.totalPnL);
    const pnlPercent = totalVolume > 0 ? ((totalPnL / totalVolume) * 100).toFixed(2) : '0.00';

    // Group trades by asset to calculate holdings
    const assetHoldings = trades
      .filter(t => t.status === 'OPEN')
      .reduce((acc, trade) => {
        const asset = trade.asset.split('/')[0]; // Get base asset from pair like "ETH/USDC"
        if (!acc[asset]) {
          acc[asset] = {
            token: asset,
            balance: 0,
            value: 0,
            trades: 0,
          };
        }
        
        const amount = parseFloat(trade.amount);
        const price = parseFloat(trade.price);
        
        if (trade.type === 'BUY') {
          acc[asset].balance += amount;
          acc[asset].value += amount * price;
        } else {
          acc[asset].balance -= amount;
          acc[asset].value -= amount * price;
        }
        acc[asset].trades += 1;
        
        return acc;
      }, {} as Record<string, { token: string; balance: number; value: number; trades: number; }>);

    const holdings = Object.values(assetHoldings).filter(h => h.balance > 0);
    const totalValue = holdings.reduce((sum, h) => sum + h.value, 0);

    return {
      totalValue,
      totalVolume,
      totalPnL,
      pnlPercent: parseFloat(pnlPercent),
      holdings: holdings.map(h => ({
        ...h,
        allocation: totalValue > 0 ? ((h.value / totalValue) * 100).toFixed(1) : '0',
      })),
    };
  }, [trades, stats]);

  if (!isConnected) {
    return (
      <div className="container mx-auto p-8 flex items-center justify-center min-h-[60vh]">
        <div className="text-center glass rounded-xl p-12 border-dashed-sui max-w-lg">
          <AlertCircle className="h-16 w-16 text-primary mx-auto mb-6" />
          <h2 className="text-3xl font-bold mb-4">Connect Your Wallet</h2>
          <p className="text-gray-400 mb-8">
            Connect your wallet to view your portfolio and trading performance
          </p>
          <ConnectButton />
        </div>
      </div>
    );
  }

  if (loading) {
    return (
      <div className="container mx-auto p-8 text-center">
        <h1 className="text-4xl font-bold mb-4">Loading...</h1>
      </div>
    );
  }

  if (trades.length === 0) {
    return (
      <div className="container mx-auto p-8">
        <h1 className="text-5xl font-bold mb-8 gradient-text">Portfolio</h1>
        <EmptyStateGuide />
      </div>
    );
  }

  return (
    <div className="container mx-auto p-8 animate-fade-in">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-5xl font-bold mb-3">Portfolio</h1>
        <p className="text-gray-400">Track your holdings and performance</p>
      </div>

      {/* Summary Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        {/* Total Value */}
        <Card className="glass border-dashed-sui hover-lift transform-gpu">
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-gray-400">Total Value</CardTitle>
            <DollarSign className="h-5 w-5 text-primary" />
          </CardHeader>
          <CardContent>
            <div className="text-4xl font-bold mono-number mb-2">
              ${portfolioData.totalValue.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
            </div>
            <p className="text-sm text-gray-400">Across {portfolioData.holdings.length} assets</p>
          </CardContent>
        </Card>

        {/* Total Volume */}
        <Card className="glass border-dashed-sui hover-lift transform-gpu">
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-gray-400">Total Volume</CardTitle>
            <DollarSign className="h-5 w-5 text-blue-500" />
          </CardHeader>
          <CardContent>
            <div className="text-4xl font-bold mono-number mb-2 text-blue-500">
              ${portfolioData.totalVolume.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
            </div>
            <p className="text-sm text-gray-400">{stats.totalTrades} trades</p>
          </CardContent>
        </Card>

        {/* All-Time P&L */}
        <Card className="glass border-dashed-sui hover-lift transform-gpu">
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-gray-400">All-Time P&L</CardTitle>
            {portfolioData.totalPnL >= 0 ? (
              <TrendingUp className="h-5 w-5 text-green-500" />
            ) : (
              <TrendingDown className="h-5 w-5 text-red-500" />
            )}
          </CardHeader>
          <CardContent>
            <div className={`text-4xl font-bold mono-number mb-2 ${portfolioData.totalPnL >= 0 ? 'text-green-500' : 'text-red-500'}`}>
              {portfolioData.totalPnL >= 0 ? '+' : ''}${portfolioData.totalPnL.toFixed(2)}
            </div>
            <p className="text-sm text-gray-400">
              {portfolioData.pnlPercent >= 0 ? '+' : ''}{portfolioData.pnlPercent}%
            </p>
          </CardContent>
        </Card>
      </div>

      {/* Active Positions */}
      <Card className="glass border-dashed-sui mb-8">
        <CardHeader>
          <CardTitle className="text-xl">Active Positions</CardTitle>
          <p className="text-sm text-gray-400 mt-1">Your currently open trading positions</p>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <div className="glass rounded-lg p-4 border border-white/10">
              <p className="text-sm text-gray-400 mb-1">Open Trades</p>
              <p className="text-3xl font-bold text-primary">{stats.activePositions}</p>
            </div>
            <div className="glass rounded-lg p-4 border border-white/10">
              <p className="text-sm text-gray-400 mb-1">Closed Trades</p>
              <p className="text-3xl font-bold text-gray-300">{stats.closedPositions}</p>
            </div>
            <div className="glass rounded-lg p-4 border border-white/10">
              <p className="text-sm text-gray-400 mb-1">Total Trades</p>
              <p className="text-3xl font-bold text-gray-300">{stats.totalTrades}</p>
            </div>
            <div className="glass rounded-lg p-4 border border-white/10">
              <p className="text-sm text-gray-400 mb-1">Assets</p>
              <p className="text-3xl font-bold text-gray-300">{portfolioData.holdings.length}</p>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Holdings Table */}
      <Card className="glass border-dashed-sui">
        <CardHeader>
          <CardTitle className="text-xl">Holdings</CardTitle>
          <p className="text-sm text-gray-400 mt-1">Your current token balances from active positions</p>
        </CardHeader>
        <CardContent>
          {portfolioData.holdings.length === 0 ? (
            <div className="text-center py-12 text-gray-500">
              <p className="text-lg font-semibold mb-2">No Holdings</p>
              <p className="text-sm">Your holdings will appear here once you open positions</p>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead>
                  <tr className="border-b border-white/10">
                    <th className="text-left py-3 px-4 text-sm font-semibold text-gray-400 uppercase tracking-wide">
                      Token
                    </th>
                    <th className="text-right py-3 px-4 text-sm font-semibold text-gray-400 uppercase tracking-wide">
                      Balance
                    </th>
                    <th className="text-right py-3 px-4 text-sm font-semibold text-gray-400 uppercase tracking-wide">
                      Value
                    </th>
                    <th className="text-right py-3 px-4 text-sm font-semibold text-gray-400 uppercase tracking-wide">
                      Trades
                    </th>
                    <th className="text-right py-3 px-4 text-sm font-semibold text-gray-400 uppercase tracking-wide">
                      Allocation
                    </th>
                  </tr>
                </thead>
                <tbody>
                  {portfolioData.holdings.map((holding) => (
                    <tr
                      key={holding.token}
                      className="border-b border-white/5 hover:bg-white/5 transition-smooth"
                    >
                      <td className="py-4 px-4">
                        <div className="flex items-center gap-3">
                          <div className="w-8 h-8 rounded-full bg-primary/20 flex items-center justify-center">
                            <span className="text-sm font-bold text-primary">
                              {holding.token.charAt(0)}
                            </span>
                          </div>
                          <span className="font-bold">{holding.token}</span>
                        </div>
                      </td>
                      <td className="py-4 px-4 text-right">
                        <span className="font-mono text-sm">
                          {holding.balance.toFixed(4)}
                        </span>
                      </td>
                      <td className="py-4 px-4 text-right">
                        <span className="font-mono font-medium">
                          ${holding.value.toFixed(2)}
                        </span>
                      </td>
                      <td className="py-4 px-4 text-right">
                        <span className="text-sm text-gray-400">
                          {holding.trades}
                        </span>
                      </td>
                      <td className="py-4 px-4 text-right">
                        <div className="flex items-center justify-end gap-2">
                          <div className="w-24 h-2 bg-white/10 rounded-full overflow-hidden">
                            <div
                              className="h-full bg-primary rounded-full"
                              style={{ width: `${holding.allocation}%` }}
                            />
                          </div>
                          <span className="font-mono text-sm text-gray-400 w-12">
                            {holding.allocation}%
                          </span>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
