/** @type {import('next').NextConfig} */
const nextConfig = {
  /* Memory optimizations */
  swcMinify: true,
  productionBrowserSourceMaps: false,
  compress: true,
  typescript: {
    tsconfigPath: './tsconfig.json',
  },
  onDemandEntries: {
    maxInactiveAge: 60 * 1000,
    pagesBufferLength: 5,
  },
};

export default nextConfig;
