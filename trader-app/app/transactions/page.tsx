'use client';

import { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { Search, Download, ExternalLink, CheckCircle, XCircle, Clock } from 'lucide-react';

type TxStatus = 'success' | 'failed' | 'pending';
type TxType = 'swap' | 'approve' | 'transfer';

interface Transaction {
  id: string;
  date: string;
  time: string;
  type: TxType;
  from: string;
  to: string;
  amount: string;
  price: string;
  fee: string;
  status: TxStatus;
  txHash: string;
}

export default function TransactionsPage() {
  const [searchQuery, setSearchQuery] = useState('');
  const [typeFilter, setTypeFilter] = useState<'all' | TxType>('all');
  const [statusFilter, setStatusFilter] = useState<'all' | TxStatus>('all');

  // Mock data - in production, fetch from blockchain/indexer
  const transactions: Transaction[] = [
    {
      id: '1',
      date: '2026-02-05',
      time: '14:30:22',
      type: 'swap',
      from: 'USDC',
      to: 'WETH',
      amount: '5,200',
      price: '2,395.50',
      fee: '12.50',
      status: 'success',
      txHash: '0xabcd1234...5678',
    },
    {
      id: '2',
      date: '2026-02-05',
      time: '09:15:10',
      type: 'swap',
      from: 'WETH',
      to: 'USDC',
      amount: '1.5',
      price: '2,390.00',
      fee: '8.75',
      status: 'success',
      txHash: '0x1234abcd...9012',
    },
    {
      id: '3',
      date: '2026-02-04',
      time: '16:45:33',
      type: 'approve',
      from: 'USDC',
      to: '—',
      amount: '∞',
      price: '—',
      fee: '3.20',
      status: 'success',
      txHash: '0x5678efgh...3456',
    },
    {
      id: '4',
      date: '2026-02-04',
      time: '11:20:15',
      type: 'swap',
      from: 'USDC',
      to: 'WETH',
      amount: '8,500',
      price: '2,385.00',
      fee: '18.30',
      status: 'success',
      txHash: '0x9012ijkl...7890',
    },
    {
      id: '5',
      date: '2026-02-03',
      time: '13:55:40',
      type: 'swap',
      from: 'WETH',
      to: 'USDC',
      amount: '2.0',
      price: '2,380.00',
      fee: '10.50',
      status: 'failed',
      txHash: '0xmnop3456...qrst',
    },
  ];

  const filteredTransactions = transactions.filter((tx) => {
    const matchesSearch =
      tx.from.toLowerCase().includes(searchQuery.toLowerCase()) ||
      tx.to.toLowerCase().includes(searchQuery.toLowerCase()) ||
      tx.txHash.toLowerCase().includes(searchQuery.toLowerCase());

    const matchesType = typeFilter === 'all' || tx.type === typeFilter;
    const matchesStatus = statusFilter === 'all' || tx.status === statusFilter;

    return matchesSearch && matchesType && matchesStatus;
  });

  const getStatusBadge = (status: TxStatus) => {
    switch (status) {
      case 'success':
        return (
          <span className="inline-flex items-center gap-1 px-3 py-1 rounded-full text-xs font-semibold bg-green-500/20 text-green-500 border border-green-500/30">
            <CheckCircle className="h-3 w-3" />
            Success
          </span>
        );
      case 'failed':
        return (
          <span className="inline-flex items-center gap-1 px-3 py-1 rounded-full text-xs font-semibold bg-red-500/20 text-red-500 border border-red-500/30">
            <XCircle className="h-3 w-3" />
            Failed
          </span>
        );
      case 'pending':
        return (
          <span className="inline-flex items-center gap-1 px-3 py-1 rounded-full text-xs font-semibold bg-yellow-500/20 text-yellow-500 border border-yellow-500/30">
            <Clock className="h-3 w-3" />
            Pending
          </span>
        );
    }
  };

  const getTypeBadge = (type: TxType) => {
    const colors = {
      swap: 'text-primary',
      approve: 'text-purple-500',
      transfer: 'text-green-500',
    };
    return <span className={`text-xs font-semibold uppercase ${colors[type]}`}>{type}</span>;
  };

  return (
    <div className="container mx-auto p-8 animate-fade-in">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-5xl font-bold mb-3">Transaction History</h1>
        <p className="text-gray-400">View all your trading activity</p>
      </div>

      {/* Filters & Search */}
      <Card className="glass border-dashed-sui mb-6">
        <CardContent className="pt-6">
          <div className="flex flex-col md:flex-row gap-4">
            {/* Search */}
            <div className="flex-1 relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-500" />
              <Input
                placeholder="Search by token or tx hash..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="pl-10 bg-white/5 border-white/10"
              />
            </div>

            {/* Type Filter */}
            <select
              value={typeFilter}
              onChange={(e) => setTypeFilter(e.target.value as typeof typeFilter)}
              className="px-4 py-2 bg-white/5 border border-white/10 rounded-lg text-white hover:bg-white/10 transition-smooth cursor-pointer"
            >
              <option value="all">All Types</option>
              <option value="swap">Swap</option>
              <option value="approve">Approve</option>
              <option value="transfer">Transfer</option>
            </select>

            {/* Status Filter */}
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value as typeof statusFilter)}
              className="px-4 py-2 bg-white/5 border border-white/10 rounded-lg text-white hover:bg-white/10 transition-smooth cursor-pointer"
            >
              <option value="all">All Status</option>
              <option value="success">Success</option>
              <option value="failed">Failed</option>
              <option value="pending">Pending</option>
            </select>

            {/* Export Button */}
            <Button variant="outline" className="gap-2">
              <Download className="h-4 w-4" />
              Export CSV
            </Button>
          </div>
        </CardContent>
      </Card>

      {/* Results Count */}
      <div className="mb-4">
        <p className="text-sm text-gray-400">
          Showing <span className="text-primary font-semibold">{filteredTransactions.length}</span> of{' '}
          <span className="font-semibold">{transactions.length}</span> transactions
        </p>
      </div>

      {/* Transactions Table */}
      <Card className="glass border-dashed-sui">
        <CardHeader>
          <CardTitle className="text-xl">All Transactions</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b border-white/10">
                  <th className="text-left py-3 px-4 text-sm font-semibold text-gray-400 uppercase tracking-wide">
                    Date/Time
                  </th>
                  <th className="text-left py-3 px-4 text-sm font-semibold text-gray-400 uppercase tracking-wide">
                    Type
                  </th>
                  <th className="text-left py-3 px-4 text-sm font-semibold text-gray-400 uppercase tracking-wide">
                    Tokens
                  </th>
                  <th className="text-right py-3 px-4 text-sm font-semibold text-gray-400 uppercase tracking-wide">
                    Amount
                  </th>
                  <th className="text-right py-3 px-4 text-sm font-semibold text-gray-400 uppercase tracking-wide">
                    Price
                  </th>
                  <th className="text-right py-3 px-4 text-sm font-semibold text-gray-400 uppercase tracking-wide">
                    Fee
                  </th>
                  <th className="text-left py-3 px-4 text-sm font-semibold text-gray-400 uppercase tracking-wide">
                    Status
                  </th>
                  <th className="text-left py-3 px-4 text-sm font-semibold text-gray-400 uppercase tracking-wide">
                    Tx Hash
                  </th>
                </tr>
              </thead>
              <tbody>
                {filteredTransactions.map((tx) => (
                  <tr
                    key={tx.id}
                    className="border-b border-white/5 hover:bg-white/5 transition-smooth"
                  >
                    <td className="py-4 px-4">
                      <div>
                        <p className="text-sm font-medium">{tx.date}</p>
                        <p className="text-xs text-gray-500 mono-number">{tx.time}</p>
                      </div>
                    </td>
                    <td className="py-4 px-4">{getTypeBadge(tx.type)}</td>
                    <td className="py-4 px-4">
                      <span className="text-sm font-medium">
                        {tx.from} → {tx.to}
                      </span>
                    </td>
                    <td className="py-4 px-4 text-right">
                      <span className="font-mono text-sm">{tx.amount}</span>
                    </td>
                    <td className="py-4 px-4 text-right">
                      <span className="font-mono text-sm text-gray-400">{tx.price}</span>
                    </td>
                    <td className="py-4 px-4 text-right">
                      <span className="font-mono text-sm text-gray-400">${tx.fee}</span>
                    </td>
                    <td className="py-4 px-4">{getStatusBadge(tx.status)}</td>
                    <td className="py-4 px-4">
                      <a
                        href={`https://sepolia.etherscan.io/tx/${tx.txHash}`}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="flex items-center gap-1 text-primary hover:underline font-mono text-sm"
                      >
                        {tx.txHash}
                        <ExternalLink className="h-3 w-3" />
                      </a>
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
