'use client';

import LogoLoop from '@/components/LogoLoop';
import { 
  SiReact, 
  SiNextdotjs, 
  SiTypescript, 
  SiTailwindcss,
  SiEthereum,
  SiSolidity,
  SiVercel,
  SiGithub,
  SiNodedotjs,
  SiVite
} from 'react-icons/si';

const techLogos = [
  { node: <SiReact className="text-[#61DAFB]" />, title: "React", href: "https://react.dev" },
  { node: <SiNextdotjs className="text-white" />, title: "Next.js", href: "https://nextjs.org" },
  { node: <SiTypescript className="text-[#3178C6]" />, title: "TypeScript", href: "https://www.typescriptlang.org" },
  { node: <SiTailwindcss className="text-[#06B6D4]" />, title: "Tailwind CSS", href: "https://tailwindcss.com" },
  { node: <SiEthereum className="text-[#627EEA]" />, title: "Ethereum", href: "https://ethereum.org" },
  { node: <SiSolidity className="text-[#363636]" />, title: "Solidity", href: "https://soliditylang.org" },
  { node: <SiVercel className="text-white" />, title: "Vercel", href: "https://vercel.com" },
  { node: <SiGithub className="text-white" />, title: "GitHub", href: "https://github.com" },
  { node: <SiNodedotjs className="text-[#339933]" />, title: "Node.js", href: "https://nodejs.org" },
  { node: <SiVite className="text-[#646CFF]" />, title: "Vite", href: "https://vitejs.dev" },
];

const partnerLogos = [
  { node: <div className="text-purple-400 font-bold text-2xl">ENS</div>, title: "ENS Domains", href: "https://ens.domains" },
  { node: <div className="text-cyan-400 font-bold text-2xl">Arc</div>, title: "Arc Protocol", href: "https://arc.net" },
  { node: <div className="text-pink-400 font-bold text-2xl">Yellow</div>, title: "Yellow Network", href: "https://yellow.org" },
  { node: <div className="text-blue-400 font-bold text-2xl">Uniswap</div>, title: "Uniswap", href: "https://uniswap.org" },
  { node: <div className="text-green-400 font-bold text-2xl">Sepolia</div>, title: "Sepolia Testnet" },
];

export default function LogoLoopDemo() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-purple-900 to-gray-900 py-20">
      <div className="container mx-auto px-4">
        <h1 className="text-5xl font-bold text-white text-center mb-4">
          LogoLoop Component
        </h1>
        <p className="text-gray-300 text-center mb-16 text-lg">
          Infinite scrolling logo carousel with smooth animations
        </p>

        {/* Horizontal Loop - Left */}
        <section className="mb-20">
          <h2 className="text-3xl font-bold text-white mb-6">Horizontal Scroll (Left)</h2>
          <div className="bg-gray-800/50 rounded-2xl p-8 backdrop-blur-sm border border-purple-500/30">
            <h3 className="text-xl font-semibold text-white mb-6">Tech Stack</h3>
            <div style={{ height: '120px', position: 'relative', overflow: 'hidden' }}>
              <LogoLoop
                logos={techLogos}
                speed={100}
                direction="left"
                logoHeight={60}
                gap={60}
                hoverSpeed={0}
                scaleOnHover
                fadeOut
                fadeOutColor="#1f2937"
                ariaLabel="Technology stack"
              />
            </div>
          </div>
        </section>

        {/* Horizontal Loop - Right */}
        <section className="mb-20">
          <h2 className="text-3xl font-bold text-white mb-6">Horizontal Scroll (Right)</h2>
          <div className="bg-gray-800/50 rounded-2xl p-8 backdrop-blur-sm border border-cyan-500/30">
            <h3 className="text-xl font-semibold text-white mb-6">Partners</h3>
            <div style={{ height: '120px', position: 'relative', overflow: 'hidden' }}>
              <LogoLoop
                logos={partnerLogos}
                speed={80}
                direction="right"
                logoHeight={50}
                gap={80}
                pauseOnHover
                scaleOnHover
                fadeOut
                fadeOutColor="#1f2937"
                ariaLabel="Partner organizations"
              />
            </div>
          </div>
        </section>

        {/* Fast Scroll */}
        <section className="mb-20">
          <h2 className="text-3xl font-bold text-white mb-6">Fast Scroll with Deceleration</h2>
          <div className="bg-gray-800/50 rounded-2xl p-8 backdrop-blur-sm border border-pink-500/30">
            <h3 className="text-xl font-semibold text-white mb-6">Hover to Slow Down</h3>
            <div style={{ height: '120px', position: 'relative', overflow: 'hidden' }}>
              <LogoLoop
                logos={techLogos}
                speed={200}
                direction="left"
                logoHeight={60}
                gap={50}
                hoverSpeed={30}
                scaleOnHover
                fadeOut
                fadeOutColor="#1f2937"
                ariaLabel="Fast scrolling logos"
              />
            </div>
          </div>
        </section>

        {/* Compact Version */}
        <section className="mb-20">
          <h2 className="text-3xl font-bold text-white mb-6">Compact Version</h2>
          <div className="bg-gray-800/50 rounded-2xl p-6 backdrop-blur-sm border border-purple-500/30">
            <div style={{ height: '80px', position: 'relative', overflow: 'hidden' }}>
              <LogoLoop
                logos={techLogos}
                speed={120}
                direction="left"
                logoHeight={40}
                gap={40}
                pauseOnHover
                fadeOut
                fadeOutColor="#1f2937"
                ariaLabel="Compact logo display"
              />
            </div>
          </div>
        </section>

        {/* Usage Examples */}
        <section>
          <h2 className="text-3xl font-bold text-white mb-6">Usage Examples</h2>
          <div className="bg-gray-800/50 rounded-2xl p-8 backdrop-blur-sm border border-purple-500/30">
            <div className="space-y-8">
              <div>
                <h3 className="text-xl font-semibold text-white mb-4">Basic Usage</h3>
                <pre className="bg-gray-900 p-4 rounded-lg overflow-x-auto">
                  <code className="text-sm text-gray-300">{`import LogoLoop from '@/components/LogoLoop';
import { SiReact, SiNextdotjs } from 'react-icons/si';

const logos = [
  { node: <SiReact />, title: "React", href: "https://react.dev" },
  { node: <SiNextdotjs />, title: "Next.js", href: "https://nextjs.org" },
];

<div style={{ height: '120px' }}>
  <LogoLoop
    logos={logos}
    speed={100}
    direction="left"
    logoHeight={60}
    gap={60}
    pauseOnHover
    scaleOnHover
    fadeOut
  />
</div>`}</code>
                </pre>
              </div>

              <div>
                <h3 className="text-xl font-semibold text-white mb-4">With Images</h3>
                <pre className="bg-gray-900 p-4 rounded-lg overflow-x-auto">
                  <code className="text-sm text-gray-300">{`const imageLogos = [
  { src: "/logos/company1.png", alt: "Company 1", href: "https://company1.com" },
  { src: "/logos/company2.png", alt: "Company 2", href: "https://company2.com" },
];

<LogoLoop
  logos={imageLogos}
  speed={80}
  direction="right"
  logoHeight={50}
  gap={80}
  fadeOut
  fadeOutColor="#ffffff"
/>`}</code>
                </pre>
              </div>

              <div>
                <h3 className="text-xl font-semibold text-white mb-4">Props</h3>
                <div className="bg-gray-900 p-6 rounded-lg">
                  <table className="w-full text-sm text-gray-300">
                    <thead>
                      <tr className="border-b border-gray-700">
                        <th className="text-left py-2 pr-4">Prop</th>
                        <th className="text-left py-2 pr-4">Type</th>
                        <th className="text-left py-2 pr-4">Default</th>
                        <th className="text-left py-2">Description</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-800">
                      <tr>
                        <td className="py-2 pr-4 font-mono text-purple-400">logos</td>
                        <td className="py-2 pr-4">LogoItem[]</td>
                        <td className="py-2 pr-4">required</td>
                        <td className="py-2">Array of logo items</td>
                      </tr>
                      <tr>
                        <td className="py-2 pr-4 font-mono text-purple-400">speed</td>
                        <td className="py-2 pr-4">number</td>
                        <td className="py-2 pr-4">120</td>
                        <td className="py-2">Scroll speed in px/s</td>
                      </tr>
                      <tr>
                        <td className="py-2 pr-4 font-mono text-purple-400">direction</td>
                        <td className="py-2 pr-4">string</td>
                        <td className="py-2 pr-4">&apos;left&apos;</td>
                        <td className="py-2">left | right | up | down</td>
                      </tr>
                      <tr>
                        <td className="py-2 pr-4 font-mono text-purple-400">logoHeight</td>
                        <td className="py-2 pr-4">number</td>
                        <td className="py-2 pr-4">28</td>
                        <td className="py-2">Height of logos in px</td>
                      </tr>
                      <tr>
                        <td className="py-2 pr-4 font-mono text-purple-400">gap</td>
                        <td className="py-2 pr-4">number</td>
                        <td className="py-2 pr-4">32</td>
                        <td className="py-2">Gap between logos in px</td>
                      </tr>
                      <tr>
                        <td className="py-2 pr-4 font-mono text-purple-400">pauseOnHover</td>
                        <td className="py-2 pr-4">boolean</td>
                        <td className="py-2 pr-4">false</td>
                        <td className="py-2">Pause on hover</td>
                      </tr>
                      <tr>
                        <td className="py-2 pr-4 font-mono text-purple-400">hoverSpeed</td>
                        <td className="py-2 pr-4">number</td>
                        <td className="py-2 pr-4">-</td>
                        <td className="py-2">Speed when hovering</td>
                      </tr>
                      <tr>
                        <td className="py-2 pr-4 font-mono text-purple-400">scaleOnHover</td>
                        <td className="py-2 pr-4">boolean</td>
                        <td className="py-2 pr-4">false</td>
                        <td className="py-2">Scale logos on hover</td>
                      </tr>
                      <tr>
                        <td className="py-2 pr-4 font-mono text-purple-400">fadeOut</td>
                        <td className="py-2 pr-4">boolean</td>
                        <td className="py-2 pr-4">false</td>
                        <td className="py-2">Fade edges</td>
                      </tr>
                      <tr>
                        <td className="py-2 pr-4 font-mono text-purple-400">fadeOutColor</td>
                        <td className="py-2 pr-4">string</td>
                        <td className="py-2 pr-4">auto</td>
                        <td className="py-2">Fade color (hex)</td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          </div>
        </section>
      </div>
    </div>
  );
}
