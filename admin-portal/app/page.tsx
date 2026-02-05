import Link from 'next/link';
import { Button } from '@/components/ui/button';
import { ArrowRight, Shield, Users, Key, FileCheck } from 'lucide-react';

export default function Home() {
  return (
    <div className="relative">
      {/* Hero Section */}
      <div className="container mx-auto px-6 py-32 animate-fade-in">
        <div className="max-w-5xl">
          <h1 className="text-7xl md:text-8xl font-bold tracking-tight leading-none mb-8">
            License
            <br />
            <span className="gradient-text">Management.</span>
          </h1>
          
          <div className="flex items-start gap-3 mb-12">
            <div className="w-1 h-6 bg-primary mt-1" />
            <p className="text-xl md:text-2xl text-gray-400 max-w-2xl">
              Issue non-transferable trading licenses secured by ENS fuses.
              Manage trader access and compliance with institutional controls.
            </p>
          </div>

          <Link href="/admin">
            <Button 
              size="lg" 
              className="text-lg px-8 py-6 glow-blue-sm hover-lift group"
            >
              Go to Dashboard
              <ArrowRight className="ml-2 h-5 w-5 group-hover:translate-x-1 transition-transform" />
            </Button>
          </Link>
        </div>
      </div>

      {/* Features Grid */}
      <div className="container mx-auto px-6 py-20">
        <div className="grid md:grid-cols-2 gap-8 max-w-6xl">
          {/* Feature 1 */}
          <div className="glass rounded-xl p-8 border-dashed-sui hover-lift transform-gpu">
            <div className="flex items-center gap-4 mb-4">
              <div className="mono-number text-sm text-gray-500">01</div>
              <Key className="h-6 w-6 text-primary" />
            </div>
            <h3 className="text-2xl font-bold mb-3">Issue Licenses</h3>
            <p className="text-gray-400 leading-relaxed">
              Create ENS-based trading licenses with Arc DID verification.
              Each license is non-transferable and bound to a verified address.
            </p>
          </div>

          {/* Feature 2 */}
          <div className="glass rounded-xl p-8 border-dashed-sui hover-lift transform-gpu">
            <div className="flex items-center gap-4 mb-4">
              <div className="mono-number text-sm text-gray-500">02</div>
              <Users className="h-6 w-6 text-primary" />
            </div>
            <h3 className="text-2xl font-bold mb-3">Manage Traders</h3>
            <p className="text-gray-400 leading-relaxed">
              View all active licenses, revoke access when needed, and maintain
              complete control over who can trade in your pools.
            </p>
          </div>

          {/* Feature 3 */}
          <div className="glass rounded-xl p-8 border-dashed-sui hover-lift transform-gpu">
            <div className="flex items-center gap-4 mb-4">
              <div className="mono-number text-sm text-gray-500">03</div>
              <Shield className="h-6 w-6 text-primary" />
            </div>
            <h3 className="text-2xl font-bold mb-3">Arc KYC Integration</h3>
            <p className="text-gray-400 leading-relaxed">
              Verify trader credentials through Arc DID before issuing licenses.
              Ensure compliance with institutional requirements.
            </p>
          </div>

          {/* Feature 4 */}
          <div className="glass rounded-xl p-8 border-dashed-sui hover-lift transform-gpu">
            <div className="flex items-center gap-4 mb-4">
              <div className="mono-number text-sm text-gray-500">04</div>
              <FileCheck className="h-6 w-6 text-primary" />
            </div>
            <h3 className="text-2xl font-bold mb-3">Audit Trail</h3>
            <p className="text-gray-400 leading-relaxed">
              Complete on-chain record of all license issuances and revocations.
              Full transparency for regulatory compliance.
            </p>
          </div>
        </div>
      </div>

      {/* CTA Section */}
      <div className="container mx-auto px-6 py-32">
        <div className="max-w-4xl text-center mx-auto">
          <h2 className="text-5xl md:text-6xl font-bold mb-6">
            Manage your <span className="gradient-text">institutional pool</span>
          </h2>
          <p className="text-xl text-gray-400 mb-12 max-w-2xl mx-auto">
            Control access, ensure compliance, and maintain security
          </p>
          <Link href="/admin">
            <Button 
              size="lg" 
              className="text-lg px-12 py-6 glow-blue hover-lift group"
            >
              Open Dashboard
              <ArrowRight className="ml-2 h-5 w-5 group-hover:translate-x-1 transition-transform" />
            </Button>
          </Link>
        </div>
      </div>
    </div>
  );
}
