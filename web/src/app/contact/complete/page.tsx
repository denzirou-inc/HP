import Box from '@mui/material/Box';
import Container from '@mui/material/Container';
import Typography from '@mui/material/Typography';

const Complete = () => {
  return (
    <div className="w-[1200px] flex flex-col items-start justify-start gap-[45px] max-w-full mq675:gap-[22px]">
      <div className="self-stretch flex flex-col items-start justify-start gap-[33px] max-w-full mq675:gap-[16px]">
        <div className="flex flex-row items-start justify-start py-0 px-[43px] box-border max-w-full mq750:pl-[21px] mq750:pr-[21px] mq750:box-border">
          <div className="flex flex-col items-start justify-start gap-[16px] max-w-full">
            <div className="w-[271px] flex flex-row items-start justify-start gap-[12px]">
              <h1 className="text-17xl text-sandybrown m-0 flex-1 relative font-bold font-poppins mq450:text-3xl mq750:text-10xl">
                Contact
              </h1>
              <div className="flex flex-col items-start justify-start pt-[26px] px-0 pb-0 text-base text-black font-kosugi-maru">
                <div className="relative inline-block min-w-[96px]">
                  お問い合わせ
                </div>
              </div>
            </div>
          </div>
        </div>
        <div className="self-stretch h-px relative box-border border-t-[1px] border-solid border-gainsboro" />
      </div>
      <div className="w-[1180px] flex flex-row items-start justify-center py-0 px-5 box-border max-w-full mb-4">
        <Container maxWidth="sm">
          <Box>
            <Typography
              variant="h4"
              component="h2"
              className="font-kosugi-maru"
            >
              送信完了
            </Typography>
            <Typography
              variant="body1"
              className="font-kosugi-maru"
              sx={{ mt: 2 }}
            >
              お問い合わせありがとうございます。
              <br />
              ご記入いただいた内容を確認の上、一週間以内にご登録いただいたメールアドレス宛にご連絡を差し上げます。お手数ですが、今しばらくお待ちください。
            </Typography>
          </Box>
        </Container>
      </div>
    </div>
  );
};

export default Complete;
