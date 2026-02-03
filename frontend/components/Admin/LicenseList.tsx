'use client';

import { useState, useEffect } from 'react';
import { useWatchContractEvent } from 'wagmi';
import { LICENSE_MANAGER_ADDRESS, LICENSE_MANAGER_ABI, PERMIT_POOL_HOOK_ADDRESS, PERMIT_POOL_HOOK_ABI } from '@/lib/contracts/definitions';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { useWriteContract } from 'wagmi';

type License = {
  address: string;
  label: string;
  node: string;
  status: 'Active' | 'Revoked';
};

export function LicenseList() {
  // Mock initial data
  const [licenses, setLicenses] = useState<License[]>([
    { address: '0x123...abc', label: 'alice', node: '0xabc...', status: 'Active' },
    { address: '0x456...def', label: 'bob', node: '0xdef...', status: 'Revoked' },
  ]);

  // Watch for new licenses
  useWatchContractEvent({
    address: LICENSE_MANAGER_ADDRESS,
    abi: LICENSE_MANAGER_ABI,
    eventName: 'LicenseIssued',
    onLogs(logs) {
      logs.forEach(log => {
        const { licensee, label, node } = log.args;
        if (licensee && label && node) {
          setLicenses(prev => [...prev, {
            address: licensee,
            label: label,
            node: node,
            status: 'Active'
          }]);
        }
      });
    },
  });

  const { writeContract } = useWriteContract();

  const handleRevoke = (node: string) => {
    writeContract({
      address: PERMIT_POOL_HOOK_ADDRESS,
      abi: PERMIT_POOL_HOOK_ABI,
      functionName: 'revokeLicense',
      args: [node as `0x${string}`],
    });
  };

  return (
    <Card>
      <CardHeader>
        <CardTitle>Active Licenses</CardTitle>
      </CardHeader>
      <CardContent>
        <div className="rounded-md border">
          <table className="w-full text-sm text-left">
            <thead className="bg-muted font-medium">
              <tr>
                <th className="p-4">Subdomain</th>
                <th className="p-4">Owner</th>
                <th className="p-4">Status</th>
                <th className="p-4 text-right">Actions</th>
              </tr>
            </thead>
            <tbody>
              {licenses.map((license, i) => (
                <tr key={i} className="border-t hover:bg-muted/50 transition-colors">
                  <td className="p-4 font-mono">{license.label}.fund.eth</td>
                  <td className="p-4 font-mono">{license.address.slice(0, 6)}...{license.address.slice(-4)}</td>
                  <td className="p-4">
                    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                      license.status === 'Active' ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                    }`}>
                      {license.status}
                    </span>
                  </td>
                  <td className="p-4 text-right">
                    {license.status === 'Active' && (
                      <Button 
                        variant="destructive" 
                        size="sm"
                        onClick={() => handleRevoke(license.node)}
                      >
                        Revoke
                      </Button>
                    )}
                  </td>
                </tr>
              ))}
              {licenses.length === 0 && (
                <tr>
                  <td colSpan={4} className="p-4 text-center text-muted-foreground">
                    No licenses issued yet.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </CardContent>
    </Card>
  );
}
