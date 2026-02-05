import Link from 'next/link';
import { Button } from '@/components/ui/button';

export default function Home() {
  return (
    <div className="flex flex-col items-center justify-center py-20 text-center">
      <h1 className="text-4xl font-bold tracking-tighter sm:text-6xl text-primary">
        PermitPool Admin Portal
        <br />
        <span className="text-secondary-foreground">License Management</span>
      </h1>
      <p className="mt-6 max-w-[600px] text-lg text-muted-foreground">
        Issue non-transferable trading licenses secured by ENS fuses.
        Manage trader access and compliance with institutional controls.
      </p>
      <div className="mt-8 flex gap-4">
        <Link href="/admin">
          <Button size="lg">Go to Dashboard</Button>
        </Link>
      </div>
    </div>
  );
}
