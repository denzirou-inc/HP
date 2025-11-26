import type { Config } from 'tailwindcss';

const config: Config = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      backgroundImage: {
        'gradient-radial': 'radial-gradient(var(--tw-gradient-stops))',
        'gradient-conic':
          'conic-gradient(from 180deg at 50% 50%, var(--tw-gradient-stops))',
        bg1: 'url("/bg1.png")',
      },
      colors: {
        white: '#fff',
        black: '#000',
        sandybrown: '#f79256',
        gainsboro: '#dedede',
        darkslateblue: '#083d77',
        darkslategray: '#333',
      },
      spacing: {},
      fontFamily: {
        poppins: 'Poppins',
        'kosugi-maru': "'Kosugi Maru'",
        kosugi: 'Kosugi',
        'noto-sans-jp': "'Noto Sans JP'",
      },
      borderRadius: {
        '8xs': '5px',
        '41xl': '60px',
        '31xl': '50px',
        '81xl': '100px',
      },
    },
    fontSize: {
      '3xs': '10px',
      base: '16px',
      '13xl': '32px',
      lgi: '19px',
      '7xl': '26px',
      '17xl': '36px',
      '3xl': '22px',
      '10xl': '29px',
      xl: '20px',
      '5xl': '24px',
      '29xl': '48px',
      '19xl': '38px',
      inherit: 'inherit',
    },
    screens: {
      mq1125: {
        raw: 'screen and (max-width: 1125px)',
      },
      mq1025: {
        raw: 'screen and (max-width: 1025px)',
      },
      mq750: {
        raw: 'screen and (max-width: 750px)',
      },
      mq450: {
        raw: 'screen and (max-width: 450px)',
      },
    },
  },
  plugins: [],
};
export default config;
