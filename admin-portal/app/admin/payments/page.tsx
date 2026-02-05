'use client';

import { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { Search, DollarSign, AlertCircle, CheckCircle, Clock, Send } from 'lucide-react';

type PaymentStatus = 'current' | 'overdue' | 'failed';

interface Payment {
  id: string;
  trader: string;
  subdomain: string;
  monthlyFee: number;
  lastPaymentDate: string;
  nextDueDate: string;
  status: PaymentStatus;
  yellowSessionId: string;
}

export default function PaymentsPage() {
  const [searchQuery, setSearchQuery] = useState('');
  const [statusFilter, setStatusFilter] = useState<'all' | PaymentStatus>('all');

  // Mock data - in production, fetch from Yellow Network/database
  const payments: Payment[] = [
    {
      id: '1',
      trader: 'Alice Johnson',
      subdomain: 'trader1.fund.eth',
      monthlyFee: 50,
      lastPaymentDate: '2026-01-05',
      nextDueDate: '2026-03-05',
      status: 'current',
      yellowSessionId: 'YLW-001-2026',
    },
    {
      id: '2',
      trader: 'Bob Smith',
      subdomain: 'trader2.fund.eth',
      monthlyFee: 50,
      lastPaymentDate: '2026-01-10',
      nextDueDate: '2026-03-10',
      status: 'current',
      yellowSessionId: 'YLW-002-2026',
    },
    {
      id: '3',
      trader: 'Carol Davis',
      subdomain: 'trader3.fund.eth',
      monthlyFee: 50,
      lastPaymentDate: '2025-12-15',
      nextDueDate: '2026-02-15',
      status: 'overdue',
      yellowSessionId: 'YLW-003-2025',
    },
    {
      id: '4',
      trader: 'David Wilson',
      subdomain: 'trader4.fund.eth',
      monthlyFee: 50,
      lastPaymentDate: '2026-01-20',
      nextDueDate: '2026-03-20',
      status: 'current',
      yellowSessionId: 'YLW-004-2026',
    },
    {
      id: '5',
      trader: 'Eve Martinez',
      subdomain: 'trader5.fund.eth',
      monthlyFee: 50,
      lastPaymentDate: '2025-12-01',
      nextDueDate: '2026-02-01',
      status: 'failed',
      yellowSessionId: 'YLW-005-2025',
    },
  ];

  const metrics = {
    totalRevenue: payments.length * 50,
    overdueCount: payments.filter(p => p.status === 'overdue' || p.status === 'failed').length,
    collectionRate: 75, // percentage
  };

  const filteredPayments = payments.filter((payment) => {
    const matchesSearch =
      payment.trader.toLowerCase().includes(searchQuery.toLowerCase()) ||
      payment.subdomain.toLowerCase().includes(searchQuery.toLowerCase()) ||
      payment.yellowSessionId.toLowerCase().includes(searchQuery.toLowerCase());

    const matchesStatus = statusFilter === 'all' || payment.status === statusFilter;

    return matchesSearch && matchesStatus;
  });

  const getStatusBadge = (status: PaymentStatus) => {
    switch (status) {
      case 'current':
        return (
          <span className="inline-flex items-center gap-1 px-3 py-1 rounded-full text-xs font-semibold bg-green-500/20 text-green-500 border border-green-500/30">
            <CheckCircle className="h-3 w-3" />
            Current
          </span>
        );
      case 'overdue':
        return (
          <span className="inline-flex items-center gap-1 px-3 py-1 rounded-full text-xs font-semibold bg-yellow-500/20 text-yellow-500 border border-yellow-500/30">
            <Clock className="h-3 w-3" />
            Overdue
          </span>
        );
      case 'failed':
        return (
          <span className="inline-flex items-center gap-1 px-3 py-1 rounded-full text-xs font-semibold bg-red-500/20 text-red-500 border border-red-500/30">
            <AlertCircle className="h-3 w-3" />
            Failed
          </span>
        );
    }
  };

  return (
    <div className="container mx-auto p-8 animate-fade-in">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-5xl font-bold mb-3">Payment Management</h1>
        <p className="text-gray-400">Monitor and manage trader subscription payments</p>
      </div>

      {/* Metrics Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        {/* Total Monthly Revenue */}
        <Card className="glass border-dashed-sui hover-lift transform-gpu">
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-gray-400">Monthly Revenue</CardTitle>
            <DollarSign className="h-5 w-5 text-green-500" />
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold mono-number text-green-500">
              ${metrics.totalRevenue}
            </div>
            <p className="text-xs text-gray-500 mt-1">From active licenses</p>
          </CardContent>
        </Card>

        {/* Overdue Payments */}
        <Card className="glass border-dashed-sui hover-lift transform-gpu">
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-gray-400">Overdue Payments</CardTitle>
            <AlertCircle className="h-5 w-5 text-red-500" />
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold mono-number text-red-500">
              {metrics.overdueCount}
            </div>
            <p className="text-xs text-gray-500 mt-1">Require attention</p>
          </CardContent>
        </Card>

        {/* Collection Rate */}
        <Card className="glass border-dashed-sui hover-lift transform-gpu">
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-gray-400">Collection Rate</CardTitle>
            <CheckCircle className="h-5 w-5 text-primary" />
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold mono-number">
              {metrics.collectionRate}%
            </div>
            <p className="text-xs text-gray-500 mt-1">On-time payments</p>
          </CardContent>
        </Card>
      </div>

      {/* Filters & Actions */}
      <Card className="glass border-dashed-sui mb-6">
        <CardContent className="pt-6">
          <div className="flex flex-col md:flex-row gap-4">
            {/* Search */}
            <div className="flex-1 relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-500" />
              <Input
                placeholder="Search by trader, subdomain, or session ID..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="pl-10 bg-white/5 border-white/10"
              />
            </div>

            {/* Status Filter */}
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value as typeof statusFilter)}
              className="px-4 py-2 bg-white/5 border border-white/10 rounded-lg text-white hover:bg-white/10 transition-smooth cursor-pointer"
            >
              <option value="all">All Status</option>
              <option value="current">Current</option>
              <option value="overdue">Overdue</option>
              <option value="failed">Failed</option>
            </select>

            {/* Bulk Actions */}
            <Button variant="outline" className="gap-2">
              <Send className="h-4 w-4" />
              Send Reminders
            </Button>
          </div>
        </CardContent>
      </Card>

      {/* Results Count */}
      <div className="mb-4">
        <p className="text-sm text-gray-400">
          Showing <span className="text-primary font-semibold">{filteredPayments.length}</span> of{' '}
          <span className="font-semibold">{payments.length}</span> payment records
        </p>
      </div>

      {/* Payments Table */}
      <Card className="glass border-dashed-sui">
        <CardHeader>
          <CardTitle className="text-xl">Payment Records</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b border-white/10">
                  <th className="text-left py-3 px-4 text-sm font-semibold text-gray-400 uppercase tracking-wide">
                    Trader
                  </th>
                  <th className="text-left py-3 px-4 text-sm font-semibold text-gray-400 uppercase tracking-wide">
                    Subdomain
                  </th>
                  <th className="text-right py-3 px-4 text-sm font-semibold text-gray-400 uppercase tracking-wide">
                    Monthly Fee
                  </th>
                  <th className="text-left py-3 px-4 text-sm font-semibold text-gray-400 uppercase tracking-wide">
                    Last Payment
                  </th>
                  <th className="text-left py-3 px-4 text-sm font-semibold text-gray-400 uppercase tracking-wide">
                    Next Due
                  </th>
                  <th className="text-left py-3 px-4 text-sm font-semibold text-gray-400 uppercase tracking-wide">
                    Status
                  </th>
                  <th className="text-left py-3 px-4 text-sm font-semibold text-gray-400 uppercase tracking-wide">
                    Yellow Session
                  </th>
                  <th className="text-left py-3 px-4 text-sm font-semibold text-gray-400 uppercase tracking-wide">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody>
                {filteredPayments.map((payment) => (
                  <tr
                    key={payment.id}
                    className="border-b border-white/5 hover:bg-white/5 transition-smooth"
                  >
                    <td className="py-4 px-4">
                      <span className="font-medium">{payment.trader}</span>
                    </td>
                    <td className="py-4 px-4">
                      <span className="font-mono text-sm text-primary">{payment.subdomain}</span>
                    </td>
                    <td className="py-4 px-4 text-right">
                      <span className="font-mono font-medium">${payment.monthlyFee}</span>
                    </td>
                    <td className="py-4 px-4">
                      <span className="text-sm text-gray-400">{payment.lastPaymentDate}</span>
                    </td>
                    <td className="py-4 px-4">
                      <span className="text-sm text-gray-400">{payment.nextDueDate}</span>
                    </td>
                    <td className="py-4 px-4">{getStatusBadge(payment.status)}</td>
                    <td className="py-4 px-4">
                      <span className="font-mono text-xs text-gray-400">{payment.yellowSessionId}</span>
                    </td>
                    <td className="py-4 px-4">
                      <div className="flex gap-2">
                        <Button variant="ghost" size="sm" className="text-xs">
                          View
                        </Button>
                        {payment.status !== 'current' && (
                          <Button variant="ghost" size="sm" className="text-xs text-yellow-500">
                            Renew
                          </Button>
                        )}
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
