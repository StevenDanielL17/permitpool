import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
import './globals.css';
import '@rainbow-me/rainbowkit/styles.css';
import { Providers } from '@/components/Providers';
import Link from 'next/link';
import { ConnectButton } from '@/components/ConnectButton';

const inter = Inter({ subsets: ['latin'] });

export const metadata: Metadata = {
  title: 'PermitPool',
  description: 'Institutional DeFi with ENS & Arc ID',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className={inter.className}>
        <Providers>
          <div className="flex h-screen flex-col">
            <header className="border-b">
              <div className="container flex h-16 items-center justify-between px-4">
                <div className="flex items-center gap-6">
                  <Link href="/" className="text-xl font-bold">
                    PermitPool
                  </Link>
                  <nav className="flex gap-4">
                    <Link href="/trade" className="text-sm font-medium hover:text-primary">
                      Trade
                    </Link>
                    <Link href="/admin" className="text-sm font-medium hover:text-primary">
                      Admin
                    </Link>
                  </nav>
                </div>
                <ConnectButton />
              </div>
            </header>
            <main className="flex-1 container py-6 mx-auto">
              {children}
            </main>
          </div>
        </Providers>
      </body>
    </html>
  );
}
