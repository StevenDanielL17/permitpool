'use client';

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { CheckCircle2, XCircle } from 'lucide-react';

export function LicenseList() {
  // Simplified version - in production, query events or use an indexer
  const licenses = [
    {
      subdomain: 'agent1',
      owner: '0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb',
      status: 'active' as const,
      issuedAt: '2024-01-15',
    },
    // Add more from events or indexer
  ];

  return (
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
                className="flex items-center justify-between p-4 border rounded-lg"
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
                  <Button variant="outline" size="sm">
                    Details
                  </Button>
                  <Button variant="destructive" size="sm">
                    Revoke
                  </Button>
                </div>
              </div>
            ))
          )}
        </div>
      </CardContent>
    </Card>
  );
}
