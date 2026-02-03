'use client';

import { IssuanceForm } from "@/components/Admin/IssuanceForm";
import { LicenseList } from "@/components/Admin/LicenseList";

export default function AdminPage() {
  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-3xl font-bold tracking-tight">Admin Dashboard</h1>
        <p className="text-muted-foreground mt-2">
          Manage institutional trading licenses and permissions.
        </p>
      </div>

      <div className="grid gap-8 md:grid-cols-2">
        <div className="md:col-span-1">
          <IssuanceForm />
        </div>
        
        <div className="md:col-span-1 border rounded-lg p-6 bg-slate-50 dark:bg-slate-900/50">
          <h3 className="font-semibold mb-4">System Status</h3>
          <div className="grid grid-cols-2 gap-4">
            <div className="p-4 bg-background rounded-md shadow-sm border">
              <div className="text-sm text-muted-foreground">Network</div>
              <div className="font-bold text-xl">Sepolia</div>
            </div>
            <div className="p-4 bg-background rounded-md shadow-sm border">
              <div className="text-sm text-muted-foreground">Total Licenses</div>
              <div className="font-bold text-xl">12</div>
            </div>
          </div>
        </div>
      </div>

      <LicenseList />
    </div>
  );
}
