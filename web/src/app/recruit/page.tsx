import Image from 'next/image';
import Link from 'next/link';

import AnimationButton from '@/app/components/AnimationButton';
export default function Recruit() {
  return (
    <div className="w-full relative bg-white overflow-hidden flex flex-col items-start justify-start pt-6 px-0 pb-0 box-border gap-[74px] leading-[normal] tracking-[normal] mq450:gap-[18px] mq800:gap-[37px]">
      <section className="max-w-[85vw] w-full flex flex-col items-end justify-start mx-auto mb-8 box-border gap-[53px] mq800:gap-[26px]">
        <div className="w-full flex flex-row items-start justify-center py-0 box-border max-w-full text-left font-poppins">
          <div className="w-full flex flex-col items-start justify-start max-w-full">
            <div className="self-stretch flex flex-row items-start justify-end pt-0 px-0 pb-6">
              <div className="relative leading-[30px]">{`Top > Recruit`}</div>
            </div>
            <div className="flex flex-row items-start justify-start gap-[22px] text-17xl">
              <h1 className="m-0 relative text-sandybrown leading-[48px] font-bold font-inherit mq450:text-10xl">
                Recruit
              </h1>
              <div className="flex flex-col items-start justify-start pt-[26px] px-0 pb-0 text-base text-black font-kosugi-maru">
                <div className="relative inline-block min-w-[32px]">{`募集 `}</div>
              </div>
            </div>
            <div className="self-stretch flex flex-row items-start justify-end max-w-full text-center text-xl text-black font-kosugi-maru">
              <div className="w-[765px] flex flex-row items-start justify-start gap-[19px] max-w-full mq750:flex-col">
                <div className="flex-1 relative tracking-[0.03em] leading-[30px] inline-block min-w-[313px] max-w-full mq450:text-base mq450:leading-[24px]">
                  <p className="m-0">社内コミュニケーションを重視した、</p>
                  <p className="m-0">
                    チームでの業務に意欲的な方を募集しています！
                  </p>
                </div>
                <div className="h-[212px] w-[265px] flex flex-col items-start justify-start pt-[26px] px-0 pb-0 box-border min-w-[265px] mq800:flex-1">
                  <Image
                    className="self-stretch flex-1 relative max-w-full overflow-hidden max-h-full object-cover mq800:self-stretch mq800:w-auto"
                    loading="lazy"
                    alt=""
                    width={265}
                    height={212}
                    src="/the-little-things-working@2x.png"
                  />
                </div>
              </div>
            </div>
          </div>
        </div>
        <div className="self-stretch ml-[-7.5vw] rounded-tl-none rounded-tr-41xl rounded-br-41xl rounded-bl-none bg-sandybrown flex flex-row items-end justify-between pt-[39.3px] pb-[30px] pr-[75px] pl-[156px] box-border max-w-full gap-[20px] text-left text-5xl text-white font-kosugi-maru mq450:pt-[26px] mq450:pb-5 mq750:pl-4 mq750:pr-4 mq750:box-border mq1125:flex-wrap mq1125:justify-center mq1325:pl-[78px] mq1325:pr-[37px] mq1325:box-border">
          <div className="h-[269px] w-[347px] flex flex-col items-start justify-end pt-0 px-0 pb-[29px] box-border max-w-full">
            <Image
              className="self-stretch flex-1 relative max-w-full overflow-hidden max-h-full object-cover z-[1]"
              loading="lazy"
              alt=""
              width={347}
              height={269}
              src="/humaaans-1-character@2x.png"
            />
          </div>
          <div className="w-[268px] flex flex-col items-start justify-end pt-0 pb-[12.7px] pr-[33px] pl-0 box-border">
            <div className="self-stretch flex flex-col items-start justify-start gap-[21px]">
              <h3 className="m-0 relative text-inherit font-normal font-inherit inline-block min-w-[96px] z-[1] mq450:text-lgi">
                募集要項
              </h3>
              <div className="self-stretch flex flex-row items-stare justify-end text-xl text-black">
                <div className="relative leading-[50px] z-[1] mq450:text-base mq450:leading-[40px]">
                  <p className="m-0">プログラマー</p>
                  <p className="m-0">システムエンジニア</p>
                  <p className="m-0">サーバーエンジニア</p>
                  <p className="m-0">運用管理エンジニア</p>
                  <p className="m-0">OAサポート</p>
                </div>
              </div>
            </div>
          </div>
          <div className="flex flex-row items-start justify-start py-[13px] pr-[27px] pl-[49px] relative gap-[13px] z-[2] text-base font-poppins">
            <Link href="/recruit/entry">
              <AnimationButton variant="primary">ENTRY</AnimationButton>
            </Link>
          </div>
        </div>
      </section>
    </div>
  );
}
