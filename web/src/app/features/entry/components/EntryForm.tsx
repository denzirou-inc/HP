'use client';
import { zodResolver } from '@hookform/resolvers/zod';
import { Box, Button, TextField } from '@mui/material';
import React, { useState } from 'react';
import { Controller, useForm } from 'react-hook-form';
import { EntrySchemaType, entrySchema } from '../schemas/entryScheme';
import Confirm from './Confirm';

const EntryForm: React.FC = () => {
  const [formData, setFormData] = useState<EntrySchemaType | null>(null);
  const {
    control,
    handleSubmit,
    formState: { errors },
  } = useForm<EntrySchemaType>({
    resolver: zodResolver(entrySchema),
    defaultValues: {
      name: '',
      kanaName: '',
      email: '',
      tel: '',
      motivation: '',
    },
  });

  const onSubmit = (data: EntrySchemaType) => {
    setFormData(data);
  };

  if (formData) {
    return <Confirm data={formData} onBack={() => setFormData(null)} />;
  }

  return (
    <form
      onSubmit={handleSubmit(onSubmit)}
      className="text-black font-kosugi-maru flex flex-col justify-center gap-6 max-w-[400px] w-[400px]"
    >
      <Box>
        <Controller
          name="name"
          control={control}
          render={({ field }) => (
            <TextField
              {...field}
              className="w-full"
              id="name"
              label="お名前*"
              variant="outlined"
              autoComplete="name"
              error={!!errors.name}
              helperText={errors.name ? errors.name.message : ''}
            />
          )}
        />
      </Box>

      <Box>
        <Controller
          name="kanaName"
          control={control}
          render={({ field }) => (
            <TextField
              {...field}
              className="w-full"
              id="kanaName"
              label="フリガナ"
              variant="outlined"
              autoComplete="off"
              error={!!errors.kanaName}
              helperText={errors.kanaName ? errors.kanaName.message : ''}
            />
          )}
        />
      </Box>

      <Box>
        <Controller
          name="email"
          control={control}
          render={({ field }) => (
            <TextField
              {...field}
              className="w-full"
              id="email"
              label="メールアドレス*"
              variant="outlined"
              autoComplete="email"
              error={!!errors.email}
              helperText={errors.email ? errors.email.message : ''}
            />
          )}
        />
      </Box>

      <Box>
        <Controller
          name="tel"
          control={control}
          render={({ field }) => (
            <TextField
              {...field}
              className="w-full"
              id="tel"
              label="電話番号*"
              variant="outlined"
              autoComplete="tel"
              error={!!errors.tel}
              helperText={errors.tel ? errors.tel.message : ''}
            />
          )}
        />
      </Box>

      <Box>
        <Controller
          name="motivation"
          control={control}
          render={({ field }) => (
            <TextField
              {...field}
              className="w-full"
              id="motivation"
              label="志望動機*"
              variant="outlined"
              autoComplete="off"
              multiline
              minRows={6}
              error={!!errors.motivation}
              helperText={errors.motivation ? errors.motivation.message : ''}
            />
          )}
        />
      </Box>

      <Box className="flex justify-center">
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
        >
          確認
        </Button>
      </Box>
    </form>
  );
};

export default EntryForm;
