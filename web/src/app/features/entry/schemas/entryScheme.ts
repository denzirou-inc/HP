import { z } from 'zod';

const katakanaRegex = /^[ァ-ンヴー]*$/;

export const entrySchema = z.object({
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
  motivation: z
    .string({ required_error: '志望動機を入力して下さい' })
    .min(1, '志望動機は必須です')
    .max(3000, '志望動機は3000文字以内で入力してください'),
});

export type EntrySchemaType = z.infer<typeof entrySchema>;
