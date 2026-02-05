'use client';

import Link from 'next/link';
import { ConnectButton } from '@rainbow-me/rainbowkit';

export function Header() {
  return (
    <header className="border-b bg-white">
      <div className="container mx-auto px-4 py-4 flex items-center justify-between">
        <div className="flex items-center gap-8">
          <Link href="/" className="text-2xl font-bold text-blue-600">
            PermitPool Admin
          </Link>
          <nav className="flex gap-6">
            <Link href="/admin" className="text-gray-700 hover:text-blue-600 transition-colors">
              Dashboard
            </Link>
          </nav>
        </div>
        <ConnectButton />
      </div>
    </header>
  );
}
