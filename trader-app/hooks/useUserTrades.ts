import { useState, useEffect } from 'react';
import { useAccount } from 'wagmi';

// Define what a Trade looks like
export interface Trade {
  id: string;
  asset: string;    // e.g., "ETH/USD"
  type: 'BUY' | 'SELL';
  amount: string;
  price: string;
  timestamp: number;
  status: 'OPEN' | 'CLOSED';
  pnl?: string;     // Profit/Loss
}

export function useUserTrades() {
  const { address } = useAccount();
  const [trades, setTrades] = useState<Trade[]>([]);
  const [loading, setLoading] = useState(true);

  // 1. LOAD TRADES when wallet changes
  useEffect(() => {
    if (!address) {
      setTrades([]); // No wallet = No data
      setLoading(false);
      return;
    }

    // "Fake Database" Key: trades_0x123...
    const storageKey = `trades_${address.toLowerCase()}`;
    const savedTrades = localStorage.getItem(storageKey);

    if (savedTrades) {
      try {
        setTrades(JSON.parse(savedTrades));
      } catch (error) {
        console.error('Error loading trades:', error);
        setTrades([]);
      }
    } else {
      setTrades([]); // New user = Empty state
    }
    setLoading(false);
  }, [address]);

  // 2. FUNCTION TO ADD A NEW TRADE (Call this when they click "Buy")
  const executeTrade = (newTrade: Omit<Trade, 'id' | 'timestamp' | 'status'>) => {
    if (!address) return;

    const tradeRecord: Trade = {
      ...newTrade,
      id: Math.random().toString(36).substr(2, 9),
      timestamp: Date.now(),
      status: 'OPEN',
      pnl: '0.00' // Starts at 0
    };

    const updatedTrades = [tradeRecord, ...trades]; // Add to top
    setTrades(updatedTrades);

    // Save to "Database"
    const storageKey = `trades_${address.toLowerCase()}`;
    localStorage.setItem(storageKey, JSON.stringify(updatedTrades));
  };

  // 3. FUNCTION TO CLOSE A TRADE
  const closeTrade = (tradeId: string, finalPnl: string) => {
    if (!address) return;

    const updatedTrades = trades.map(trade => 
      trade.id === tradeId 
        ? { ...trade, status: 'CLOSED' as const, pnl: finalPnl }
        : trade
    );

    setTrades(updatedTrades);

    const storageKey = `trades_${address.toLowerCase()}`;
    localStorage.setItem(storageKey, JSON.stringify(updatedTrades));
  };

  // 4. CALCULATE ANALYTICS (Dynamic!)
  const stats = {
    totalTrades: trades.length,
    activePositions: trades.filter(t => t.status === 'OPEN').length,
    closedPositions: trades.filter(t => t.status === 'CLOSED').length,
    // Simple mock PnL calculation based on history
    totalPnL: trades.reduce((acc, t) => acc + parseFloat(t.pnl || '0'), 0).toFixed(2),
    // Volume calculation
    totalVolume: trades.reduce((acc, t) => acc + (parseFloat(t.amount) * parseFloat(t.price)), 0).toFixed(2)
  };

  return { trades, executeTrade, closeTrade, stats, loading };
}
