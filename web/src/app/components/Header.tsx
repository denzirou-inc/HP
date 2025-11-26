import Link from 'next/link';
import MainNavigation from '@/app/components/MainNavigation';

export default function Header() {
  return (
    <header className="bg-white h-16 w-full flex flex-row items-start justify-between py-2 pr-0 pl-5 box-border gap-[20px] max-w-full z-[1] text-left text-13xl text-black font-poppins">
      <h1 className="m-0 relative text-inherit font-normal font-inherit inline-block shrink-0 whitespace-nowrap">
        <Link href="/">Denzirou Inc.</Link>
      </h1>
      <nav className="m-0 w-[395px] flex flex-col items-start justify-start px-0 pb-0 box-border max-w-full mq750:hidden">
        <div className="m-0 self-stretch flex flex-row items-start justify-between gap-[20px] text-left text-base font-poppins px-4">
          <MainNavigation />
        </div>
      </nav>
    </header>
  );
}
