# Technology Stack

## Core Framework
- **Next.js**: 14.2.31 with App Router
- **React**: 18 (latest stable)
- **TypeScript**: 5 (latest stable)

## Frontend Styling & UI
- **Tailwind CSS**: 3.4.3 (utility-first CSS)
- **Material-UI (MUI)**: 5.15.18 (React component library)
- **Emotion**: 11.11.4+ (CSS-in-JS styling for MUI)
- **PostCSS**: 8 (CSS processing)
- **Fonts**: Kosugi Maru (Google Fonts, Japanese support)

## Forms & Validation  
- **React Hook Form**: 7.51.5 (form management)
- **Zod**: 3.23.8 (TypeScript-first schema validation)
- **Hookform Resolvers**: 3.4.2 (form validation integration)

## Backend & API
- **Next.js API Routes**: Server-side functionality
- **Nodemailer**: 7.0.5 (email sending)
- **Environment Variables**: Multi-environment configuration

## Interactive Components
- **Swiper**: 11.1.4 (touch sliders and carousels)

## Development Tools
- **Biome**: 2.2.2 (linting, formatting, and code analysis)
  - Replaces ESLint + Prettier combination
  - Faster TypeScript/JavaScript toolchain
- **TypeScript Compiler**: Type checking and compilation

## Infrastructure & Deployment
- **Docker**: Multi-environment containerization
  - Development: `docker-compose.development.yml`
  - Production: `docker-compose.production.yml`
- **Nginx**: Reverse proxy and static file serving
- **Mailserver**: Docker-based email server (production)
- **Sakura VPS**: Production hosting environment

## Email System
- **Development**: MailHog (email testing)
- **Production**: Custom mailserver with security configurations
- **SMTP**: Configurable SMTP settings via environment variables

## Architecture Benefits
- **Single Codebase**: Frontend and backend in one Next.js app
- **Type Safety**: End-to-end TypeScript coverage
- **Performance**: App Router for optimal loading and SEO
- **Modern Tooling**: Biome for fast development workflow
- **Scalable Deployment**: Docker-based multi-environment setup