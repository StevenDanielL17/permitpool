import { ArrowRight, BookOpen, Wallet, TrendingUp } from 'lucide-react';
import Link from 'next/link';
import { Button } from '@/components/ui/button';

export function EmptyStateGuide() {
  return (
    <div className="glass border-dashed-sui rounded-xl p-8 text-center max-w-4xl mx-auto mt-10 animate-fade-in">
      <div className="bg-primary/10 w-20 h-20 rounded-full flex items-center justify-center mx-auto mb-6 backdrop-blur">
        <BookOpen className="w-10 h-10 text-primary" />
      </div>
      
      <h2 className="text-4xl font-bold gradient-text mb-4">Welcome to the Trading Floor</h2>
      <p className="text-gray-400 text-lg mb-10 max-w-2xl mx-auto">
        Your account is licensed and ready. You haven't made any trades yet. 
        Follow these steps to execute your first swap and start building your portfolio.
      </p>

      <div className="grid md:grid-cols-3 gap-6 text-left mb-10">
        {/* Step 1 */}
        <div className="glass bg-white/5 p-6 rounded-lg border border-white/10 hover-lift">
          <div className="flex items-center gap-3 mb-3">
            <span className="bg-primary/20 w-10 h-10 rounded-full flex items-center justify-center text-primary font-bold">
              1
            </span>
            <h3 className="text-xl font-bold text-white">Select Asset</h3>
          </div>
          <p className="text-sm text-gray-400 leading-relaxed">
            Choose between USDC and WETH from the swap interface. Each token pair has real-time pricing.
          </p>
        </div>

        {/* Step 2 */}
        <div className="glass bg-white/5 p-6 rounded-lg border border-white/10 hover-lift">
          <div className="flex items-center gap-3 mb-3">
            <span className="bg-primary/20 w-10 h-10 rounded-full flex items-center justify-center text-primary font-bold">
              2
            </span>
            <h3 className="text-xl font-bold text-white">Enter Amount</h3>
          </div>
          <p className="text-sm text-gray-400 leading-relaxed">
            Input the value you want to trade. The output amount will calculate automatically based on market rates.
          </p>
        </div>

        {/* Step 3 */}
        <div className="glass bg-white/5 p-6 rounded-lg border border-white/10 hover-lift">
          <div className="flex items-center gap-3 mb-3">
            <span className="bg-primary/20 w-10 h-10 rounded-full flex items-center justify-center text-primary font-bold">
              3
            </span>
            <h3 className="text-xl font-bold text-white">Execute Swap</h3>
          </div>
          <p className="text-sm text-gray-400 leading-relaxed">
            Click "Execute Swap" to confirm. Your trade will be verified by PermitPoolHook and saved to your history.
          </p>
        </div>
      </div>

      {/* Feature Highlights */}
      <div className="grid md:grid-cols-2 gap-4 mb-10 text-left">
        <div className="glass bg-white/5 p-4 rounded-lg border border-white/10 flex items-start gap-3">
          <TrendingUp className="w-6 h-6 text-green-500 flex-shrink-0 mt-1" />
          <div>
            <h4 className="font-semibold text-white mb-1">Real-Time Portfolio Tracking</h4>
            <p className="text-sm text-gray-400">Your trades are tracked in real-time. View P&L, holdings, and performance metrics.</p>
          </div>
        </div>
        <div className="glass bg-white/5 p-4 rounded-lg border border-white/10 flex items-start gap-3">
          <Wallet className="w-6 h-6 text-blue-500 flex-shrink-0 mt-1" />
          <div>
            <h4 className="font-semibold text-white mb-1">Personal Trading History</h4>
            <p className="text-sm text-gray-400">Every trade is saved to your wallet address. Your data, your control.</p>
          </div>
        </div>
      </div>

      <Button asChild size="lg" className="gap-2 text-lg px-8 py-6">
        <Link href="/trade">
          <Wallet className="w-5 h-5" />
          Start Trading Now
          <ArrowRight className="w-5 h-5" />
        </Link>
      </Button>

      <p className="text-xs text-gray-500 mt-6">
        💡 Tip: This is a simulation environment. Trades are stored locally per wallet address.
      </p>
    </div>
  );
}
