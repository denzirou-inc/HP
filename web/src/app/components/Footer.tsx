import Image from 'next/image';
import MainNavigation from '@/app/components/MainNavigation';

export default function Footer() {
  return (
    <footer className="self-stretch flex flex-col items-center justify-start pt-14 px-5 pb-[15px] box-border relative gap-[102.2px] max-w-full text-left text-13xl text-black font-poppins mq450:gap-[51px]">
      <div className="w-full h-full absolute !m-[0] top-[0px] right-[0px] bottom-[0px] left-[0px] bg-gainsboro" />
      <div className="w-[401px] flex flex-col items-start justify-start gap-[14px] max-w-full">
        <div className="self-stretch flex flex-row items-start justify-start py-0 px-[75px] mq450:pl-5 mq450:pr-5 mq450:box-border">
          <h1 className="m-0 flex-1 h-24 z-[1]">
            <Image
              src="/logo.svg"
              width={100}
              height={100}
              alt="Denzirou Inc. Logo"
              className="h-full w-auto object-cover mx-auto"
            />
          </h1>
        </div>
        <MainNavigation />
      </div>
      <div className="w-[402px] flex flex-row items-start justify-center py-0 pr-px pl-0 box-border max-w-full text-[10px]">
        <div className="relative z-[1]">
          Copyright(c)Denzirou Inc. All rights reserved.
        </div>
      </div>
    </footer>
  );
}
