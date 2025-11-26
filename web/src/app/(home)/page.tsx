import Link from 'next/link';
import AnimationButton from '@/app/components/AnimationButton';
import Slider from '@/app/components/Slider';

export default function Home() {
  const slides = [
    {
      id: 1,
      imageUrl: '/bill.png',
    },
    {
      id: 2,
      imageUrl: '/top-image.jpg',
    },
  ];
  return (
    <div className="w-full relative bg-white overflow-hidden flex flex-col items-start justify-start px-0 pb-0 box-border leading-[normal] tracking-[normal] text-left text-black font-kosugi-maru">
      <div className="w-full flex flex-col items-start justify-start max-w-full">
        <section className="w-full">
          <Slider slides={slides} />
        </section>
      </div>
      <section className="w-full mb-16 relative">
        <div className="bg-left-bottom bg-bg1 bg-cover bg-no-repeat h-96 rounded-bl-[60px] ml-[40%] w-full"></div>
        <div className="absolute top-[20%] left-[10%] right-[10%] w-[80%]">
          <h2 className="shadow-text m-0 self-stretch relative text-29xl mb-4 tracking-[0.03em] font-bold font-inherit inline-block mq1025:text-19xl mq450:text-10xl">
            ITの力で企業の未来を変える
          </h2>
          <p className="shadow-text text-xl leading-8 mq450:text-base mt-4 text-balance">
            私たちは、明るい未来を支える企業のため
            テクノロジーの力で作業の効率化を実現します。
          </p>
          <p className="shadow-text text-xl leading-8 mq450:text-base mt-4 text-balance">
            企業ごとの強みを活かし、ITの技術を駆使しながら
            サポートすることで、それぞれが掲げる目標を
            より現実的な姿に変えていきます。
          </p>
        </div>
      </section>
      <section id="about" className="w-full mb-16">
        <div className="bg-sandybrown rounded-br-[60px] rounded-tr-[60px] mr-[10%] pl-[10%]">
          <div className="flex flex-row gap-4 max-w-screen-md py-8 items-start justify-between mq1025:flex-col">
            <h1 className="text-17xl m-0 flex-1 font-bold text-white font-poppins mq1025:text-10xl">
              About
            </h1>
            <h2 className="leading-[48px] flex-1 text-17xl font-bold font-kosugi-maru text-white inline-block max-w-full z-[2] mq1025:text-19xl mq450:text-10xl text-nowrap">
              テクノロジーで
              <br />
              明るい未来を
            </h2>
            <div className="mt-16 flex-grow leading-8 mq1025:mt-0">
              <p>
                社員に目標がなければ、クライアントの信用は得られません。
                <br />
                そして社長に夢がなければ、社員は付いてきません。
                <br />
                私たちは、弊社で働く全ての社員のために、
                <br />
                会社の歩むべき未来を明確に提示します。
                <br />
                IT技術を求める企業に、チーム一丸となった姿を見て頂き
                <br />
                安心して弊社をご利用頂けるよう、夢・目標を明確にします。
              </p>
            </div>
          </div>
        </div>
      </section>
      <section className="w-full pt-0 mb-16 text-left text-17xl mq450:pb-10 mq450:box-border">
        <div className="mx-auto w-[80%] flex flex-row items-start justify-between max-w-full gap-[20px] mq1025:flex-wrap">
          <div className="w-[275px] flex flex-row items-start justify-start gap-[14px]">
            <h1 className="text-sandybrown m-0 flex-1 relative text-inherit font-bold font-poppins font-inherit mq1025:text-10xl">
              Company
            </h1>
            <div className="flex flex-col items-start justify-start pt-[26px] px-0 pb-0 text-base text-black font-kosugi-maru">
              <div className="relative inline-block min-w-[64px]">会社概要</div>
            </div>
          </div>
          <div className="w-[627px] flex flex-col items-start justify-start pt-[45px] pb-0 box-border min-w-[627px] max-w-full text-base text-black font-kosugi-maru mq750:min-w-full mq1025:flex-1 mq450:pt-[29px] mq450:box-border">
            <div className="self-stretch flex flex-col items-start justify-start gap-[22px] max-w-full">
              <div className="self-stretch flex flex-col items-start justify-start pt-0 px-0 pb-[2.5px] gap-[27.5px] text-darkslategray">
                <div className="flex flex-row items-start justify-start py-0 px-4 box-border">
                  <div className="flex flex-col sm:flex-row items-start justify-start gap-2 sm:gap-[40px] w-full">
                    <div className="relative inline-block min-w-[80px] text-darkslategray">
                      社名
                    </div>
                    <div className="relative text-black">
                      株式会社藤原伝次郎商店
                    </div>
                  </div>
                </div>
                <div className="self-stretch h-px relative box-border border-t-[1px] border-solid border-gainsboro" />
              </div>
              <div className="flex flex-row items-start justify-start pt-0 px-4 pb-[5px] box-border">
                <div className="flex flex-col sm:flex-row items-start justify-start gap-2 sm:gap-[40px] w-full">
                  <div className="relative inline-block min-w-[80px] text-darkslategray">
                    部署名
                  </div>
                  <div className="relative">SE部門</div>
                </div>
              </div>
              <div className="self-stretch h-px relative box-border border-t-[1px] border-solid border-gainsboro" />
              <div className="self-stretch flex flex-col items-start justify-start gap-[15px] max-w-full">
                <div className="flex flex-row items-start justify-start py-0 px-4 box-border max-w-full">
                  <div className="flex flex-col sm:flex-row items-start justify-start gap-2 sm:gap-[40px] w-full">
                    <div className="relative inline-block min-w-[80px] text-darkslategray">
                      住所
                    </div>
                    <div className="relative leading-[20px]">
                      <p className="m-0">愛知県名古屋市千種区園山町1-36-1</p>
                    </div>
                  </div>
                </div>
                <div className="self-stretch h-px relative box-border border-t-[1px] border-solid border-gainsboro" />
              </div>
              <div className="flex flex-row items-start justify-start py-0 px-4 box-border">
                <div className="flex flex-col sm:flex-row items-start justify-start gap-2 sm:gap-[40px] w-full">
                  <div className="relative inline-block min-w-[80px] text-darkslategray">
                    設立
                  </div>
                  <div className="relative">2024年1月</div>
                </div>
              </div>
              <div className="self-stretch h-2.5 flex flex-row items-start justify-start pt-0 px-0 pb-[9px] box-border max-w-full">
                <div className="self-stretch flex-1 relative box-border max-w-full border-t-[1px] border-solid border-gainsboro" />
              </div>
              <div className="flex flex-row items-start justify-start py-0 px-4 box-border max-w-full">
                <div className="flex flex-col sm:flex-row items-start justify-start gap-2 sm:gap-[40px] w-full">
                  <div className="relative inline-block min-w-[80px] text-darkslategray sm:pt-1">
                    事業内容
                  </div>
                  <div className="flex flex-col items-start justify-start pt-px px-0 pb-0">
                    <ul className="list-disc list-inside space-y-2">
                      <li>アプリケーション・Webサービスの企画/設計</li>
                      <li>開発プロダクトリリース後の運用/保守</li>
                      <li>IT業務改善支援</li>
                      <li>システムエンジニアリングサービス（SES）の支援</li>
                    </ul>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>
      <section className="flex flex-row flex-wrap items-start justify-center w-full text-left text-17xl text-white font-poppins">
        <div className="w-1/2 flex flex-col items-center justify-start pt-[46px] px-5 pb-[43px] box-border relative gap-[14px] max-w-full mq750:w-full">
          <div className="w-full h-full absolute !m-[0] top-[0px] right-[0px] bottom-[0px] left-[0px] bg-sandybrown" />
          <div className="flex flex-row items-start justify-start gap-4 z-[1]">
            <h1 className="m-0 h-[47px] relative text-inherit font-bold font-inherit inline-block mq1025:text-10xl">
              Recruit
            </h1>
            <div className="flex flex-col items-start justify-start pt-[26px] px-0 pb-0 text-base text-black font-kosugi">
              <div className="relative inline-block min-w-[32px]">{`募集 `}</div>
            </div>
          </div>
          <div>
            <Link href="/recruit">
              <AnimationButton variant="primary">募集を見る</AnimationButton>
            </Link>
          </div>
        </div>
        <div className="w-1/2 flex flex-col items-center justify-start pt-12 px-5 pb-[50px] box-border relative gap-[11.7px] text-sandybrown mq750:w-full">
          <div className="w-full h-full absolute !m-[0] top-[0px] right-[0px] bottom-[0px] left-[0px] bg-darkslateblue" />
          <div className="flex flex-row items-start justify-start gap-4 z-[1]">
            <h1 className="m-0 h-[37.3px] flex-1 relative text-inherit font-bold font-inherit inline-block mq1025:text-10xl">
              Contact
            </h1>
            <div className="flex flex-col items-start justify-start pt-[25px] px-0 pb-0 text-base text-white font-kosugi-maru">
              <div className="relative inline-block min-w-[96px]">
                お問い合わせ
              </div>
            </div>
          </div>
          <div>
            <Link href="/contact">
              <AnimationButton variant="secondary">
                お問い合わせはこちら
              </AnimationButton>
            </Link>
          </div>
        </div>
      </section>
    </div>
  );
}
