import { Alert, Box, Button, Container, Typography } from '@mui/material';
import { useRouter } from 'next/navigation';
import React, { useState } from 'react';
import { ContactSchemaType } from '../schemas/contactScheme';

interface ConfirmProps {
  data: ContactSchemaType;
  onBack: () => void;
}

const Confirm: React.FC<ConfirmProps> = ({ data, onBack }) => {
  const router = useRouter();
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const handleConfirm = async () => {
    try {
      console.log(process.env.NEXT_PUBLIC_API_URL);
      const response = await fetch(
        `${process.env.NEXT_PUBLIC_API_URL}/contact/send`,
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            action: 'contact',
            cname: data.companyName,
            name: data.name,
            kana: data.kanaName,
            email: data.email,
            tel: data.tel,
            detail: data.detail,
          }),
        }
      );
      if (response.ok) {
        router.push('/contact/complete');
      } else {
        setErrorMessage(
          '通信に失敗しました。お手数ですが、しばらくしてからもう一度お試しください。'
        );
      }
    } catch (_error) {
      setErrorMessage(
        '通信に失敗しました。お手数ですが、しばらくしてからもう一度お試しください。'
      );
    }
  };

  return (
    <Container maxWidth="sm">
      <Typography
        variant="h4"
        component="h1"
        className="font-kosugi-maru text-black"
      >
        確認
      </Typography>
      <Box className="mt-4 flex flex-col text-black gap-4">
        <div className="border-b pb-4">
          <strong>企業名</strong>
          <p>{data.companyName}</p>
        </div>
        <div className="border-b pb-4">
          <strong>お名前</strong>
          <p>{data.name}</p>
        </div>
        <div className="border-b pb-4">
          <strong>お名前(カナ)</strong>
          <p>{data.kanaName}</p>
        </div>
        <div className="border-b pb-4">
          <strong>メールアドレス</strong>
          <p>{data.email}</p>
        </div>
        <div className="border-b pb-4">
          <strong>電話番号</strong>
          <p>{data.tel}</p>
        </div>
        <div className="border-b pb-4">
          <strong>お問い合わせ内容</strong>
          <p>{data.detail}</p>
        </div>
      </Box>
      {errorMessage && (
        <Alert severity="error" sx={{ mt: 2 }}>
          {errorMessage}
        </Alert>
      )}
      <Box sx={{ mt: 5 }} className="flex flex-row justify-around">
        <Button
          className="h-[50px] w-[100px] font-kosugi-maru"
          disableElevation={true}
          variant="contained"
          sx={{
            textTransform: 'none',
            color: '#fff',
            fontSize: '20',
            background: '#083d77',
            borderRadius: '5px',
            '&:hover': { opacity: 0.8, background: '#083d77' },
            width: 100,
            height: 50,
          }}
          type="submit"
          onClick={onBack}
        >
          戻る
        </Button>

        <Button
          className="h-[50px] w-[100px] font-kosugi-maru"
          disableElevation={true}
          variant="contained"
          sx={{
            textTransform: 'none',
            color: '#fff',
            fontSize: '20',
            background: '#f79256',
            borderRadius: '5px',
            '&:hover': { opacity: 0.8, background: '#f79256' },
            width: 100,
            height: 50,
          }}
          type="submit"
          onClick={handleConfirm}
        >
          送信
        </Button>
      </Box>
    </Container>
  );
};

export default Confirm;
