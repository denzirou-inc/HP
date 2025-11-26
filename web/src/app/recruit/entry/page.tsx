import EntryForm from '@/app/features/entry/components/EntryForm';
export default function Entry() {
  return (
    <div className="w-[1200px] flex flex-col items-start justify-start gap-[45px] max-w-full mq675:gap-[22px]">
      <div className="self-stretch flex flex-col items-start justify-start gap-[33px] max-w-full mq675:gap-[16px]">
        <div className="flex flex-row items-start justify-start py-0 px-[43px] box-border max-w-full mq750:pl-[21px] mq750:pr-[21px] mq750:box-border">
          <div className="flex flex-col items-start justify-start gap-[16px] max-w-full">
            <div className="w-[271px] flex flex-row items-start justify-start gap-[12px]">
              <h1 className="text-17xl text-sandybrown m-0 flex-1 relative font-bold font-poppins text-nowrap mq450:text-10xl">
                Entry Form
              </h1>
              <div className="flex flex-col items-start justify-start pt-[26px] px-0 pb-0 text-base text-black font-kosugi-maru">
                <div className="relative inline-block min-w-[96px]">
                  応募フォーム
                </div>
              </div>
            </div>
            <div className="flex flex-row items-start justify-start py-0 pr-0 pl-[5px] text-base text-black font-kosugi-maru">
              <div className="relative leading-[30px]">
                <p className="m-0">
                  転職をご希望の方、業務委託案件をお探し中の方、その他ご自身のキャリアについての
                </p>
                <p className="m-0">ご相談はこちらからお問い合わせください。</p>
                <p className="m-0">
                  内容をご入力の上、「確認」ボタンをクリックしてください。
                </p>
              </div>
            </div>
          </div>
        </div>
        <div className="self-stretch h-px relative box-border border-t-[1px] border-solid border-gainsboro" />
      </div>
      <div className="w-[1180px] flex flex-row items-start justify-center py-0 px-5 box-border max-w-full mb-4">
        <EntryForm />
      </div>
    </div>
  );
}
