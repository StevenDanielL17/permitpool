/** @type {import('next').NextConfig} */
const nextConfig = {
  /* Memory optimizations */
  swcMinify: true,
  compress: true,
  productionBrowserSourceMaps: false,
  experimental: {
    optimizeFonts: true,
    isrMemoryCacheSize: 0,
  },
  /* Disable Turbopack - use SWC for lower memory usage */
  ...(process.env.DISABLE_TURBOPACK === '1' && {
    experimental: {
      turbopack: false,
    }
  }),
};

export default nextConfig;
