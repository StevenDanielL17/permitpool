'use client';

import { useState } from 'react';
import { useWriteContract, useWaitForTransactionReceipt } from 'wagmi';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { CheckCircle2, XCircle, AlertCircle } from 'lucide-react';
import { CONTRACTS } from '@/lib/contracts/addresses';
import { HOOK_ABI } from '@/lib/contracts/abis';
import { toast } from 'sonner';

interface License {
  subdomain: string;
  owner: string;
  node: `0x${string}`;
  status: 'active' | 'revoked';
  issuedAt: string;
  arcCredential?: string;
}

export function LicenseList() {
  const [selectedLicense, setSelectedLicense] = useState<License | null>(null);
  const [revokeConfirm, setRevokeConfirm] = useState<License | null>(null);

  const { writeContract, data: hash, isPending: isRevoking } = useWriteContract();
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({
    hash,
  });

  // Mock licenses - in production, fetch from contract events or indexer
  const licenses: License[] = [
    {
      subdomain: 'alice',
      owner: '0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb',
      node: '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef' as `0x${string}`,
      status: 'active',
      issuedAt: '2024-01-15',
      arcCredential: 'arc_cred_alice_123',
    },
    {
      subdomain: 'bob',
      owner: '0x8ba1f109551bD432803012645Ac136ddd64DBA72',
      node: '0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890' as `0x${string}`,
      status: 'active',
      issuedAt: '2024-01-16',
      arcCredential: 'arc_cred_bob_456',
    },
  ];

  const handleRevokeLicense = async (license: License) => {
    if (!license.node) {
      toast.error('License node not available');
      return;
    }

    try {
      writeContract({
        address: CONTRACTS.HOOK,
        abi: HOOK_ABI,
        functionName: 'revokeLicense',
        args: [license.node],
      });

      toast.success('Revocation transaction submitted');
      setRevokeConfirm(null);
    } catch (error) {
      console.error('Error revoking license:', error);
      toast.error('Failed to revoke license');
    }
  };

  if (isSuccess) {
    setSelectedLicense(null);
    toast.success('License revoked successfully!');
  }

  return (
    <>
      <Card>
        <CardHeader>
          <CardTitle>Active Licenses</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {licenses.length === 0 ? (
              <p className="text-gray-600 text-center py-8">No licenses issued yet</p>
            ) : (
              licenses.map((license) => (
                <div
                  key={license.subdomain}
                  className="flex items-center justify-between p-4 border rounded-lg hover:bg-gray-50 transition"
                >
                  <div className="flex-1">
                    <h4 className="font-medium">{license.subdomain}.fund.eth</h4>
                    <p className="text-sm text-gray-600">
                      {license.owner.slice(0, 10)}...{license.owner.slice(-8)}
                    </p>
                    <p className="text-xs text-gray-500">Issued: {license.issuedAt}</p>
                  </div>
                  <div className="flex items-center gap-2">
                    {license.status === 'active' ? (
                      <Badge variant="default" className="gap-1">
                        <CheckCircle2 className="h-3 w-3" />
                        Active
                      </Badge>
                    ) : (
                      <Badge variant="destructive" className="gap-1">
                        <XCircle className="h-3 w-3" />
                        Revoked
                      </Badge>
                    )}
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => setSelectedLicense(license)}
                    >
                      Details
                    </Button>
                    {license.status === 'active' && (
                      <Button
                        variant="destructive"
                        size="sm"
                        onClick={() => setRevokeConfirm(license)}
                        disabled={isRevoking || isConfirming}
                      >
                        {isRevoking || isConfirming ? 'Revoking...' : 'Revoke'}
                      </Button>
                    )}
                  </div>
                </div>
              ))
            )}
          </div>
        </CardContent>
      </Card>

      {/* Details Modal */}
      <Dialog open={!!selectedLicense} onOpenChange={(open) => !open && setSelectedLicense(null)}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>License Details</DialogTitle>
            <DialogDescription>
              View comprehensive license information
            </DialogDescription>
          </DialogHeader>

          {selectedLicense && (
            <div className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="text-sm font-medium text-gray-600">Subdomain</label>
                  <p className="text-sm font-mono">{selectedLicense.subdomain}.fund.eth</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-gray-600">Status</label>
                  <div className="mt-1">
                    <Badge
                      variant={selectedLicense.status === 'active' ? 'default' : 'destructive'}
                    >
                      {selectedLicense.status}
                    </Badge>
                  </div>
                </div>
              </div>

              <div>
                <label className="text-sm font-medium text-gray-600">Owner Address</label>
                <p className="text-sm font-mono break-all">{selectedLicense.owner}</p>
              </div>

              <div>
                <label className="text-sm font-medium text-gray-600">ENS Node</label>
                <p className="text-sm font-mono break-all">{selectedLicense.node}</p>
              </div>

              <div>
                <label className="text-sm font-medium text-gray-600">Arc Credential</label>
                <p className="text-sm font-mono">{selectedLicense.arcCredential || 'N/A'}</p>
              </div>

              <div>
                <label className="text-sm font-medium text-gray-600">Issued Date</label>
                <p className="text-sm">{selectedLicense.issuedAt}</p>
              </div>

              <Alert className="border-blue-200 bg-blue-50">
                <CheckCircle2 className="h-4 w-4 text-blue-600" />
                <AlertDescription className="text-blue-800">
                  This license is protected by ENS fuses and cannot be transferred.
                </AlertDescription>
              </Alert>

              <div className="flex gap-2">
                <Button
                  variant="outline"
                  className="flex-1"
                  onClick={() => setSelectedLicense(null)}
                >
                  Close
                </Button>
                {selectedLicense.status === 'active' && (
                  <Button
                    variant="destructive"
                    className="flex-1"
                    onClick={() => {
                      setSelectedLicense(null);
                      setRevokeConfirm(selectedLicense);
                    }}
                  >
                    Revoke License
                  </Button>
                )}
              </div>
            </div>
          )}
        </DialogContent>
      </Dialog>

      {/* Revoke Confirmation Modal */}
      <Dialog open={!!revokeConfirm} onOpenChange={(open) => !open && setRevokeConfirm(null)}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Revoke License</DialogTitle>
            <DialogDescription>
              This action cannot be undone
            </DialogDescription>
          </DialogHeader>

          {revokeConfirm && (
            <div className="space-y-4">
              <Alert variant="destructive">
                <AlertCircle className="h-4 w-4" />
                <AlertDescription>
                  Are you sure you want to revoke the license for{' '}
                  <strong>{revokeConfirm.subdomain}.fund.eth</strong>? The holder will no longer
                  be able to trade on this pool.
                </AlertDescription>
              </Alert>

              <div className="bg-gray-50 p-3 rounded text-sm">
                <p className="font-medium mb-1">License Details:</p>
                <p>Subdomain: {revokeConfirm.subdomain}</p>
                <p>Owner: {revokeConfirm.owner.slice(0, 10)}...{revokeConfirm.owner.slice(-8)}</p>
              </div>

              {hash && (
                <div className="text-sm text-gray-600">
                  Transaction:{' '}
                  <a
                    href={`https://sepolia.etherscan.io/tx/${hash}`}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-blue-600 hover:underline"
                  >
                    {hash.slice(0, 10)}...{hash.slice(-8)}
                  </a>
                </div>
              )}

              <div className="flex gap-2">
                <Button
                  variant="outline"
                  className="flex-1"
                  onClick={() => setRevokeConfirm(null)}
                  disabled={isRevoking || isConfirming}
                >
                  Cancel
                </Button>
                <Button
                  variant="destructive"
                  className="flex-1"
                  onClick={() => handleRevokeLicense(revokeConfirm)}
                  disabled={isRevoking || isConfirming}
                >
                  {isRevoking || isConfirming ? 'Revoking...' : 'Confirm Revoke'}
                </Button>
              </div>
            </div>
          )}
        </DialogContent>
      </Dialog>
    </>
  );
}
