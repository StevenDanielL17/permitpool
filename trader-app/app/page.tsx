import Link from 'next/link';
import { Button } from '@/components/ui/button';
import { ArrowRight, Shield, Zap, Lock, CheckCircle2, Users, TrendingUp, Activity } from 'lucide-react';

export default function Home() {
  return (
    <div className="relative">
      {/* Hero Section - Sui.io style */}
      <div className="container mx-auto px-6 py-32 animate-fade-in">
        <div className="max-w-5xl">
          {/* Large bold heading like Sui.io */}
          <h1 className="text-7xl md:text-8xl font-bold tracking-tight leading-none mb-8">
            Institutional
            <br />
            <span className="gradient-text">DeFi Access.</span>
          </h1>
          
          {/* Subtitle with blue accent */}
          <div className="flex items-start gap-3 mb-12">
            <div className="w-1 h-6 bg-primary mt-1" />
            <p className="text-xl md:text-2xl text-gray-400 max-w-2xl">
              Trade on Uniswap v4 with institutional compliance built-in.
              Your license grants you secure, auditable access to permissioned pools.
            </p>
          </div>

          {/* CTA Button with glow */}
          <Link href="/trade">
            <Button 
              size="lg" 
              className="text-lg px-8 py-6 glow-blue-sm hover-lift group"
            >
              Start Trading
              <ArrowRight className="ml-2 h-5 w-5 group-hover:translate-x-1 transition-transform" />
            </Button>
          </Link>
        </div>
      </div>

      {/* Stats Section */}
      <div className="container mx-auto px-6 py-12">
        <div className="grid md:grid-cols-3 gap-6 max-w-6xl">
          <div className="glass rounded-xl p-6 border-dashed-sui text-center">
            <Activity className="h-8 w-8 text-primary mx-auto mb-3" />
            <div className="text-4xl font-bold mb-2 mono-number">100%</div>
            <div className="text-gray-400 text-sm">On-Chain Verification</div>
          </div>
          <div className="glass rounded-xl p-6 border-dashed-sui text-center">
            <Users className="h-8 w-8 text-primary mx-auto mb-3" />
            <div className="text-4xl font-bold mb-2 mono-number">24/7</div>
            <div className="text-gray-400 text-sm">Real-Time Access</div>
          </div>
          <div className="glass rounded-xl p-6 border-dashed-sui text-center">
            <TrendingUp className="h-8 w-8 text-primary mx-auto mb-3" />
            <div className="text-4xl font-bold mb-2 mono-number">v4</div>
            <div className="text-gray-400 text-sm">Uniswap Protocol</div>
          </div>
        </div>
      </div>

      {/* Features Section - Technical layout like Sui.io */}
      <div className="container mx-auto px-6 py-20">
        <div className="grid md:grid-cols-2 gap-8 max-w-6xl">
          {/* Feature Card 1 */}
          <div className="glass rounded-xl p-8 border-dashed-sui hover-lift transform-gpu">
            <div className="flex items-center gap-4 mb-4">
              <div className="mono-number text-sm text-gray-500">01</div>
              <Shield className="h-6 w-6 text-primary" />
            </div>
            <h3 className="text-2xl font-bold mb-3">License-Based Access</h3>
            <p className="text-gray-400 leading-relaxed">
              Non-transferable ENS-based licenses ensure only verified institutional
              traders can access permissioned pools. Built on Uniswap v4 hooks.
            </p>
          </div>

          {/* Feature Card 2 */}
          <div className="glass rounded-xl p-8 border-dashed-sui hover-lift transform-gpu">
            <div className="flex items-center gap-4 mb-4">
              <div className="mono-number text-sm text-gray-500">02</div>
              <Zap className="h-6 w-6 text-primary" />
            </div>
            <h3 className="text-2xl font-bold mb-3">Real-Time Verification</h3>
            <p className="text-gray-400 leading-relaxed">
              Arc DID credentials and Yellow Network payment verification happen
              on-chain, in real-time, with every swap transaction.
            </p>
          </div>
        </div>
      </div>

      {/* How It Works Section */}
      <div className="container mx-auto px-6 py-20">
        <div className="max-w-4xl">
          <div className="mb-12">
            <div className="mono-number text-sm text-gray-500 mb-4">HOW IT WORKS</div>
            <h2 className="text-5xl font-bold mb-4">Three Simple Steps</h2>
            <p className="text-xl text-gray-400">Get started with institutional DeFi trading</p>
          </div>

          <div className="space-y-6">
            {/* Step 1 */}
            <div className="glass rounded-xl p-6 border-l-4 border-primary">
              <div className="flex items-start gap-4">
                <div className="mono-number text-2xl font-bold text-primary">01</div>
                <div>
                  <h4 className="text-xl font-bold mb-2">Connect Your Wallet</h4>
                  <p className="text-gray-400">Link your institutional wallet to verify your identity and credentials.</p>
                </div>
              </div>
            </div>

            {/* Step 2 */}
            <div className="glass rounded-xl p-6 border-l-4 border-primary">
              <div className="flex items-start gap-4">
                <div className="mono-number text-2xl font-bold text-primary">02</div>
                <div>
                  <h4 className="text-xl font-bold mb-2">Verify Your License</h4>
                  <p className="text-gray-400">Your ENS-based trading license is automatically verified through Arc DID.</p>
                </div>
              </div>
            </div>

            {/* Step 3 */}
            <div className="glass rounded-xl p-6 border-l-4 border-primary">
              <div className="flex items-start gap-4">
                <div className="mono-number text-2xl font-bold text-primary">03</div>
                <div>
                  <h4 className="text-xl font-bold mb-2">Start Trading</h4>
                  <p className="text-gray-400">Access permissioned pools and execute compliant trades on Uniswap v4.</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Security Features */}
      <div className="container mx-auto px-6 py-20">
        <div className="max-w-4xl glass rounded-2xl p-12 border-dashed-sui">
          <div className="flex items-center gap-3 mb-8">
            <Lock className="h-8 w-8 text-primary" />
            <h2 className="text-4xl font-bold">Enterprise Security</h2>
          </div>
          
          <div className="grid md:grid-cols-2 gap-6">
            <div className="flex items-start gap-3">
              <CheckCircle2 className="h-6 w-6 text-green-500 flex-shrink-0 mt-1" />
              <div>
                <h4 className="font-semibold mb-1">Non-Transferable Licenses</h4>
                <p className="text-sm text-gray-400">Licenses are bound to verified addresses and cannot be transferred</p>
              </div>
            </div>
            <div className="flex items-start gap-3">
              <CheckCircle2 className="h-6 w-6 text-green-500 flex-shrink-0 mt-1" />
              <div>
                <h4 className="font-semibold mb-1">On-Chain Verification</h4>
                <p className="text-sm text-gray-400">All credentials verified directly on-chain for maximum security</p>
              </div>
            </div>
            <div className="flex items-start gap-3">
              <CheckCircle2 className="h-6 w-6 text-green-500 flex-shrink-0 mt-1" />
              <div>
                <h4 className="font-semibold mb-1">Real-Time Compliance</h4>
                <p className="text-sm text-gray-400">Every transaction checked against current license status</p>
              </div>
            </div>
            <div className="flex items-start gap-3">
              <CheckCircle2 className="h-6 w-6 text-green-500 flex-shrink-0 mt-1" />
              <div>
                <h4 className="font-semibold mb-1">Audit Trail</h4>
                <p className="text-sm text-gray-400">Complete transaction history for regulatory compliance</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Technical Details Section */}
      <div className="container mx-auto px-6 py-20">
        <div className="max-w-4xl border-dashed-sui rounded-xl p-12 glass">
          <div className="mono-number text-sm text-gray-500 mb-6">TECHNICAL STACK</div>
          <div className="grid md:grid-cols-3 gap-8">
            <div>
              <div className="text-primary font-semibold mb-2">Protocol</div>
              <div className="text-gray-400">Uniswap v4</div>
            </div>
            <div>
              <div className="text-primary font-semibold mb-2">Identity</div>
              <div className="text-gray-400">Arc DID + ENS</div>
            </div>
            <div>
              <div className="text-primary font-semibold mb-2">Payments</div>
              <div className="text-gray-400">Yellow Network</div>
            </div>
          </div>
        </div>
      </div>

      {/* CTA Section */}
      <div className="container mx-auto px-6 py-32">
        <div className="max-w-4xl text-center mx-auto">
          <h2 className="text-5xl md:text-6xl font-bold mb-6">
            Ready to start <span className="gradient-text">trading?</span>
          </h2>
          <p className="text-xl text-gray-400 mb-12 max-w-2xl mx-auto">
            Join institutional traders accessing compliant DeFi markets
          </p>
          <Link href="/trade">
            <Button 
              size="lg" 
              className="text-lg px-12 py-6 glow-blue hover-lift group"
            >
              Launch App
              <ArrowRight className="ml-2 h-5 w-5 group-hover:translate-x-1 transition-transform" />
            </Button>
          </Link>
        </div>
      </div>

      {/* Footer */}
      <footer className="border-t border-white/10 mt-20">
        <div className="container mx-auto px-6 py-12">
          <div className="grid md:grid-cols-4 gap-8 max-w-6xl">
            <div>
              <div className="text-xl font-bold gradient-text mb-4">PermitPool</div>
              <p className="text-sm text-gray-500">
                Institutional DeFi access with compliance built-in
              </p>
            </div>
            <div>
              <h4 className="font-semibold mb-4">Product</h4>
              <ul className="space-y-2 text-sm text-gray-400">
                <li><Link href="/trade" className="hover:text-primary transition-smooth">Trading</Link></li>
                <li><Link href="/" className="hover:text-primary transition-smooth">Features</Link></li>
              </ul>
            </div>
            <div>
              <h4 className="font-semibold mb-4">Technology</h4>
              <ul className="space-y-2 text-sm text-gray-400">
                <li className="hover:text-primary transition-smooth cursor-pointer">Uniswap v4</li>
                <li className="hover:text-primary transition-smooth cursor-pointer">Arc DID</li>
                <li className="hover:text-primary transition-smooth cursor-pointer">Yellow Network</li>
              </ul>
            </div>
            <div>
              <h4 className="font-semibold mb-4">Built For</h4>
              <ul className="space-y-2 text-sm text-gray-400">
                <li>ETHOnline 2026</li>
                <li className="mono-number text-xs text-gray-600">Sepolia Testnet</li>
              </ul>
            </div>
          </div>
          <div className="border-t border-white/10 mt-12 pt-8 text-center text-sm text-gray-500">
            <p>© 2026 PermitPool. Built with Uniswap v4, Arc, and Yellow Network.</p>
            <p className="mt-2 text-xs text-gray-600">Built by <span className="text-primary font-semibold">Steve</span></p>
          </div>
        </div>
      </footer>
    </div>
  );
}
