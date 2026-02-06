import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
import './globals.css';
import { Providers } from '@/components/Providers';
import { Header } from '@/components/Header';
import Footer from '@/components/Footer';
import LaserFlow from '@/components/effects/LaserFlow';
import DevToolbar from '@/components/DevToolbar';
import { Toaster } from 'sonner';

const inter = Inter({ 
  subsets: ['latin'],
  display: 'swap', // Optimize font loading
  preload: true,
});


export const metadata: Metadata = {
  title: 'PermitPool Admin - License Management',
  description: 'Admin portal for managing trading licenses and compliance',
  viewport: {
    width: 'device-width',
    initialScale: 1,
    maximumScale: 5,
    userScalable: true,
    viewportFit: 'cover', // For iPhone notch
  },
  themeColor: '#1890FF', // Sui blue
  appleWebApp: {
    capable: true,
    statusBarStyle: 'black-translucent',
    title: 'PermitPool Admin',
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body className={inter.className} suppressHydrationWarning>
        <Providers>
          <Header />
          <main className="min-h-screen bg-black relative overflow-hidden">
            {/* Background Effects */}
            <div className="fixed inset-0 pointer-events-none z-0">
               <div className="absolute inset-0 radial-gradient-blue opacity-50" />
               <LaserFlow 
                 color="#1890FF" 
                 fogIntensity={0.6} 
                 wispDensity={0.8}
                 flowSpeed={0.2} 
                 className="opacity-60"
               />
            </div>
            
            <div className="relative z-10">
              {children}
            </div>
          </main>
          <Footer />
          <DevToolbar />
          <Toaster position="top-right" />
        </Providers>
      </body>
    </html>
  );
}
