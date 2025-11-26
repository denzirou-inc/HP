# Codebase Structure

## Root Directory Structure
```
company-web/
├── docker/                # Docker configuration and compose files
├── web/                   # Next.js frontend application
├── deploy/                # Deployment scripts and configuration
├── docs/                  # Project documentation
├── nginx/                 # Nginx proxy configuration
├── scripts/               # Shell scripts for email management
├── .serena/               # Serena MCP configuration
├── .claude/               # Claude Code configuration
├── .github/               # GitHub workflows
├── .vscode/               # VS Code settings
├── Makefile              # Docker management commands
├── .mcp.json             # MCP server configuration
├── ReadMe.md             # Project documentation (Japanese)
├── .env.production.example # Production environment template
└── .gitignore
```

## Frontend Structure (web/)
```
web/
├── src/app/
│   ├── components/        # Shared UI components
│   │   ├── Header.tsx
│   │   ├── Footer.tsx
│   │   ├── MainNavigation.tsx
│   │   ├── Slider.tsx
│   │   └── AnimationButton.tsx
│   ├── features/          # Feature-specific components
│   │   ├── contact/
│   │   │   ├── components/
│   │   │   └── schemas/
│   │   └── entry/
│   │       ├── components/
│   │       └── schemas/
│   ├── api/               # API routes
│   │   ├── contact/send/  # Contact form API
│   │   └── health/        # Health check API
│   ├── hooks/             # Custom React hooks
│   ├── libs/              # Third-party library configurations
│   ├── styles/            # Global styles
│   ├── utils/             # Utility functions
│   ├── contact/           # Contact page routes
│   ├── recruit/           # Recruitment page routes
│   ├── layout.tsx         # Root layout
│   ├── page.tsx           # Home page (in (home) directory)
│   ├── not-found.tsx      # 404 page
│   ├── globals.css        # Global CSS
│   └── favicon.ico
├── public/                # Static assets
│   ├── images/            # Image files (logo, backgrounds, etc.)
│   └── icons/             # Icon files
├── package.json           # Dependencies and scripts
├── next.config.mjs        # Next.js configuration
├── tailwind.config.ts     # Tailwind CSS configuration
├── tsconfig.json          # TypeScript configuration
├── biome.json            # Biome linter/formatter configuration
└── postcss.config.mjs    # PostCSS configuration
```

## Docker Structure
```
docker/
├── docker-compose.local.yml      # Local development
├── docker-compose.development.yml # Development environment
├── docker-compose.production.yml  # Production environment
├── mailserver/                    # Email server configuration
│   ├── data/                     # Mailserver data
│   ├── security/                 # Security configurations
│   ├── init-hooks/               # Initialization scripts
│   ├── setup-mailserver.sh       # Mailserver setup script
│   └── docker-compose.mailserver.yml
├── nginx/                        # Nginx configuration
│   ├── nextjs.conf              # Production config
│   └── nextjs.dev.conf          # Development config
└── web/
    └── Dockerfile               # Web application container
```

## Deploy Structure
```
deploy/
├── config/                      # Environment configurations
│   ├── deploy.conf
│   ├── development.env
│   ├── production.env
│   └── production.env.example
├── logs/                        # Deployment logs
├── deploy-development.sh        # Development deployment script
├── deploy-production.sh         # Production deployment script
├── setup-server.sh             # Server setup script
├── monitor.sh                  # Monitoring script
└── README.md                   # Deploy documentation
```

## Documentation Structure
```
docs/
├── ARCHITECTURE.md              # System architecture
├── DEPLOYMENT_GUIDE.md          # Deployment guide
├── DNS_SETUP_GUIDE.md          # DNS configuration
├── EMAIL_MANAGEMENT_GUIDE.md   # Email management
├── MAILSERVER_*.md             # Mailserver documentation
├── MULTI_ENV_DESIGN.md         # Multi-environment design
└── PROJECT_CLEANUP_SUMMARY.md  # Project cleanup notes
```

## Key Features by Directory
- **Contact System**: `web/src/app/contact/` + `web/src/app/features/contact/` + `web/src/app/api/contact/`
- **Recruitment System**: `web/src/app/recruit/` + `web/src/app/features/entry/`
- **Shared Components**: `web/src/app/components/`
- **Form Validation**: Schema files in `features/*/schemas/`
- **API Endpoints**: Next.js API routes in `web/src/app/api/`
- **Email Management**: Scripts in `scripts/` directory
- **Multi-Environment Deployment**: Deploy scripts and Docker configurations

## Architecture Notes
- **Frontend**: Next.js 14+ with App Router
- **Styling**: Tailwind CSS + PostCSS
- **Type Safety**: TypeScript throughout
- **Code Quality**: Biome for linting and formatting
- **Deployment**: Docker-based multi-environment setup
- **Email**: Dedicated mailserver with security configurations
- **Infrastructure**: Sakura VPS with custom deployment automation