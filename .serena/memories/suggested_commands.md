# Suggested Commands for Development

## Local Development (Recommended)

### Getting Started
```bash
# Install dependencies
make install

# Start development server (http://localhost:3000)
make dev
```

### Daily Development Commands
```bash
# Code quality checks
make lint          # Run Biome linting
make format        # Run Biome formatting

# Building
make build         # Production build
make start         # Start production server locally
```

### Email Testing Setup
```bash
# Start MailHog/Mailcatcher for email testing
make up            # SMTP: localhost:1025, Web UI: http://localhost:8025

# Check email service status
make status

# View email service logs
make logs

# Stop email services
make down

# Reset email environment (if issues occur)
make destroy
```

## Email Management (Production)

### Account Management
```bash
# List all email accounts
make email-list

# Create new email account
make email-create EMAIL=user@denzirou.com
make email-create EMAIL=user@denzirou.com PASS=mypassword

# Delete email account
make email-delete EMAIL=user@denzirou.com

# Change email password
make email-password EMAIL=user@denzirou.com
make email-password EMAIL=user@denzirou.com PASS=newpassword

# Quick test accounts
make email-quick-test    # Creates test+date@denzirou.com
make email-quick-temp    # Creates temp+time@denzirou.com
```

### Email Administration
```bash
# Interactive email management panel
make email-admin

# Email statistics
make email-stats

# Email management help
make email-help
```

## Development Workflow

### Before Starting Work
```bash
# 1. Install dependencies (first time)
make install

# 2. Start email testing service (for contact forms)
make up

# 3. Start development server
make dev
```

### During Development
```bash
# Check code quality frequently
make lint format

# Test email functionality at http://localhost:8025
# (when using contact forms or recruitment submissions)
```

### Before Committing
```bash
# Always run these before committing
make lint          # Fix any linting errors
make format        # Ensure consistent formatting
make build         # Ensure production build works

# Test functionality manually in browser
```

## Platform-Specific Notes

### Architecture Detection
- **ARM64 (M1/M2 Mac)**: Uses Mailcatcher with ARM64 profile
- **Intel/AMD64**: Uses MailHog with Intel profile
- Platform automatically detected via `uname -m`

### Port Information
- **Development Server**: http://localhost:3000
- **Email Testing UI**: http://localhost:8025
- **SMTP Server**: localhost:1025

## Docker Environment Information
- **Project Name**: `denzirou-company-web`
- **Compose File**: `docker/docker-compose.local.yml`
- **Profiles**: `arm64` or `intel` (auto-detected)

## Useful File Locations
- **Web App**: `web/` directory
- **Email Scripts**: `scripts/` directory
- **Docker Config**: `docker/` directory
- **Deployment**: `deploy/` directory

## TypeScript Development
```bash
# Type checking (from web/ directory)
cd web && npm run type-check

# Alternative Biome commands (from web/ directory)
cd web && npm run check        # Check without fixing
cd web && npm run check:fix    # Check and auto-fix
```