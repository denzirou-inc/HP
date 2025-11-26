import type { Metadata } from 'next';
import { Kosugi_Maru } from 'next/font/google';
import './globals.css';
import Footer from '@/app/components/Footer';
import Header from '@/app/components/Header';

const kosugiMaru = Kosugi_Maru({ subsets: ['latin'], weight: '400' });

export const metadata: Metadata = {
  title: 'Denzirou Inc.',
  description: '株式会社藤原伝次郎商店のサイトです。',
  openGraph: {
    title: 'Denzirou Inc.',
    description: '株式会社藤原伝次郎商店のサイトです。',
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="ja">
      <body className={kosugiMaru.className}>
        <Header />
        {children}
        <Footer />
      </body>
    </html>
  );
}
