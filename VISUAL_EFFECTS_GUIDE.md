# Visual Effects Integration Guide

## Overview

This guide covers the integration of premium WebGL visual effects into the PermitPool project, including Dither and LaserFlow components.

## Installation

The following packages have been installed in both `admin-portal` and `trader-app`:

```bash
npm install three postprocessing @react-three/fiber @react-three/postprocessing
```

## Components

### 1. Dither Effect

**Location**: `components/effects/Dither.tsx`

A retro-style dithered wave effect with mouse interaction capabilities.

#### Features:

- Perlin noise-based wave patterns
- Bayer matrix dithering for retro aesthetic
- Mouse interaction support
- Customizable colors and animation parameters
- Performance optimized with WebGL shaders

#### Props:

```typescript
{
  waveSpeed?: number;          // Speed of wave animation (default: 0.05)
  waveFrequency?: number;      // Frequency of waves (default: 3)
  waveAmplitude?: number;      // Amplitude of waves (default: 0.3)
  waveColor?: [number, number, number];  // RGB color (default: [0.5, 0.5, 0.5])
  colorNum?: number;           // Number of colors in dither (default: 4)
  pixelSize?: number;          // Pixel size for dither effect (default: 2)
  disableAnimation?: boolean;  // Disable animation (default: false)
  enableMouseInteraction?: boolean;  // Enable mouse effects (default: true)
  mouseRadius?: number;        // Mouse interaction radius (default: 1)
}
```

#### Basic Usage:

```tsx
import Dither from "@/components/effects/Dither";

<div style={{ width: "100%", height: "600px", position: "relative" }}>
  <Dither
    waveColor={[0.8, 0.4, 1.0]}
    enableMouseInteraction
    mouseRadius={0.5}
    colorNum={6}
    waveAmplitude={0.4}
    waveFrequency={2}
    waveSpeed={0.08}
  />
</div>;
```

### 2. LaserFlow Effect

**Location**: `components/effects/LaserFlow.tsx`

An advanced laser beam effect with volumetric fog, wisps, and dynamic animations.

#### Features:

- Volumetric fog rendering
- Animated wisp particles
- Mouse-responsive tilt
- Customizable beam properties
- Automatic performance optimization (DPR scaling)
- Intersection Observer for performance
- WebGL context loss handling

#### Props:

```typescript
{
  className?: string;
  style?: React.CSSProperties;
  wispDensity?: number;         // Density of wisps (default: 1)
  dpr?: number;                 // Device pixel ratio override
  mouseSmoothTime?: number;     // Mouse smoothing (default: 0.0)
  mouseTiltStrength?: number;   // Mouse tilt effect (default: 0.01)
  horizontalBeamOffset?: number; // Horizontal offset (default: 0.1)
  verticalBeamOffset?: number;   // Vertical offset (default: 0.0)
  flowSpeed?: number;           // Flow animation speed (default: 0.35)
  verticalSizing?: number;      // Vertical beam size (default: 2.0)
  horizontalSizing?: number;    // Horizontal beam size (default: 0.5)
  fogIntensity?: number;        // Fog intensity (default: 0.45)
  fogScale?: number;            // Fog scale (default: 0.3)
  wispSpeed?: number;           // Wisp animation speed (default: 15.0)
  wispIntensity?: number;       // Wisp brightness (default: 5.0)
  flowStrength?: number;        // Flow effect strength (default: 0.25)
  decay?: number;               // Beam decay (default: 1.1)
  falloffStart?: number;        // Falloff start distance (default: 1.2)
  fogFallSpeed?: number;        // Fog fall speed (default: 0.6)
  color?: string;               // Beam color hex (default: '#FF79C6')
}
```

#### Basic Usage:

```tsx
import LaserFlow from "@/components/effects/LaserFlow";

<div style={{ height: "500px", position: "relative", overflow: "hidden" }}>
  <LaserFlow
    color="#CF9EFF"
    wispDensity={1}
    wispSpeed={15}
    wispIntensity={5}
    flowSpeed={0.35}
    flowStrength={0.25}
    fogIntensity={0.45}
  />
</div>;
```

#### Interactive Reveal Effect:

```tsx
import { useRef } from "react";
import LaserFlow from "@/components/effects/LaserFlow";

function InteractiveReveal() {
  const revealRef = useRef(null);

  return (
    <div
      style={{
        height: "800px",
        position: "relative",
        overflow: "hidden",
        backgroundColor: "#060010",
      }}
      onMouseMove={(e) => {
        const rect = e.currentTarget.getBoundingClientRect();
        const x = e.clientX - rect.left;
        const y = e.clientY - rect.top;
        const el = revealRef.current;
        if (el) {
          el.style.setProperty("--mx", `${x}px`);
          el.style.setProperty("--my", `${y + rect.height * 0.5}px`);
        }
      }}
      onMouseLeave={() => {
        const el = revealRef.current;
        if (el) {
          el.style.setProperty("--mx", "-9999px");
          el.style.setProperty("--my", "-9999px");
        }
      }}
    >
      <LaserFlow color="#CF9EFF" />

      {/* Your content here */}
      <div
        style={{
          position: "absolute",
          top: "50%",
          left: "50%",
          transform: "translateX(-50%)",
          zIndex: 6,
        }}
      >
        <h1>Your Content</h1>
      </div>

      {/* Reveal mask */}
      <div
        ref={revealRef}
        style={{
          position: "absolute",
          width: "100%",
          top: "-50%",
          zIndex: 5,
          mixBlendMode: "lighten",
          opacity: 0.3,
          pointerEvents: "none",
          background:
            "radial-gradient(circle, rgba(207,158,255,0.5) 0%, transparent 70%)",
          WebkitMaskImage:
            "radial-gradient(circle at var(--mx) var(--my), rgba(255,255,255,1) 0px, rgba(255,255,255,0) 240px)",
          maskImage:
            "radial-gradient(circle at var(--mx) var(--my), rgba(255,255,255,1) 0px, rgba(255,255,255,0) 240px)",
        }}
      />
    </div>
  );
}
```

## Performance Optimization

### Automatic Optimizations

Both components include built-in performance optimizations:

1. **LaserFlow**:
   - Automatic DPR scaling based on FPS
   - Intersection Observer (pauses when off-screen)
   - Visibility API (pauses when tab is hidden)
   - WebGL context loss recovery
   - Efficient resize handling with RAF debouncing

2. **Dither**:
   - Fixed DPR of 1 for consistent performance
   - Optimized shader compilation
   - Minimal re-renders with useFrame

### Manual Optimizations

```tsx
// Reduce DPR for better performance
<LaserFlow dpr={1} />

// Disable mouse interaction if not needed
<Dither enableMouseInteraction={false} />

// Reduce wisp density
<LaserFlow wispDensity={0.5} />

// Disable animation for static backgrounds
<Dither disableAnimation />
```

## Color Schemes

### Recommended Color Palettes

#### Cyberpunk Theme:

```tsx
// Neon Pink
<LaserFlow color="#FF79C6" />
<Dither waveColor={[1.0, 0.48, 0.78]} />

// Electric Blue
<LaserFlow color="#00D9FF" />
<Dither waveColor={[0.0, 0.85, 1.0]} />

// Purple Haze
<LaserFlow color="#CF9EFF" />
<Dither waveColor={[0.81, 0.62, 1.0]} />
```

#### Professional Theme:

```tsx
// Deep Blue
<LaserFlow color="#4A90E2" />
<Dither waveColor={[0.29, 0.56, 0.89]} />

// Emerald
<LaserFlow color="#50C878" />
<Dither waveColor={[0.31, 0.78, 0.47]} />
```

## Integration Examples

### Admin Portal Landing Page

```tsx
"use client";

import LaserFlow from "@/components/effects/LaserFlow";

export default function AdminLanding() {
  return (
    <div className="relative min-h-screen bg-gray-900">
      {/* Background Effect */}
      <div className="absolute inset-0 opacity-60">
        <LaserFlow color="#CF9EFF" fogIntensity={0.3} wispDensity={0.8} />
      </div>

      {/* Content */}
      <div className="relative z-10 container mx-auto px-4 py-20">
        <h1 className="text-6xl font-bold text-white mb-6">PermitPool Admin</h1>
        <p className="text-xl text-gray-300">Institutional DeFi Management</p>
      </div>
    </div>
  );
}
```

### Trader App Hero Section

```tsx
"use client";

import Dither from "@/components/effects/Dither";

export default function TraderHero() {
  return (
    <section className="relative h-screen">
      {/* Background Effect */}
      <div className="absolute inset-0">
        <Dither
          waveColor={[0.2, 0.6, 1.0]}
          waveSpeed={0.03}
          waveFrequency={2.5}
          colorNum={8}
          enableMouseInteraction
          mouseRadius={0.4}
        />
      </div>

      {/* Content Overlay */}
      <div className="relative z-10 flex items-center justify-center h-full">
        <div className="text-center">
          <h1 className="text-7xl font-bold text-white mb-4">
            Trade with Confidence
          </h1>
          <p className="text-2xl text-gray-200">Powered by ENS Licensing</p>
        </div>
      </div>
    </section>
  );
}
```

## Browser Compatibility

### Supported Browsers:

- ✅ Chrome 90+
- ✅ Firefox 88+
- ✅ Safari 14+
- ✅ Edge 90+

### WebGL Requirements:

- WebGL 1.0 minimum
- OES_standard_derivatives extension (optional, for better quality)

### Fallback Handling:

```tsx
"use client";

import { useState, useEffect } from "react";
import LaserFlow from "@/components/effects/LaserFlow";

export default function SafeEffect() {
  const [webGLSupported, setWebGLSupported] = useState(true);

  useEffect(() => {
    const canvas = document.createElement("canvas");
    const gl =
      canvas.getContext("webgl") || canvas.getContext("experimental-webgl");
    setWebGLSupported(!!gl);
  }, []);

  if (!webGLSupported) {
    return (
      <div className="bg-gradient-to-br from-purple-900 to-pink-900 h-full">
        {/* Fallback gradient background */}
      </div>
    );
  }

  return <LaserFlow color="#CF9EFF" />;
}
```

## Troubleshooting

### Common Issues:

1. **Black Screen**:
   - Check browser console for WebGL errors
   - Verify GPU acceleration is enabled
   - Try reducing DPR: `<LaserFlow dpr={1} />`

2. **Performance Issues**:
   - Reduce wisp density: `wispDensity={0.5}`
   - Disable fog: `fogIntensity={0}`
   - Lower DPR: `dpr={1}`

3. **TypeScript Errors**:
   - Ensure `@types/three` is installed
   - Add `"skipLibCheck": true` to tsconfig.json if needed

4. **Build Errors**:
   - Ensure all peer dependencies are installed
   - Clear `.next` cache: `rm -rf .next`

## Demo Page

Visit `/admin/effects-demo` in the admin portal to see live examples and interactive demos of all effects.

## Performance Metrics

Expected performance on modern hardware:

- **Dither**: 60 FPS @ 1080p
- **LaserFlow**: 50-60 FPS @ 1080p (with auto-scaling)

The LaserFlow component automatically adjusts DPR based on performance, maintaining smooth framerates across different devices.
