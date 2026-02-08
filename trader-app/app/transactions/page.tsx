'use client';

import { useState } from 'react';
import { useAccount } from 'wagmi';
import { useUserTrades } from '@/hooks/useUserTrades';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { Search, Download, ExternalLink, CheckCircle, XCircle, Clock, AlertCircle } from 'lucide-react';
import { ConnectButton } from '@rainbow-me/rainbowkit';

export default function TransactionsPage() {
  const { isConnected } = useAccount();
  const { trades, loading } = useUserTrades();
  const [searchQuery, setSearchQuery] = useState('');

  // Convert trades to transaction format for display
  const transactions = trades.map(trade => ({
    id: trade.id,
    date: new Date(trade.timestamp).toLocaleDateString('en-CA'),
    time: new Date(trade.timestamp).toLocaleTimeString('en-US'),
    type: 'swap' as const,
    from: trade.type === 'BUY' ? 'USDC' : trade.asset.split('/')[0],
    to: trade.type === 'BUY' ? trade.asset.split('/')[0] : 'USDC',
    amount: trade.amount,
    price: trade.price,
    fee: '0.00', // Could be calculated
    status: trade.status === 'OPEN' ? 'success' as const : 'success' as const,
    txHash: `0x${trade.id.slice(0, 8)}...${trade.id.slice(-4)}`,
  }));

  const filteredTransactions = transactions.filter((tx) => {
    const matchesSearch =
      tx.from.toLowerCase().includes(searchQuery.toLowerCase()) ||
      tx.to.toLowerCase().includes(searchQuery.toLowerCase()) ||
      tx.txHash.toLowerCase().includes(searchQuery.toLowerCase());

    return matchesSearch;
  });

  const getStatusBadge = (status: 'success' | 'failed' | 'pending') => {
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

  const getTypeBadge = (type: 'swap' | 'approve' | 'transfer') => {
    const colors = {
      swap: 'text-primary',
      approve: 'text-purple-500',
      transfer: 'text-green-500',
    };
    return <span className={`text-xs font-semibold uppercase ${colors[type]}`}>{type}</span>;
  };

  if (!isConnected) {
    return (
      <div className="container mx-auto p-8 flex items-center justify-center min-h-[60vh]">
        <div className="text-center glass rounded-xl p-12 border-dashed-sui max-w-lg">
          <AlertCircle className="h-16 w-16 text-primary mx-auto mb-6" />
          <h2 className="text-3xl font-bold mb-4">Connect Your Wallet</h2>
          <p className="text-gray-400 mb-8">
            Connect your wallet to view your transaction history
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

      <div classSpacer for future filters */}
            <div className="flex-1"></divn value="approve">Approve</option>
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
                  >length === 0 ? (
                  <tr>
                    <td colSpan={8} className="py-12 text-center">
                      <div className="text-gray-500">
                        <p className="text-lg font-semibold mb-2">No transactions yet</p>
                        <p className="text-sm">Your trades will appear here once you start trading</p>
                      </div>
                    </td>
                  </tr>
                ) : (
                  filteredTransactions.
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
                  
                )    >
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
