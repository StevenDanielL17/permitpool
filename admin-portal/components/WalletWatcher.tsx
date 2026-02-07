'use client';

import { useEffect } from 'react';

export function WalletWatcher() {
  useEffect(() => {
    if (typeof window !== 'undefined') {
      // Check if MetaMask/Ethereum provider is present
      if (typeof (window as any).ethereum === 'undefined') {
        console.log('MetaMask not installed');
      } else {
        const ethereum = (window as any).ethereum;

        // Handle network changes
        const handleChainChanged = () => {
          console.log('Chain changed, reloading...');
          window.location.reload();
        };

        // Handle account changes
        const handleAccountsChanged = (accounts: string[]) => {
          console.log('Accounts changed:', accounts);
          // Optional: You could trigger state updates here specific to your app
        };

        ethereum.on('chainChanged', handleChainChanged);
        ethereum.on('accountsChanged', handleAccountsChanged);

        // Cleanup listeners
        return () => {
          if (ethereum.removeListener) {
            ethereum.removeListener('chainChanged', handleChainChanged);
            ethereum.removeListener('accountsChanged', handleAccountsChanged);
          }
        };
      }
    }
  }, []);

  return null;
}
