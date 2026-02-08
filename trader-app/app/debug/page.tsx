'use client';

import { useAccount } from 'wagmi';
import { useState, useEffect } from 'react';
import { BrowserProvider } from 'ethers';

export default function DebugPage() {
  const { address, isConnected } = useAccount();
  const [reverseENS, setReverseENS] = useState<string | null>(null);
  const [forwardENS, setForwardENS] = useState<string | null>(null);
  const [checking, setChecking] = useState(false);

  useEffect(() => {
    async function checkENS() {
      if (!isConnected || !address || !window.ethereum) return;
      
      setChecking(true);
      
      try {
        const provider = new BrowserProvider(window.ethereum);
        
        // Check reverse resolution
        const ensName = await provider.lookupAddress(address);
        setReverseENS(ensName);
        
        // Check forward resolution
        if (ensName) {
          const resolved = await provider.resolveName(ensName);
          setForwardENS(resolved);
        } else {
          // Try the expected name
          const expectedName = 'dexter.hedgefund-v3.eth';
          const resolved = await provider.resolveName(expectedName);
          setForwardENS(resolved);
        }
      } catch (error) {
        console.error('ENS check error:', error);
      }
      
      setChecking(false);
    }
    
    checkENS();
  }, [address, isConnected]);

  return (
    <div className="min-h-screen bg-gray-100 p-8">
      <div className="max-w-4xl mx-auto">
        <h1 className="text-3xl font-bold mb-8">🔍 Trader App Diagnostics</h1>
        
        {/* Environment Variables */}
        <div className="bg-white rounded-lg shadow p-6 mb-6">
          <h2 className="text-xl font-semibold mb-4">📋 Environment Variables</h2>
          <div className="space-y-2 font-mono text-sm">
            <div>
              <span className="text-gray-600">LICENSE_MANAGER:</span>{' '}
              <span className="text-blue-600">{process.env.NEXT_PUBLIC_LICENSE_MANAGER_ADDRESS || '❌ NOT SET'}</span>
            </div>
            <div>
              <span className="text-gray-600">PARENT_DOMAIN:</span>{' '}
              <span className="text-blue-600">{process.env.NEXT_PUBLIC_PARENT_DOMAIN || '❌ NOT SET'}</span>
            </div>
            <div>
              <span className="text-gray-600">CHAIN_ID:</span>{' '}
              <span className="text-blue-600">{process.env.NEXT_PUBLIC_CHAIN_ID || '❌ NOT SET'}</span>
            </div>
            <div>
              <span className="text-gray-600">HOOK:</span>{' '}
              <span className="text-blue-600">{process.env.NEXT_PUBLIC_HOOK_ADDRESS || '❌ NOT SET'}</span>
            </div>
          </div>
        </div>

        {/* Wallet Status */}
        <div className="bg-white rounded-lg shadow p-6 mb-6">
          <h2 className="text-xl font-semibold mb-4">💳 Wallet Status</h2>
          {isConnected ? (
            <div className="space-y-2">
              <div className="flex items-center gap-2">
                <span className="text-green-500 text-2xl">✅</span>
                <span>Connected</span>
              </div>
              <div className="font-mono text-sm bg-gray-100 p-3 rounded">
                {address}
              </div>
            </div>
          ) : (
            <div className="flex items-center gap-2">
              <span className="text-red-500 text-2xl">❌</span>
              <span>Not connected - Connect your wallet first</span>
            </div>
          )}
        </div>

        {/* ENS Resolution */}
        {isConnected && (
          <>
            <div className="bg-white rounded-lg shadow p-6 mb-6">
              <h2 className="text-xl font-semibold mb-4">🔄 Reverse ENS Resolution</h2>
              {checking ? (
                <div>Checking...</div>
              ) : reverseENS ? (
                <div className="space-y-2">
                  <div className="flex items-center gap-2">
                    <span className="text-green-500 text-2xl">✅</span>
                    <span>Reverse resolution found!</span>
                  </div>
                  <div className="font-mono text-lg bg-green-50 p-3 rounded text-green-700">
                    {reverseENS}
                  </div>
                  {reverseENS.endsWith('.hedgefund-v3.eth') ? (
                    <div className="mt-4 p-4 bg-green-100 border border-green-300 rounded">
                      <p className="font-semibold text-green-800">✅ VALID LICENSE DETECTED!</p>
                      <p className="text-sm text-green-700">Your license should be recognized by the app.</p>
                    </div>
                  ) : (
                    <div className="mt-4 p-4 bg-yellow-100 border border-yellow-300 rounded">
                      <p className="font-semibold text-yellow-800">⚠️ Not a valid license</p>
                      <p className="text-sm text-yellow-700">ENS name doesn't end with .hedgefund-v3.eth</p>
                    </div>
                  )}
                </div>
              ) : (
                <div className="space-y-4">
                  <div className="flex items-center gap-2">
                    <span className="text-red-500 text-2xl">❌</span>
                    <span>No reverse resolution found</span>
                  </div>
                  <div className="p-4 bg-red-50 border border-red-300 rounded">
                    <p className="font-semibold text-red-800 mb-2">This is why the app can't detect your license!</p>
                    <p className="text-sm text-red-700 mb-3">
                      Your wallet address doesn't resolve to an ENS name. The app checks:
                      wallet address → ENS name → is it *.hedgefund-v3.eth?
                    </p>
                    <div className="bg-white p-3 rounded mt-3">
                      <p className="font-semibold mb-2">🔧 How to fix:</p>
                      <ol className="list-decimal list-inside space-y-1 text-sm">
                        <li>Go to <a href="https://app.ens.domains" target="_blank" className="text-blue-600 underline">app.ens.domains</a></li>
                        <li>Connect this wallet</li>
                        <li>Click "My Account" → "Primary ENS Name"</li>
                        <li>Select "dexter.hedgefund-v3.eth" (or your license name)</li>
                        <li>Confirm the transaction</li>
                        <li>Refresh this page after the transaction confirms</li>
                      </ol>
                    </div>
                  </div>
                </div>
              )}
            </div>

            <div className="bg-white rounded-lg shadow p-6">
              <h2 className="text-xl font-semibold mb-4">➡️ Forward ENS Resolution</h2>
              <p className="text-sm text-gray-600 mb-2">Checking if dexter.hedgefund-v3.eth resolves to your address...</p>
              {checking ? (
                <div>Checking...</div>
              ) : forwardENS ? (
                <div className="space-y-2">
                  <div className="font-mono text-sm bg-gray-100 p-3 rounded break-all">
                    dexter.hedgefund-v3.eth → {forwardENS}
                  </div>
                  {forwardENS.toLowerCase() === address?.toLowerCase() ? (
                    <div className="flex items-center gap-2 text-green-600">
                      <span className="text-2xl">✅</span>
                      <span>Forward resolution matches your address!</span>
                    </div>
                  ) : (
                    <div className="space-y-2">
                      <div className="flex items-center gap-2 text-yellow-600">
                        <span className="text-2xl">⚠️</span>
                        <span>Forward resolution points to a different address</span>
                      </div>
                      <div className="text-sm p-3 bg-yellow-50 rounded">
                        <div className="mb-1"><strong>Expected (license owner):</strong></div>
                        <div className="font-mono text-xs break-all mb-2">{forwardENS}</div>
                        <div className="mb-1"><strong>Your wallet:</strong></div>
                        <div className="font-mono text-xs break-all">{address}</div>
                        <div className="mt-2 text-yellow-700">
                          You need to connect with the wallet that owns the license! 🔑
                        </div>
                      </div>
                    </div>
                  )}
                </div>
              ) : (
                <div className="text-gray-500">No forward resolution found</div>
              )}
            </div>
          </>
        )}

        <div className="mt-8 p-4 bg-blue-50 border border-blue-300 rounded">
          <h3 className="font-semibold mb-2">💡 Understanding the Issue</h3>
          <p className="text-sm">
            The Trader App uses <strong>reverse ENS lookup</strong> to detect licenses.
            Even if forward resolution works (name → address), you MUST also set up
            reverse resolution (address → name) by setting your Primary ENS Name.
          </p>
        </div>
      </div>
    </div>
  );
}
