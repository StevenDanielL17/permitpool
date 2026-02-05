import Link from 'next/link';
import { Button } from '@/components/ui/button';

export default function Home() {
  return (
    <div className="flex flex-col items-center justify-center py-20 text-center">
      <h1 className="text-4xl font-bold tracking-tighter sm:text-6xl text-primary">
        PermitPool Trading
        <br />
        <span className="text-secondary-foreground">Institutional DeFi Access</span>
      </h1>
      <p className="mt-6 max-w-[600px] text-lg text-muted-foreground">
        Trade on Uniswap v4 with institutional compliance built-in.
        Your license grants you secure, auditable access to permissioned pools.
      </p>
      <div className="mt-8 flex gap-4">
        <Link href="/trade">
          <Button size="lg">Start Trading</Button>
        </Link>
      </div>
    </div>
  );
}
