'use client';

import { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { TrendingUp, Download, BarChart3, PieChart, Activity } from 'lucide-react';

type TimeRange = '7d' | '30d' | '90d';

export default function AnalyticsPage() {
  const [timeRange, setTimeRange] = useState<TimeRange>('30d');

  // Mock chart data
  const tradingVolumeData = {
    '7d': [45000, 52000, 48000, 55000, 60000, 58000, 62000],
    '30d': [30000, 35000, 42000, 48000, 52000, 55000, 58000, 60000, 62000],
    '90d': [20000, 25000, 30000, 35000, 40000, 45000, 50000, 55000, 62000],
  };

  const licensesData = {
    issued: [2, 3, 1, 4, 2, 3, 5, 2, 4],
    revoked: [0, 1, 0, 0, 1, 0, 2, 0, 1],
  };

  const revenueData = [900, 950, 1000, 1050, 1100, 1150, 1200, 1250];

  const topPairs = [
    { pair: 'USDC/WETH', volume: 285000 },
    { pair: 'WETH/USDT', volume: 142000 },
    { pair: 'USDC/USDT', volume: 98000 },
    { pair: 'WBTC/WETH', volume: 67000 },
  ];

  const gasFees = [
    { category: 'Swaps', amount: 450 },
    { category: 'Approvals', amount: 120 },
    { category: 'License Issuance', amount: 85 },
    { category: 'Revocations', amount: 45 },
  ];

  return (
    <div className="container mx-auto p-8 animate-fade-in">
      {/* Header */}
      <div className="mb-8">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-5xl font-bold mb-3">Analytics</h1>
            <p className="text-gray-400">Platform metrics and performance insights</p>
          </div>
          <Button className="gap-2 glow-blue-sm">
            <Download className="h-4 w-4" />
            Export Report
          </Button>
        </div>
      </div>

      {/* Trading Volume Chart */}
      <Card className="glass border-dashed-sui mb-8">
        <CardHeader>
          <div className="flex items-center justify-between">
            <div>
              <CardTitle className="text-xl flex items-center gap-2">
                <TrendingUp className="h-5 w-5 text-primary" />
                Trading Volume Over Time
              </CardTitle>
              <p className="text-sm text-gray-400 mt-1">Total swap volume across all traders</p>
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
          <div className="h-64 flex items-end gap-2 p-4">
            {tradingVolumeData[timeRange].map((value, index) => {
              const maxValue = Math.max(...tradingVolumeData[timeRange]);
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
        </CardContent>
      </Card>

      {/* Licenses Issued vs Revoked */}
      <Card className="glass border-dashed-sui mb-8">
        <CardHeader>
          <CardTitle className="text-xl flex items-center gap-2">
            <Activity className="h-5 w-5 text-green-500" />
            Licenses: Issued vs Revoked
          </CardTitle>
          <p className="text-sm text-gray-400 mt-1">License activity over the last 30 days</p>
        </CardHeader>
        <CardContent>
          <div className="h-48 flex items-end gap-3 p-4">
            {licensesData.issued.map((issued, index) => {
              const revoked = licensesData.revoked[index];
              const maxValue = Math.max(...licensesData.issued);
              const issuedHeight = (issued / maxValue) * 100;
              const revokedHeight = (revoked / maxValue) * 100;
              
              return (
                <div key={index} className="flex-1 flex gap-1 items-end">
                  <div
                    className="flex-1 bg-gradient-to-t from-green-500/50 to-green-500 rounded-t-lg transition-all duration-500"
                    style={{ height: `${issuedHeight}%` }}
                    title={`Issued: ${issued}`}
                  />
                  <div
                    className="flex-1 bg-gradient-to-t from-red-500/50 to-red-500 rounded-t-lg transition-all duration-500"
                    style={{ height: `${revokedHeight}%` }}
                    title={`Revoked: ${revoked}`}
                  />
                </div>
              );
            })}
          </div>
          <div className="flex justify-center gap-6 mt-4">
            <div className="flex items-center gap-2">
              <div className="w-4 h-4 bg-green-500 rounded" />
              <span className="text-sm text-gray-400">Issued</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-4 h-4 bg-red-500 rounded" />
              <span className="text-sm text-gray-400">Revoked</span>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Revenue Trend & Top Trading Pairs */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
        {/* Revenue Trend */}
        <Card className="glass border-dashed-sui">
          <CardHeader>
            <CardTitle className="text-xl flex items-center gap-2">
              <BarChart3 className="h-5 w-5 text-green-500" />
              Revenue Trend
            </CardTitle>
            <p className="text-sm text-gray-400 mt-1">Monthly recurring revenue</p>
          </CardHeader>
          <CardContent>
            <div className="h-48 flex items-end gap-2 p-4">
              {revenueData.map((value, index) => {
                const maxValue = Math.max(...revenueData);
                const height = (value / maxValue) * 100;
                return (
                  <div key={index} className="flex-1 flex flex-col items-center gap-2">
                    <div className="text-xs text-gray-500 mono-number">
                      ${value}
                    </div>
                    <div
                      className="w-full bg-gradient-to-t from-green-500/50 to-green-500 rounded-t-lg transition-all duration-500 hover-lift"
                      style={{ height: `${height}%` }}
                    />
                  </div>
                );
              })}
            </div>
          </CardContent>
        </Card>

        {/* Top Trading Pairs */}
        <Card className="glass border-dashed-sui">
          <CardHeader>
            <CardTitle className="text-xl flex items-center gap-2">
              <TrendingUp className="h-5 w-5 text-primary" />
              Top Trading Pairs
            </CardTitle>
            <p className="text-sm text-gray-400 mt-1">By total volume (30d)</p>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {topPairs.map((pair, index) => {
                const maxVolume = topPairs[0].volume;
                const percentage = (pair.volume / maxVolume) * 100;
                return (
                  <div key={index}>
                    <div className="flex items-center justify-between mb-2">
                      <span className="text-sm font-medium">{pair.pair}</span>
                      <span className="text-sm mono-number text-gray-400">
                        ${(pair.volume / 1000).toFixed(0)}K
                      </span>
                    </div>
                    <div className="w-full h-2 bg-white/10 rounded-full overflow-hidden">
                      <div
                        className="h-full bg-primary rounded-full transition-all duration-500"
                        style={{ width: `${percentage}%` }}
                      />
                    </div>
                  </div>
                );
              })}
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Gas Fees Distribution */}
      <Card className="glass border-dashed-sui">
        <CardHeader>
          <CardTitle className="text-xl flex items-center gap-2">
            <PieChart className="h-5 w-5 text-yellow-500" />
            Gas Fees Distribution
          </CardTitle>
          <p className="text-sm text-gray-400 mt-1">Total gas spent by category (30d)</p>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            {gasFees.map((fee, index) => {
              const colors = ['primary', 'green-500', 'yellow-500', 'purple-500'];
              const color = colors[index];
              return (
                <div
                  key={index}
                  className="glass rounded-lg p-4 border border-dashed border-white/20 hover-lift"
                >
                  <div className="text-sm text-gray-400 mb-2">{fee.category}</div>
                  <div className={`text-2xl font-bold mono-number text-${color}`}>
                    ${fee.amount}
                  </div>
                  <div className="text-xs text-gray-500 mt-1">in gas fees</div>
                </div>
              );
            })}
          </div>
          <div className="mt-6 p-4 glass rounded-lg border border-primary/30">
            <div className="flex items-center justify-between">
              <span className="text-sm text-gray-400">Total Gas Spent</span>
              <span className="text-2xl font-bold mono-number text-primary">
                ${gasFees.reduce((sum, fee) => sum + fee.amount, 0)}
              </span>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
