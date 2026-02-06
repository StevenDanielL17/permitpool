'use client';

import { useState, useEffect } from 'react';
import { Card } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Copy, Eye, EyeOff, User, Shield } from 'lucide-react';
import { toast } from 'sonner';

export default function DevToolbar() {
  const [mounted, setMounted] = useState(false);
  const [showKeys, setShowKeys] = useState(false);
  const [isExpanded, setIsExpanded] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  if (!mounted) return null;

  // Only show in development
  if (process.env.NODE_ENV !== 'development') return null;

  const actors = [
    {
      name: 'Admin (Deployer)',
      role: 'admin',
      address: '0x52b34414df3e56ae853bc4a0eb653231447c2a36',
      // Mock key from .env.example - FOR TESTING ONLY
      privateKey: '0xd3bf516d8e8ac899433e7b73f4c53e1747537375d732315d6a18ca4af2120421' 
    },
    {
      name: 'Alice (Trader)',
      role: 'trader',
      address: '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266', // Anvil #0
      privateKey: '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80'
    }
  ];

  const copyToClipboard = (text: string, label: string) => {
    navigator.clipboard.writeText(text);
    toast.success(`${label} copied to clipboard`);
  };

  if (!isExpanded) {
    return (
      <div className="fixed bottom-4 left-4 z-50 animate-fade-in">
        <Button 
          onClick={() => setIsExpanded(true)}
          className="bg-purple-900/80 hover:bg-purple-800 text-white border border-purple-500/50 shadow-lg backdrop-blur-md"
          size="sm"
        >
          <Shield className="w-4 h-4 mr-2" />
          Dev Tools
        </Button>
      </div>
    );
  }

  return (
    <div className="fixed bottom-4 left-4 z-50 animate-slide-up">
      <Card className="bg-gray-900/95 border-purple-500/30 backdrop-blur-xl shadow-2xl w-80">
        <div className="p-4 space-y-4">
          <div className="flex items-center justify-between pb-2 border-b border-gray-800">
            <h3 className="text-sm font-semibold text-purple-400 flex items-center gap-2">
              <Shield className="w-4 h-4" />
              Test Actors
            </h3>
            <div className="flex items-center gap-2">
              <Button
                variant="ghost"
                size="icon"
                className="h-6 w-6 text-gray-400 hover:text-white"
                onClick={() => setShowKeys(!showKeys)}
                title={showKeys ? "Hide Keys" : "Show Keys"}
              >
                {showKeys ? <EyeOff className="w-3 h-3" /> : <Eye className="w-3 h-3" />}
              </Button>
              <Button
                variant="ghost"
                size="icon"
                className="h-6 w-6 text-gray-400 hover:text-white"
                onClick={() => setIsExpanded(false)}
              >
                <span className="text-xs">✕</span>
              </Button>
            </div>
          </div>

          <div className="space-y-4">
            {actors.map((actor) => (
              <div key={actor.name} className="space-y-2">
                <div className="flex items-center justify-between">
                  <span className="text-xs font-medium text-gray-300 flex items-center gap-1.5">
                    <User className="w-3 h-3 text-purple-400" />
                    {actor.name}
                  </span>
                  <span className={`text-[10px] px-1.5 py-0.5 rounded border ${
                    actor.role === 'admin' 
                      ? 'bg-blue-500/10 border-blue-500/30 text-blue-400'
                      : 'bg-green-500/10 border-green-500/30 text-green-400'
                  }`}>
                    {actor.role.toUpperCase()}
                  </span>
                </div>
                
                {/* Address */}
                <div className="flex items-center gap-2 bg-black/40 p-1.5 rounded border border-white/5 group">
                  <div className="flex-1 truncate font-mono text-[10px] text-gray-400">
                    {actor.address}
                  </div>
                  <Button
                    variant="ghost"
                    size="icon"
                    className="h-5 w-5 opacity-0 group-hover:opacity-100 transition-opacity"
                    onClick={() => copyToClipboard(actor.address, 'Address')}
                  >
                    <Copy className="w-3 h-3 text-gray-400 hover:text-white" />
                  </Button>
                </div>

                {/* Private Key */}
                {showKeys && (
                  <div className="flex items-center gap-2 bg-red-900/10 p-1.5 rounded border border-red-500/20 group">
                    <div className="flex-1 truncate font-mono text-[10px] text-red-300/70">
                      {actor.privateKey}
                    </div>
                    <Button
                      variant="ghost"
                      size="icon"
                      className="h-5 w-5 opacity-0 group-hover:opacity-100 transition-opacity"
                      onClick={() => copyToClipboard(actor.privateKey, 'Private Key')}
                    >
                      <Copy className="w-3 h-3 text-red-400 hover:text-red-200" />
                    </Button>
                  </div>
                )}
              </div>
            ))}
          </div>

          <div className="pt-2 border-t border-gray-800">
            <p className="text-[10px] text-gray-500 text-center">
              Import keys to wallet to act as user
            </p>
          </div>
        </div>
      </Card>
    </div>
  );
}
