# Company-Web Project Overview

## Purpose
This is a web application for "株式会社藤原伝次郎商店" (Denzirou Inc.) SE department. It's a company website featuring recruitment entry and contact functionality.

## Architecture
- **Full-stack Next.js application** with API routes
- **Frontend**: Next.js 14+ with App Router and TypeScript
- **Backend**: Next.js API Routes (no separate backend server)
- **Email**: Nodemailer for contact form and recruitment submissions
- **Infrastructure**: Docker-based deployment with multiple environments
- **Styling**: Tailwind CSS with Material-UI components

## Current Project Structure
```
company-web/
├── docker/          # Docker configuration and compose files
├── web/            # Next.js full-stack application
├── deploy/         # Deployment scripts and configuration
├── docs/           # Project documentation
├── nginx/          # Nginx proxy configuration  
├── scripts/        # Email management scripts
├── Makefile        # Management commands
└── ReadMe.md       # Project documentation (Japanese)
```

## Key Features
- Recruitment entry system (`/recruit/entry`)
- Contact form system (`/contact`) 
- Responsive design with Japanese fonts (Kosugi Maru)
- Form validation using Zod schemas
- Email notifications via Nodemailer
- Multi-environment deployment support

## Environment Configurations
- **Local Development**: `npm run dev` in web/ directory
- **Docker Development**: `docker-compose.development.yml`
- **Production**: `docker-compose.production.yml` with mailserver
- **Sakura VPS**: Production deployment with custom scripts

## Technical Migration Status
- **Migrated from**: Laravel 11 backend + Next.js frontend
- **Current**: Next.js full-stack with API routes
- **Benefits**: Simplified deployment, reduced infrastructure complexity
- **Email**: Switched from Laravel Mail to Nodemailer

## Deployment
- Automated deployment scripts in `deploy/` directory
- Multiple environment support (development/production)
- Integrated mailserver configuration
- Monitoring and logging capabilities