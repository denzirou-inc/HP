import { type NextRequest, NextResponse } from 'next/server';
import nodemailer from 'nodemailer';
import { z } from 'zod';

const contactSchema = z.object({
  action: z.enum(['recruit', 'contact']),
  cname: z.string().optional(),
  name: z.string().min(1, { message: '名前は必須です' }),
  kana: z.string().optional(),
  email: z
    .string()
    .email({ message: '有効なメールアドレスを入力してください' }),
  tel: z
    .string()
    .regex(/^[0-9]+$/, { message: '電話番号は数字のみで入力してください' }),
  detail: z.string().min(1, { message: '詳細は必須です' }),
});

function createTransporter() {
  const smtpConfig: any = {
    host: process.env.SMTP_HOST || 'smtp.gmail.com',
    port: parseInt(process.env.SMTP_PORT || '587', 10),
    secure: false,
  };

  // MailHog (development) の場合は認証を無効にする
  if (
    process.env.SMTP_HOST === 'mailhog' ||
    process.env.NODE_ENV === 'development'
  ) {
    smtpConfig.secure = false;
    smtpConfig.ignoreTLS = true;
    // 認証情報は不要
  } else {
    // 本番環境では認証を有効にする
    smtpConfig.auth = {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASS,
    };
  }

  return nodemailer.createTransport(smtpConfig);
}

function generateEmailContent(data: z.infer<typeof contactSchema>) {
  const isRecruit = data.action === 'recruit';
  const subject = isRecruit ? '採用応募のお知らせ' : 'お問い合わせ';
  const htmlContent = `
    <h2>${subject}</h2>
    <table border="1" style="border-collapse: collapse; width: 100%;">
      ${data.cname ? `<tr><td><strong>企業名</strong></td><td>${data.cname}</td></tr>` : ''}
      <tr><td><strong>お名前</strong></td><td>${data.name}</td></tr>
      ${data.kana ? `<tr><td><strong>フリガナ</strong></td><td>${data.kana}</td></tr>` : ''}
      <tr><td><strong>メールアドレス</strong></td><td>${data.email}</td></tr>
      <tr><td><strong>電話番号</strong></td><td>${data.tel}</td></tr>
      <tr><td><strong>${isRecruit ? '志望動機' : 'お問い合わせ内容'}</strong></td><td>${data.detail}</td></tr>
    </table>
  `;

  const textContent = `
${subject}

${data.cname ? `企業名: ${data.cname}\n` : ''}お名前: ${data.name}
${data.kana ? `フリガナ: ${data.kana}\n` : ''}メールアドレス: ${data.email}
電話番号: ${data.tel}
${isRecruit ? '志望動機' : 'お問い合わせ内容'}: ${data.detail}
  `;

  return { subject, htmlContent, textContent };
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    console.log('Received body:', body);

    // バリデーション
    const validationResult = contactSchema.safeParse(body);
    if (!validationResult.success) {
      return NextResponse.json(
        {
          status: 'error',
          message: 'バリデーションエラーです',
          errors: validationResult.error.format(),
        },
        { status: 400 }
      );
    }

    const data = validationResult.data;

    const isMailHog =
      process.env.SMTP_HOST === 'mailhog' ||
      process.env.NODE_ENV === 'development';
    if (!isMailHog && (!process.env.SMTP_USER || !process.env.SMTP_PASS)) {
      return NextResponse.json(
        {
          status: 'error',
          message: 'メール設定が不完全です（SMTP認証情報が必要）',
        },
        { status: 500 }
      );
    }

    if (!process.env.MAIL_TO) {
      return NextResponse.json(
        {
          status: 'error',
          message: 'メール送信先が設定されていません',
        },
        { status: 500 }
      );
    }

    // メール送信
    console.log('Creating transporter...');
    const transporter = createTransporter();
    const { subject, htmlContent, textContent } = generateEmailContent(data);

    console.log('Sending email...');
    await transporter.sendMail({
      from: process.env.SMTP_USER,
      to: process.env.MAIL_TO,
      subject,
      text: textContent,
      html: htmlContent,
      replyTo: data.email,
    });

    return NextResponse.json({
      status: 'success',
      message: 'メールが正常に送信されました。',
      url: 'contact',
    });
  } catch (error) {
    console.error('メール送信エラー:', error);
    return NextResponse.json(
      {
        status: 'error',
        message: 'メールの送信に失敗しました。',
        error:
          process.env.NODE_ENV === 'development' ? String(error) : undefined,
      },
      { status: 500 }
    );
  }
}
