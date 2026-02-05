'use client';

import { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { TrendingUp, TrendingDown, DollarSign, PieChart } from 'lucide-react';

type TimeRange = '7d' | '30d' | '90d';

export default function PortfolioPage() {
  const [timeRange, setTimeRange] = useState<TimeRange>('30d');

  // Mock data - in production, fetch from blockchain/indexer
  const summary = {
    totalValue: 125430.50,
    change24h: 2340.25,
    change24hPercent: 1.9,
    allTimePnL: 15680.75,
    allTimePnLPercent: 14.3,
  };

  const holdings = [
    {
      token: 'USDC',
      balance: '45,230.50',
      value: 45230.50,
      change24h: 0,
      change24hPercent: 0,
      allocation: 36,
    },
    {
      token: 'WETH',
      balance: '28.5',
      value: 68200.00,
      change24h: 1890.50,
      change24hPercent: 2.85,
      allocation: 54,
    },
    {
      token: 'USDT',
      balance: '12,000.00',
      value: 12000.00,
      change24h: 0,
      change24hPercent: 0,
      allocation: 10,
    },
  ];

  // Mock chart data points
  const chartData = {
    '7d': [120000, 121500, 119800, 122300, 123100, 124500, 125430],
    '30d': [110000, 112000, 115000, 113500, 118000, 120000, 122000, 123500, 125430],
    '90d': [95000, 98000, 102000, 105000, 108000, 112000, 115000, 120000, 125430],
  };

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
              ${summary.totalValue.toLocaleString()}
            </div>
            <p className="text-sm text-gray-400">Across all assets</p>
          </CardContent>
        </Card>

        {/* 24h Change */}
        <Card className="glass border-dashed-sui hover-lift transform-gpu">
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-gray-400">24h Change</CardTitle>
            {summary.change24hPercent > 0 ? (
              <TrendingUp className="h-5 w-5 text-green-500" />
            ) : (
              <TrendingDown className="h-5 w-5 text-red-500" />
            )}
          </CardHeader>
          <CardContent>
            <div className={`text-4xl font-bold mono-number mb-2 ${summary.change24hPercent > 0 ? 'text-green-500' : 'text-red-500'}`}>
              {summary.change24hPercent > 0 ? '+' : ''}${summary.change24h.toLocaleString()}
            </div>
            <p className="text-sm text-gray-400">
              {summary.change24hPercent > 0 ? '+' : ''}{summary.change24hPercent}%
            </p>
          </CardContent>
        </Card>

        {/* All-Time P&L */}
        <Card className="glass border-dashed-sui hover-lift transform-gpu">
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-gray-400">All-Time P&L</CardTitle>
            <TrendingUp className="h-5 w-5 text-green-500" />
          </CardHeader>
          <CardContent>
            <div className="text-4xl font-bold mono-number mb-2 text-green-500">
              +${summary.allTimePnL.toLocaleString()}
            </div>
            <p className="text-sm text-gray-400">+{summary.allTimePnLPercent}%</p>
          </CardContent>
        </Card>
      </div>

      {/* Portfolio Value Chart */}
      <Card className="glass border-dashed-sui mb-8">
        <CardHeader>
          <div className="flex items-center justify-between">
            <div>
              <CardTitle className="text-xl">Portfolio Value Over Time</CardTitle>
              <p className="text-sm text-gray-400 mt-1">Track your portfolio performance</p>
            </div>
            <div className="flex gap-2">
              {(['7d', '30d', '90d'] as TimeRange[]).map((range) => (
                <button
                  key={range}
                  onClick={() => setTimeRange(range)}
                  className={`px-4 py-2 rounded-lg text-sm font-medium transition-smooth ${
                    timeRange === range
                      ? 'bg-primary text-black'
                      : 'bg-white/5 text-gray-400 hover:bg-white/10'
                  }`}
                >
                  {range}
                </button>
              ))}
            </div>
          </div>
        </CardHeader>
        <CardContent>
          {/* Simple ASCII-style chart visualization */}
          <div className="h-64 flex items-end gap-2 p-4">
            {chartData[timeRange].map((value, index) => {
              const maxValue = Math.max(...chartData[timeRange]);
              const height = (value / maxValue) * 100;
              return (
                <div key={index} className="flex-1 flex flex-col items-center gap-2">
                  <div className="text-xs text-gray-500 mono-number">
                    ${(value / 1000).toFixed(0)}K
                  </div>
                  <div
                    className="w-full bg-gradient-to-t from-primary/50 to-primary rounded-t-lg transition-all duration-500 hover-lift"
                    style={{ height: `${height}%` }}
                  />
                </div>
              );
            })}
          </div>
          <div className="flex justify-between text-xs text-gray-500 mt-4 px-4">
            <span>Start</span>
            <span>Now</span>
          </div>
        </CardContent>
      </Card>

      {/* Holdings Table */}
      <Card className="glass border-dashed-sui">
        <CardHeader>
          <CardTitle className="text-xl">Holdings</CardTitle>
          <p className="text-sm text-gray-400 mt-1">Your current token balances</p>
        </CardHeader>
        <CardContent>
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
                    24h Change
                  </th>
                  <th className="text-right py-3 px-4 text-sm font-semibold text-gray-400 uppercase tracking-wide">
                    Allocation
                  </th>
                </tr>
              </thead>
              <tbody>
                {holdings.map((holding) => (
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
                      <span className="font-mono text-sm">{holding.balance}</span>
                    </td>
                    <td className="py-4 px-4 text-right">
                      <span className="font-mono font-medium">
                        ${holding.value.toLocaleString()}
                      </span>
                    </td>
                    <td className="py-4 px-4 text-right">
                      {holding.change24hPercent === 0 ? (
                        <span className="text-gray-500 text-sm">—</span>
                      ) : (
                        <div className="flex items-center justify-end gap-1">
                          {holding.change24hPercent > 0 ? (
                            <TrendingUp className="h-4 w-4 text-green-500" />
                          ) : (
                            <TrendingDown className="h-4 w-4 text-red-500" />
                          )}
                          <span
                            className={`font-mono text-sm ${
                              holding.change24hPercent > 0 ? 'text-green-500' : 'text-red-500'
                            }`}
                          >
                            {holding.change24hPercent > 0 ? '+' : ''}
                            {holding.change24hPercent}%
                          </span>
                        </div>
                      )}
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
        </CardContent>
      </Card>
    </div>
  );
}
