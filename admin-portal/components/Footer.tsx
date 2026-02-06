'use client';

import LogoLoop from './LogoLoop';
import { 
  SiEthereum,
  SiSolidity,
  SiReact,
  SiNextdotjs,
  SiTypescript,
  SiTailwindcss,
  SiVercel,
  SiGithub
} from 'react-icons/si';

const techStack = [
  { node: <SiEthereum className="text-[#627EEA]" />, title: "Ethereum", href: "https://ethereum.org" },
  { node: <SiSolidity className="text-gray-300" />, title: "Solidity", href: "https://soliditylang.org" },
  { node: <SiReact className="text-[#61DAFB]" />, title: "React", href: "https://react.dev" },
  { node: <SiNextdotjs className="text-white" />, title: "Next.js", href: "https://nextjs.org" },
  { node: <SiTypescript className="text-[#3178C6]" />, title: "TypeScript", href: "https://www.typescriptlang.org" },
  { node: <SiTailwindcss className="text-[#06B6D4]" />, title: "Tailwind CSS", href: "https://tailwindcss.com" },
  { node: <SiVercel className="text-white" />, title: "Vercel", href: "https://vercel.com" },
  { node: <SiGithub className="text-white" />, title: "GitHub", href: "https://github.com" },
];

const partners = [
  { node: <div className="text-purple-400 font-bold text-xl">ENS Domains</div>, title: "ENS", href: "https://ens.domains" },
  { node: <div className="text-cyan-400 font-bold text-xl">Arc Protocol</div>, title: "Arc", href: "https://arc.net" },
  { node: <div className="text-yellow-400 font-bold text-xl">Yellow Network</div>, title: "Yellow", href: "https://yellow.org" },
  { node: <div className="text-pink-400 font-bold text-xl">Uniswap v4</div>, title: "Uniswap", href: "https://uniswap.org" },
];

interface FooterProps {
  variant?: 'tech' | 'partners' | 'both';
  className?: string;
}

export default function Footer({ variant = 'both', className = '' }: FooterProps) {
  const currentYear = new Date().getFullYear();

  return (
    <footer className={`bg-gray-900 border-t border-gray-800 ${className}`}>
      {/* Logo Loop Section */}
      {variant !== 'partners' && (
        <div className="border-b border-gray-800 py-8">
          <div className="container mx-auto px-4">
            <h3 className="text-sm font-semibold text-gray-400 text-center mb-6 uppercase tracking-wider">
              Built With
            </h3>
            <div style={{ height: '80px', position: 'relative', overflow: 'hidden' }}>
              <LogoLoop
                logos={techStack}
                speed={80}
                direction="left"
                logoHeight={40}
                gap={50}
                pauseOnHover
                scaleOnHover
                fadeOut
                fadeOutColor="#111827"
                ariaLabel="Technology stack"
              />
            </div>
          </div>
        </div>
      )}

      {variant !== 'tech' && (
        <div className="border-b border-gray-800 py-8">
          <div className="container mx-auto px-4">
            <h3 className="text-sm font-semibold text-gray-400 text-center mb-6 uppercase tracking-wider">
              Powered By
            </h3>
            <div style={{ height: '80px', position: 'relative', overflow: 'hidden' }}>
              <LogoLoop
                logos={partners}
                speed={60}
                direction="right"
                logoHeight={35}
                gap={70}
                pauseOnHover
                scaleOnHover
                fadeOut
                fadeOutColor="#111827"
                ariaLabel="Partner organizations"
              />
            </div>
          </div>
        </div>
      )}

      {/* Footer Content */}
      <div className="container mx-auto px-4 py-12">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-8 mb-8">
          {/* About */}
          <div>
            <h4 className="text-white font-bold text-lg mb-4">PermitPool</h4>
            <p className="text-gray-400 text-sm leading-relaxed">
              Institutional DeFi with ENS-based licensing. Trade with confidence on Uniswap v4.
            </p>
          </div>

          {/* Product */}
          <div>
            <h4 className="text-white font-semibold mb-4">Product</h4>
            <ul className="space-y-2">
              <li>
                <a href="/features" className="text-gray-400 hover:text-white text-sm transition-colors">
                  Features
                </a>
              </li>
              <li>
                <a href="/pricing" className="text-gray-400 hover:text-white text-sm transition-colors">
                  Pricing
                </a>
              </li>
              <li>
                <a href="/docs" className="text-gray-400 hover:text-white text-sm transition-colors">
                  Documentation
                </a>
              </li>
              <li>
                <a href="/api" className="text-gray-400 hover:text-white text-sm transition-colors">
                  API
                </a>
              </li>
            </ul>
          </div>

          {/* Resources */}
          <div>
            <h4 className="text-white font-semibold mb-4">Resources</h4>
            <ul className="space-y-2">
              <li>
                <a href="/blog" className="text-gray-400 hover:text-white text-sm transition-colors">
                  Blog
                </a>
              </li>
              <li>
                <a href="/guides" className="text-gray-400 hover:text-white text-sm transition-colors">
                  Guides
                </a>
              </li>
              <li>
                <a href="/support" className="text-gray-400 hover:text-white text-sm transition-colors">
                  Support
                </a>
              </li>
              <li>
                <a href="/status" className="text-gray-400 hover:text-white text-sm transition-colors">
                  Status
                </a>
              </li>
            </ul>
          </div>

          {/* Legal */}
          <div>
            <h4 className="text-white font-semibold mb-4">Legal</h4>
            <ul className="space-y-2">
              <li>
                <a href="/privacy" className="text-gray-400 hover:text-white text-sm transition-colors">
                  Privacy Policy
                </a>
              </li>
              <li>
                <a href="/terms" className="text-gray-400 hover:text-white text-sm transition-colors">
                  Terms of Service
                </a>
              </li>
              <li>
                <a href="/cookies" className="text-gray-400 hover:text-white text-sm transition-colors">
                  Cookie Policy
                </a>
              </li>
              <li>
                <a href="/licenses" className="text-gray-400 hover:text-white text-sm transition-colors">
                  Licenses
                </a>
              </li>
            </ul>
          </div>
        </div>

        {/* Bottom Bar */}
        <div className="pt-8 border-t border-gray-800 flex flex-col md:flex-row justify-between items-center">
          <p className="text-gray-400 text-sm mb-4 md:mb-0">
            © {currentYear} PermitPool. All rights reserved.
          </p>
          <div className="flex space-x-6">
            <a
              href="https://github.com"
              target="_blank"
              rel="noopener noreferrer"
              className="text-gray-400 hover:text-white transition-colors"
              aria-label="GitHub"
            >
              <SiGithub className="w-5 h-5" />
            </a>
            <a
              href="https://twitter.com"
              target="_blank"
              rel="noopener noreferrer"
              className="text-gray-400 hover:text-white transition-colors"
              aria-label="Twitter"
            >
              <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z" />
              </svg>
            </a>
            <a
              href="https://discord.com"
              target="_blank"
              rel="noopener noreferrer"
              className="text-gray-400 hover:text-white transition-colors"
              aria-label="Discord"
            >
              <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                <path d="M20.317 4.37a19.791 19.791 0 0 0-4.885-1.515a.074.074 0 0 0-.079.037c-.21.375-.444.864-.608 1.25a18.27 18.27 0 0 0-5.487 0a12.64 12.64 0 0 0-.617-1.25a.077.077 0 0 0-.079-.037A19.736 19.736 0 0 0 3.677 4.37a.07.07 0 0 0-.032.027C.533 9.046-.32 13.58.099 18.057a.082.082 0 0 0 .031.057a19.9 19.9 0 0 0 5.993 3.03a.078.078 0 0 0 .084-.028a14.09 14.09 0 0 0 1.226-1.994a.076.076 0 0 0-.041-.106a13.107 13.107 0 0 1-1.872-.892a.077.077 0 0 1-.008-.128a10.2 10.2 0 0 0 .372-.292a.074.074 0 0 1 .077-.01c3.928 1.793 8.18 1.793 12.062 0a.074.074 0 0 1 .078.01c.12.098.246.198.373.292a.077.077 0 0 1-.006.127a12.299 12.299 0 0 1-1.873.892a.077.077 0 0 0-.041.107c.36.698.772 1.362 1.225 1.993a.076.076 0 0 0 .084.028a19.839 19.839 0 0 0 6.002-3.03a.077.077 0 0 0 .032-.054c.5-5.177-.838-9.674-3.549-13.66a.061.061 0 0 0-.031-.03zM8.02 15.33c-1.183 0-2.157-1.085-2.157-2.419c0-1.333.956-2.419 2.157-2.419c1.21 0 2.176 1.096 2.157 2.42c0 1.333-.956 2.418-2.157 2.418zm7.975 0c-1.183 0-2.157-1.085-2.157-2.419c0-1.333.955-2.419 2.157-2.419c1.21 0 2.176 1.096 2.157 2.42c0 1.333-.946 2.418-2.157 2.418z" />
              </svg>
            </a>
          </div>
        </div>
      </div>
    </footer>
  );
}
