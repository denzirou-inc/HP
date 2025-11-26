import { z } from 'zod';

const katakanaRegex = /^[ァ-ンヴー]*$/;
export const contactSchema = z.object({
  companyName: z.string().max(40, '会社名は40文字以内で入力してください'),
  name: z
    .string({ required_error: 'お名前を入力して下さい' })
    .min(1, 'お名前は必須です')
    .max(40, 'お名前は40文字以内で入力してください'),
  kanaName: z.string().regex(katakanaRegex, {
    message: 'カタカナのみ使用できます',
  }),
  email: z
    .string({ required_error: 'メールアドレスを入力して下さい' })
    .email('有効なメールアドレスを入力して下さい'),
  tel: z
    .string({ required_error: '電話番号を入力して下さい' })
    .min(1, '電話番号は必須です')
    .regex(/^[0-9]+$/, '電話番号は数字のみで入力してください'),
  detail: z
    .string({ required_error: 'お問い合わせ内容を入力して下さい' })
    .min(1, 'お問い合わせ内容は必須です')
    .max(3000, 'お問い合わせ内容は3000文字以内で入力してください'),
});

export type ContactSchemaType = z.infer<typeof contactSchema>;
