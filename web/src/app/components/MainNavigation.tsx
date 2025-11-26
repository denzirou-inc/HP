'use client';
import Link from 'next/link';
import { usePathname } from 'next/navigation';

export default function MainNavigation() {
  const pathname = usePathname();

  const isActive = (path: string) =>
    pathname.startsWith(path) ? 'text-sandybrown' : 'text-black';

  return (
    <nav className="m-0 w-[395px] flex flex-col items-start justify-start pt-[11.3px] px-0 pb-0 box-border max-w-full">
      <div className="m-0 self-stretch flex flex-row items-start justify-between gap-[20px] text-left text-base font-poppins px-4">
        <b className={`animation-nav min-w-[52px] hover:text-sandybrown`}>
          <Link href="/#about">About</Link>
        </b>
        {/* <b className={`animation-nav min-w-[65px] ${isActive('/service')} hover:text-sandybrown`}>
          <Link href="/service">Service</Link>
        </b> */}
        <b
          className={`animation-nav min-w-[59px] ${isActive('/recruit')} hover:text-sandybrown`}
        >
          <Link href="/recruit">Recruit</Link>
        </b>
        <b
          className={`animation-nav min-w-[70px] ${isActive('/contact')} hover:text-sandybrown`}
        >
          <Link href="/contact">Contact</Link>
        </b>
      </div>
    </nav>
  );
}
