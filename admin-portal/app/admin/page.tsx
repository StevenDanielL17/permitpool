'use client';

import { Activity, Users, DollarSign, TrendingUp, FileText, AlertCircle } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import Link from 'next/link';
import { Button } from '@/components/ui/button';

export default function AdminDashboard() {
  // Mock data - in production, fetch from blockchain/database
  const metrics = {
    totalLicenses: 24,
    activeTraders: 18,
    revokedLicenses: 6,
    tradingVolume: 1245678,
    monthlyRevenue: 900,
  };

  const recentActivity = [
    { id: 1, type: 'license_issued', trader: 'trader5.fund.eth', time: '2 hours ago' },
    { id: 2, type: 'trade', trader: 'trader2.fund.eth', amount: '$12,450', time: '3 hours ago' },
    { id: 3, type: 'payment', trader: 'trader8.fund.eth', amount: '$50', time: '5 hours ago' },
    { id: 4, type: 'license_revoked', trader: 'trader12.fund.eth', time: '1 day ago' },
    { id: 5, type: 'trade', trader: 'trader1.fund.eth', amount: '$8,920', time: '1 day ago' },
    { id: 6, type: 'kyc_verified', trader: 'trader15.fund.eth', time: '2 days ago' },
    { id: 7, type: 'payment', trader: 'trader3.fund.eth', amount: '$50', time: '2 days ago' },
    { id: 8, type: 'trade', trader: 'trader7.fund.eth', amount: '$15,300', time: '3 days ago' },
    { id: 9, type: 'license_issued', trader: 'trader20.fund.eth', time: '3 days ago' },
    { id: 10, type: 'trade', trader: 'trader4.fund.eth', amount: '$22,100', time: '4 days ago' },
  ];

  const getActivityIcon = (type: string) => {
    switch (type) {
      case 'license_issued':
        return <FileText className="h-4 w-4 text-green-500" />;
      case 'license_revoked':
        return <AlertCircle className="h-4 w-4 text-red-500" />;
      case 'trade':
        return <TrendingUp className="h-4 w-4 text-blue-500" />;
      case 'payment':
        return <DollarSign className="h-4 w-4 text-green-500" />;
      case 'kyc_verified':
        return <Users className="h-4 w-4 text-purple-500" />;
      default:
        return <Activity className="h-4 w-4 text-gray-500" />;
    }
  };

  const getActivityText = (activity: typeof recentActivity[0]) => {
    switch (activity.type) {
      case 'license_issued':
        return `License issued to ${activity.trader}`;
      case 'license_revoked':
        return `License revoked for ${activity.trader}`;
      case 'trade':
        return `${activity.trader} traded ${activity.amount}`;
      case 'payment':
        return `${activity.trader} paid ${activity.amount}`;
      case 'kyc_verified':
        return `KYC verified for ${activity.trader}`;
      default:
        return activity.trader;
    }
  };

  return (
    <div className="container mx-auto p-8 animate-fade-in">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-5xl font-bold mb-3">Dashboard</h1>
        <p className="text-gray-400">Manage licenses and monitor institutional trading activity</p>
      </div>

      {/* Metrics Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-6 mb-8">
        {/* Total Licenses */}
        <Card className="glass border-dashed-sui hover-lift transform-gpu">
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-gray-400">Total Licenses</CardTitle>
            <FileText className="h-5 w-5 text-primary" />
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold mono-number">{metrics.totalLicenses}</div>
            <p className="text-xs text-gray-500 mt-1">All time issued</p>
          </CardContent>
        </Card>

        {/* Active Traders */}
        <Card className="glass border-dashed-sui hover-lift transform-gpu">
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-gray-400">Active Traders</CardTitle>
            <Users className="h-5 w-5 text-green-500" />
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold mono-number text-green-500">{metrics.activeTraders}</div>
            <p className="text-xs text-gray-500 mt-1">Currently trading</p>
          </CardContent>
        </Card>

        {/* Revoked Licenses */}
        <Card className="glass border-dashed-sui hover-lift transform-gpu">
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-gray-400">Revoked</CardTitle>
            <AlertCircle className="h-5 w-5 text-red-500" />
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold mono-number text-red-500">{metrics.revokedLicenses}</div>
            <p className="text-xs text-gray-500 mt-1">Suspended access</p>
          </CardContent>
        </Card>

        {/* Trading Volume */}
        <Card className="glass border-dashed-sui hover-lift transform-gpu">
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-gray-400">Trading Volume</CardTitle>
            <TrendingUp className="h-5 w-5 text-primary" />
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold mono-number">
              ${(metrics.tradingVolume / 1000).toFixed(0)}K
            </div>
            <p className="text-xs text-gray-500 mt-1">Total 30d</p>
          </CardContent>
        </Card>

        {/* Monthly Revenue */}
        <Card className="glass border-dashed-sui hover-lift transform-gpu">
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-gray-400">Monthly Revenue</CardTitle>
            <DollarSign className="h-5 w-5 text-green-500" />
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold mono-number text-green-500">
              ${metrics.monthlyRevenue}
            </div>
            <p className="text-xs text-gray-500 mt-1">From fees</p>
          </CardContent>
        </Card>
      </div>

      {/* Quick Actions & Recent Activity */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Quick Actions */}
        <Card className="glass border-dashed-sui">
          <CardHeader>
            <CardTitle className="text-xl">Quick Actions</CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            <Link href="/admin/licenses/issue">
              <Button className="w-full glow-blue-sm hover-lift" size="lg">
                <FileText className="mr-2 h-5 w-5" />
                Issue New License
              </Button>
            </Link>
            <Link href="/admin/licenses">
              <Button variant="outline" className="w-full" size="lg">
                <Users className="mr-2 h-5 w-5" />
                Manage Licenses
              </Button>
            </Link>
            <Link href="/admin/compliance">
              <Button variant="outline" className="w-full" size="lg">
                <FileText className="mr-2 h-5 w-5" />
                View Reports
              </Button>
            </Link>
            <Link href="/admin/analytics">
              <Button variant="outline" className="w-full" size="lg">
                <TrendingUp className="mr-2 h-5 w-5" />
                Analytics
              </Button>
            </Link>
          </CardContent>
        </Card>

        {/* Recent Activity Feed */}
        <Card className="lg:col-span-2 glass border-dashed-sui">
          <CardHeader>
            <CardTitle className="text-xl">Recent Activity</CardTitle>
            <p className="text-sm text-gray-400">Last 10 actions across the platform</p>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {recentActivity.map((activity) => (
                <div
                  key={activity.id}
                  className="flex items-start gap-3 p-3 rounded-lg hover:bg-white/5 transition-smooth"
                >
                  <div className="mt-0.5">{getActivityIcon(activity.type)}</div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm text-gray-200">{getActivityText(activity)}</p>
                    <p className="text-xs text-gray-500 mt-0.5">{activity.time}</p>
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
