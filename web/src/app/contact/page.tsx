import ContactForm from '../features/contact/components/ContactForm';
export default function Contact() {
  return (
    <div className="w-[1200px] flex flex-col items-start justify-start gap-[45px] max-w-full mq675:gap-[22px]">
      <div className="self-stretch flex flex-col items-start justify-start gap-[33px] max-w-full mq675:gap-[16px]">
        <div className="flex flex-row items-start justify-start py-0 px-[43px] box-border max-w-full mq750:pl-[21px] mq750:pr-[21px] mq750:box-border">
          <div className="flex flex-col items-start justify-start gap-[16px] max-w-full">
            <div className="w-[271px] flex flex-row items-start justify-start gap-[12px]">
              <h1 className="text-17xl text-sandybrown m-0 flex-1 relative font-bold font-poppins mq450:text-10xl">
                Contact
              </h1>
              <div className="flex flex-col items-start justify-start pt-[26px] px-0 pb-0 text-base text-black font-kosugi-maru">
                <div className="relative inline-block min-w-[96px]">
                  お問い合わせ
                </div>
              </div>
            </div>
            <div className="flex flex-row items-start justify-start py-0 pr-0 pl-[5px] text-base text-black font-kosugi-maru">
              <div className="relative leading-[30px]">
                <p className="m-0">
                  ビジネスパートナー募集に関するお問い合わせは以下のフォームからお願いいたします。
                </p>
                <p className="m-0">
                  ※電話でのお問い合わせは受け付けておりません。予めご了承ください。
                </p>
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
        <ContactForm />
      </div>
    </div>
  );
}
