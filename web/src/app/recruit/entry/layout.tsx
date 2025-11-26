export default function ContactLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <div className="w-full relative bg-white overflow-hidden flex flex-col items-start justify-start pt-6 px-0 pb-0 box-border gap-[74px] leading-[normal] tracking-[normal] mq450:gap-[18px] mq800:gap-[37px]">
      <section className="self-stretch flex flex-row items-start justify-start py-0 px-[55px] box-border max-w-full text-left text-base text-black font-poppins mq750:pl-[27px] mq750:pr-[27px] mq750:box-border">
        <div className="flex-1 flex flex-col items-end justify-start gap-[39.9px] max-w-full mq675:gap-[20px]">
          <div className="w-[1276px] flex flex-row items-start justify-end py-0 px-1 box-border max-w-full text-left text-base text-black">
            <div className="flex-1 flex flex-col items-start justify-start gap-[74px] max-w-full mq450:gap-[18px] mq675:gap-[37px]">
              <div className="self-stretch flex flex-row items-start justify-end">
                <div className="relative leading-[30px] inline-block min-w-[112px]">{`Top > Recruit > Entry`}</div>
              </div>
              {children}
            </div>
          </div>
        </div>
      </section>
    </div>
  );
}
