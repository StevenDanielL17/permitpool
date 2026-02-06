'use client';

import { useRef } from 'react';
import Dither from '@/components/effects/Dither';
import LaserFlow from '@/components/effects/LaserFlow';

export default function EffectsDemo() {
  const revealImgRef = useRef<HTMLImageElement>(null);

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-purple-900 to-gray-900">
      <div className="container mx-auto px-4 py-12">
        <h1 className="text-5xl font-bold text-white text-center mb-4">
          Visual Effects Showcase
        </h1>
        <p className="text-gray-300 text-center mb-12 text-lg">
          Premium WebGL effects for an immersive experience
        </p>

        {/* Dither Effect Section */}
        <section className="mb-20">
          <h2 className="text-3xl font-bold text-white mb-6">Dither Wave Effect</h2>
          <div className="grid md:grid-cols-2 gap-8">
            {/* Example 1: Basic Dither */}
            <div className="bg-gray-800/50 rounded-2xl p-6 backdrop-blur-sm border border-purple-500/30">
              <h3 className="text-xl font-semibold text-white mb-4">Basic Wave</h3>
              <div style={{ width: '100%', height: '400px', position: 'relative', borderRadius: '12px', overflow: 'hidden' }}>
                <Dither
                  waveColor={[0.5, 0.5, 0.5]}
                  disableAnimation={false}
                  enableMouseInteraction
                  mouseRadius={0.3}
                  colorNum={4}
                  waveAmplitude={0.3}
                  waveFrequency={3}
                  waveSpeed={0.05}
                />
              </div>
            </div>

            {/* Example 2: Colorful Dither */}
            <div className="bg-gray-800/50 rounded-2xl p-6 backdrop-blur-sm border border-purple-500/30">
              <h3 className="text-xl font-semibold text-white mb-4">Purple Glow</h3>
              <div style={{ width: '100%', height: '400px', position: 'relative', borderRadius: '12px', overflow: 'hidden' }}>
                <Dither
                  waveColor={[0.8, 0.4, 1.0]}
                  disableAnimation={false}
                  enableMouseInteraction
                  mouseRadius={0.5}
                  colorNum={6}
                  waveAmplitude={0.4}
                  waveFrequency={2}
                  waveSpeed={0.08}
                />
              </div>
            </div>
          </div>
        </section>

        {/* LaserFlow Effect Section */}
        <section className="mb-20">
          <h2 className="text-3xl font-bold text-white mb-6">LaserFlow Effect</h2>
          <div className="grid md:grid-cols-2 gap-8">
            {/* Example 1: Basic LaserFlow */}
            <div className="bg-gray-800/50 rounded-2xl p-6 backdrop-blur-sm border border-cyan-500/30">
              <h3 className="text-xl font-semibold text-white mb-4">Cyan Beam</h3>
              <div style={{ height: '500px', position: 'relative', overflow: 'hidden', borderRadius: '12px', backgroundColor: '#060010' }}>
                <LaserFlow
                  color="#00D9FF"
                  horizontalBeamOffset={0.1}
                  verticalBeamOffset={0.0}
                  wispDensity={1}
                  wispSpeed={15}
                  wispIntensity={5}
                  flowSpeed={0.35}
                  flowStrength={0.25}
                  fogIntensity={0.45}
                  fogScale={0.3}
                  fogFallSpeed={0.6}
                  decay={1.1}
                  falloffStart={1.2}
                />
              </div>
            </div>

            {/* Example 2: Purple LaserFlow */}
            <div className="bg-gray-800/50 rounded-2xl p-6 backdrop-blur-sm border border-pink-500/30">
              <h3 className="text-xl font-semibold text-white mb-4">Purple Beam</h3>
              <div style={{ height: '500px', position: 'relative', overflow: 'hidden', borderRadius: '12px', backgroundColor: '#060010' }}>
                <LaserFlow
                  color="#CF9EFF"
                  horizontalBeamOffset={0.1}
                  verticalBeamOffset={0.0}
                  horizontalSizing={0.5}
                  verticalSizing={2}
                  wispDensity={1}
                  wispSpeed={15}
                  wispIntensity={5}
                  flowSpeed={0.35}
                  flowStrength={0.25}
                  fogIntensity={0.45}
                  fogScale={0.3}
                  fogFallSpeed={0.6}
                  decay={1.1}
                  falloffStart={1.2}
                />
              </div>
            </div>
          </div>
        </section>

        {/* Interactive Reveal Effect */}
        <section className="mb-20">
          <h2 className="text-3xl font-bold text-white mb-6">Interactive Reveal Effect</h2>
          <div className="bg-gray-800/50 rounded-2xl p-6 backdrop-blur-sm border border-purple-500/30">
            <h3 className="text-xl font-semibold text-white mb-4">Hover to Reveal</h3>
            <div 
              style={{ 
                height: '600px', 
                position: 'relative', 
                overflow: 'hidden',
                backgroundColor: '#060010',
                borderRadius: '12px'
              }}
              onMouseMove={(e) => {
                const rect = e.currentTarget.getBoundingClientRect();
                const x = e.clientX - rect.left;
                const y = e.clientY - rect.top;
                const el = revealImgRef.current;
                if (el) {
                  el.style.setProperty('--mx', `${x}px`);
                  el.style.setProperty('--my', `${y + rect.height * 0.5}px`);
                }
              }}
              onMouseLeave={() => {
                const el = revealImgRef.current;
                if (el) {
                  el.style.setProperty('--mx', '-9999px');
                  el.style.setProperty('--my', '-9999px');
                }
              }}
            >
              <LaserFlow
                horizontalBeamOffset={0.1}
                verticalBeamOffset={0.0}
                color="#CF9EFF"
              />
              
              <div style={{
                position: 'absolute',
                top: '50%',
                left: '50%',
                transform: 'translateX(-50%)',
                width: '86%',
                height: '60%',
                backgroundColor: '#060010',
                borderRadius: '20px',
                border: '2px solid #FF79C6',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                flexDirection: 'column',
                color: 'white',
                fontSize: '2rem',
                zIndex: 6,
                padding: '2rem'
              }}>
                <h3 className="text-4xl font-bold mb-4 bg-gradient-to-r from-purple-400 to-pink-400 bg-clip-text text-transparent">
                  PermitPool Admin
                </h3>
                <p className="text-lg text-gray-300 text-center">
                  Hover to reveal the hidden pattern
                </p>
              </div>

              <div
                ref={revealImgRef}
                style={{
                  position: 'absolute',
                  width: '100%',
                  height: '100%',
                  top: '0',
                  left: '0',
                  zIndex: 5,
                  mixBlendMode: 'lighten',
                  opacity: 0.3,
                  pointerEvents: 'none',
                  background: 'radial-gradient(circle, rgba(207,158,255,0.5) 0%, rgba(255,121,198,0.3) 50%, transparent 70%)',
                  // @ts-ignore
                  '--mx': '-9999px',
                  '--my': '-9999px',
                  WebkitMaskImage: 'radial-gradient(circle at var(--mx) var(--my), rgba(255,255,255,1) 0px, rgba(255,255,255,0.95) 60px, rgba(255,255,255,0.6) 120px, rgba(255,255,255,0.25) 180px, rgba(255,255,255,0) 240px)',
                  maskImage: 'radial-gradient(circle at var(--mx) var(--my), rgba(255,255,255,1) 0px, rgba(255,255,255,0.95) 60px, rgba(255,255,255,0.6) 120px, rgba(255,255,255,0.25) 180px, rgba(255,255,255,0) 240px)',
                  WebkitMaskRepeat: 'no-repeat',
                  maskRepeat: 'no-repeat'
                }}
              />
            </div>
          </div>
        </section>

        {/* Usage Instructions */}
        <section>
          <h2 className="text-3xl font-bold text-white mb-6">How to Use</h2>
          <div className="bg-gray-800/50 rounded-2xl p-8 backdrop-blur-sm border border-purple-500/30">
            <div className="prose prose-invert max-w-none">
              <h3 className="text-xl font-semibold text-white mb-4">Dither Effect</h3>
              <pre className="bg-gray-900 p-4 rounded-lg overflow-x-auto">
                <code className="text-sm text-gray-300">{`import Dither from '@/components/effects/Dither';

<div style={{ width: '100%', height: '600px', position: 'relative' }}>
  <Dither
    waveColor={[0.5,0.5,0.5]}
    disableAnimation={false}
    enableMouseInteraction
    mouseRadius={0.3}
    colorNum={4}
    waveAmplitude={0.3}
    waveFrequency={3}
    waveSpeed={0.05}
  />
</div>`}</code>
              </pre>

              <h3 className="text-xl font-semibold text-white mb-4 mt-8">LaserFlow Effect</h3>
              <pre className="bg-gray-900 p-4 rounded-lg overflow-x-auto">
                <code className="text-sm text-gray-300">{`import LaserFlow from '@/components/effects/LaserFlow';

<div style={{ height: '500px', position: 'relative', overflow: 'hidden' }}>
  <LaserFlow
    color="#CF9EFF"
    wispDensity={1}
    wispSpeed={15}
    wispIntensity={5}
    flowSpeed={0.35}
    flowStrength={0.25}
    fogIntensity={0.45}
  />
</div>`}</code>
              </pre>
            </div>
          </div>
        </section>
      </div>
    </div>
  );
}
