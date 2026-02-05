'use client';

import { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { Search, Filter, Download, Plus, Eye, XCircle, CheckCircle } from 'lucide-react';
import Link from 'next/link';

type LicenseStatus = 'active' | 'revoked' | 'expired';

interface License {
  id: string;
  subdomain: string;
  traderName: string;
  walletAddress: string;
  status: LicenseStatus;
  issueDate: string;
  lastTradeDate: string;
  paymentStatus: 'current' | 'overdue';
}

export default function LicensesPage() {
  const [searchQuery, setSearchQuery] = useState('');
  const [statusFilter, setStatusFilter] = useState<'all' | LicenseStatus>('all');

  // Mock data - in production, fetch from blockchain/database
  const licenses: License[] = [
    {
      id: '1',
      subdomain: 'trader1.fund.eth',
      traderName: 'Alice Johnson',
      walletAddress: '0x1234...5678',
      status: 'active',
      issueDate: '2026-01-15',
      lastTradeDate: '2026-02-05',
      paymentStatus: 'current',
    },
    {
      id: '2',
      subdomain: 'trader2.fund.eth',
      traderName: 'Bob Smith',
      walletAddress: '0xabcd...ef01',
      status: 'active',
      issueDate: '2026-01-20',
      lastTradeDate: '2026-02-04',
      paymentStatus: 'current',
    },
    {
      id: '3',
      subdomain: 'trader3.fund.eth',
      traderName: 'Carol Davis',
      walletAddress: '0x9876...5432',
      status: 'revoked',
      issueDate: '2026-01-10',
      lastTradeDate: '2026-01-28',
      paymentStatus: 'overdue',
    },
    {
      id: '4',
      subdomain: 'trader4.fund.eth',
      traderName: 'David Wilson',
      walletAddress: '0x5555...6666',
      status: 'active',
      issueDate: '2026-01-25',
      lastTradeDate: '2026-02-05',
      paymentStatus: 'current',
    },
    {
      id: '5',
      subdomain: 'trader5.fund.eth',
      traderName: 'Eve Martinez',
      walletAddress: '0x7777...8888',
      status: 'active',
      issueDate: '2026-02-01',
      lastTradeDate: '2026-02-05',
      paymentStatus: 'current',
    },
  ];

  const filteredLicenses = licenses.filter((license) => {
    const matchesSearch =
      license.subdomain.toLowerCase().includes(searchQuery.toLowerCase()) ||
      license.traderName.toLowerCase().includes(searchQuery.toLowerCase()) ||
      license.walletAddress.toLowerCase().includes(searchQuery.toLowerCase());

    const matchesStatus = statusFilter === 'all' || license.status === statusFilter;

    return matchesSearch && matchesStatus;
  });

  const getStatusBadge = (status: LicenseStatus) => {
    switch (status) {
      case 'active':
        return (
          <span className="inline-flex items-center gap-1 px-3 py-1 rounded-full text-xs font-semibold bg-green-500/20 text-green-500 border border-green-500/30">
            <CheckCircle className="h-3 w-3" />
            Active
          </span>
        );
      case 'revoked':
        return (
          <span className="inline-flex items-center gap-1 px-3 py-1 rounded-full text-xs font-semibold bg-red-500/20 text-red-500 border border-red-500/30">
            <XCircle className="h-3 w-3" />
            Revoked
          </span>
        );
      case 'expired':
        return (
          <span className="inline-flex items-center gap-1 px-3 py-1 rounded-full text-xs font-semibold bg-yellow-500/20 text-yellow-500 border border-yellow-500/30">
            Expired
          </span>
        );
    }
  };

  const getPaymentBadge = (status: 'current' | 'overdue') => {
    return status === 'current' ? (
      <span className="text-xs text-green-500">Current</span>
    ) : (
      <span className="text-xs text-red-500 font-semibold">Overdue</span>
    );
  };

  return (
    <div className="container mx-auto p-8 animate-fade-in">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-5xl font-bold mb-3">License Management</h1>
        <p className="text-gray-400">View and manage all trading licenses</p>
      </div>

      {/* Filters & Actions */}
      <Card className="glass border-dashed-sui mb-6">
        <CardContent className="pt-6">
          <div className="flex flex-col md:flex-row gap-4">
            {/* Search */}
            <div className="flex-1 relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-500" />
              <Input
                placeholder="Search by name, address, or subdomain..."
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
              <option value="active">Active</option>
              <option value="revoked">Revoked</option>
              <option value="expired">Expired</option>
            </select>

            {/* Export Button */}
            <Button variant="outline" className="gap-2">
              <Download className="h-4 w-4" />
              Export CSV
            </Button>

            {/* Issue License Button */}
            <Link href="/admin/licenses/issue">
              <Button className="glow-blue-sm hover-lift gap-2">
                <Plus className="h-4 w-4" />
                Issue License
              </Button>
            </Link>
          </div>
        </CardContent>
      </Card>

      {/* Results Count */}
      <div className="mb-4">
        <p className="text-sm text-gray-400">
          Showing <span className="text-primary font-semibold">{filteredLicenses.length}</span> of{' '}
          <span className="font-semibold">{licenses.length}</span> licenses
        </p>
      </div>

      {/* Licenses Table */}
      <Card className="glass border-dashed-sui">
        <CardHeader>
          <CardTitle className="text-xl">All Licenses</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b border-white/10">
                  <th className="text-left py-3 px-4 text-sm font-semibold text-gray-400 uppercase tracking-wide">
                    Subdomain
                  </th>
                  <th className="text-left py-3 px-4 text-sm font-semibold text-gray-400 uppercase tracking-wide">
                    Trader Name
                  </th>
                  <th className="text-left py-3 px-4 text-sm font-semibold text-gray-400 uppercase tracking-wide">
                    Wallet Address
                  </th>
                  <th className="text-left py-3 px-4 text-sm font-semibold text-gray-400 uppercase tracking-wide">
                    Status
                  </th>
                  <th className="text-left py-3 px-4 text-sm font-semibold text-gray-400 uppercase tracking-wide">
                    Issue Date
                  </th>
                  <th className="text-left py-3 px-4 text-sm font-semibold text-gray-400 uppercase tracking-wide">
                    Last Trade
                  </th>
                  <th className="text-left py-3 px-4 text-sm font-semibold text-gray-400 uppercase tracking-wide">
                    Payment
                  </th>
                  <th className="text-left py-3 px-4 text-sm font-semibold text-gray-400 uppercase tracking-wide">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody>
                {filteredLicenses.map((license) => (
                  <tr
                    key={license.id}
                    className="border-b border-white/5 hover:bg-white/5 transition-smooth"
                  >
                    <td className="py-4 px-4">
                      <span className="font-mono text-sm text-primary">{license.subdomain}</span>
                    </td>
                    <td className="py-4 px-4">
                      <span className="font-medium">{license.traderName}</span>
                    </td>
                    <td className="py-4 px-4">
                      <span className="font-mono text-sm text-gray-400">{license.walletAddress}</span>
                    </td>
                    <td className="py-4 px-4">{getStatusBadge(license.status)}</td>
                    <td className="py-4 px-4">
                      <span className="text-sm text-gray-400">{license.issueDate}</span>
                    </td>
                    <td className="py-4 px-4">
                      <span className="text-sm text-gray-400">{license.lastTradeDate}</span>
                    </td>
                    <td className="py-4 px-4">{getPaymentBadge(license.paymentStatus)}</td>
                    <td className="py-4 px-4">
                      <div className="flex gap-2">
                        <Button variant="ghost" size="sm" className="h-8 w-8 p-0">
                          <Eye className="h-4 w-4" />
                        </Button>
                        {license.status === 'active' ? (
                          <Button variant="ghost" size="sm" className="h-8 w-8 p-0 text-red-500 hover:text-red-400">
                            <XCircle className="h-4 w-4" />
                          </Button>
                        ) : (
                          <Button variant="ghost" size="sm" className="h-8 w-8 p-0 text-green-500 hover:text-green-400">
                            <CheckCircle className="h-4 w-4" />
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
