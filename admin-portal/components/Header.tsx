'use client';

import { useState } from 'react';
import Link from 'next/link';
import { ConnectButton } from '@rainbow-me/rainbowkit';
import { Menu, X } from 'lucide-react';

export function Header() {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  const navLinks = [
    { href: '/admin', label: 'Dashboard' },
    { href: '/admin/licenses', label: 'Licenses' },
    { href: '/admin/payments', label: 'Payments' },
    { href: '/admin/analytics', label: 'Analytics' },
  ];

  return (
    <header className="sticky top-0 z-50 glass border-b border-white/10">
      <div className="container mx-auto px-4 sm:px-6 py-3 sm:py-4">
        <div className="flex items-center justify-between">
          {/* Logo */}
          <Link href="/" className="text-lg sm:text-2xl font-bold gradient-text hover-lift flex-shrink-0">
            PermitPool Admin
          </Link>
          
          {/* Desktop Navigation */}
          <nav className="hidden md:flex gap-4 lg:gap-6">
            {navLinks.map((link) => (
              <Link
                key={link.href}
                href={link.href}
                className="text-gray-400 hover:text-primary transition-smooth font-medium text-xs lg:text-sm"
              >
                {link.label}
              </Link>
            ))}
          </nav>

          {/* Desktop Connect Button */}
          <div className="hidden md:block transform-gpu">
            <ConnectButton />
          </div>

          {/* Mobile Menu Button */}
          <button
            onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
            className="md:hidden p-2 text-gray-400 hover:text-primary transition-smooth touch-target"
            aria-label="Toggle menu"
          >
            {mobileMenuOpen ? <X className="h-6 w-6" /> : <Menu className="h-6 w-6" />}
          </button>
        </div>

        {/* Mobile Navigation */}
        {mobileMenuOpen && (
          <div className="md:hidden mt-4 pb-4 animate-fade-in">
            <nav className="flex flex-col gap-3">
              {navLinks.map((link) => (
                <Link
                  key={link.href}
                  href={link.href}
                  onClick={() => setMobileMenuOpen(false)}
                  className="text-gray-400 hover:text-primary transition-smooth font-medium py-2 px-3 rounded-lg hover:bg-white/5 touch-target"
                >
                  {link.label}
                </Link>
              ))}
            </nav>
            <div className="mt-4 pt-4 border-t border-white/10">
              <ConnectButton />
            </div>
          </div>
        )}
      </div>
    </header>
  );
}
