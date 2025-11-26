# Code Style and Conventions

## Frontend (TypeScript/React/Next.js)

### Code Quality Tools
- **Biome**: 2.2.2 (replaces ESLint + Prettier)
  - Linting: `npm run lint` or `make lint`
  - Formatting: `npm run format` or `make format`
  - Combined check: `npm run check` or `npm run check:fix`
- **TypeScript**: Type checking with `npm run type-check`

### Component Architecture
- **Next.js App Router**: Uses Next.js 14+ App Router pattern
- **File Structure**: Feature-based organization
  ```
  app/
  ├── components/     # Shared components
  ├── features/       # Feature-specific components and schemas
  ├── api/           # API routes
  ├── [pages]/       # Route-based pages
  └── globals.css    # Global styles
  ```

### Naming Conventions
- **Components**: PascalCase (e.g., `ContactForm.tsx`)
- **Files**: kebab-case for pages, PascalCase for components
- **Directories**: lowercase with hyphens where needed
- **API Routes**: `route.ts` in directory-based structure

### TypeScript Standards
- **Strict Type Safety**: Full TypeScript coverage
- **Zod Schemas**: Used for form validation and API validation
- **Import Aliases**: Uses `@/` for app directory imports
- **Type Definitions**: Co-located with components when specific

### Styling Conventions
- **Tailwind CSS**: Utility-first approach
- **Material-UI**: Used for complex components
- **Responsive Design**: Mobile-first with Tailwind breakpoints
- **Japanese Fonts**: Kosugi Maru for Japanese text

## Form Handling Standards
- **React Hook Form**: For form state management
- **Zod Validation**: Schema-first validation approach
- **Error Handling**: Consistent error message patterns
- **Success States**: Confirmation pages for form submissions

## API Development Conventions
- **Next.js API Routes**: RESTful endpoint structure
- **Request Validation**: Zod schemas for input validation
- **Error Responses**: Consistent JSON error format
- **Environment Variables**: Typed environment configuration

## Email System Standards
- **Nodemailer**: SMTP email sending
- **Template Structure**: Consistent HTML email templates
- **Error Handling**: Graceful email sending failure handling
- **Testing**: MailHog/Mailcatcher for development testing

## Development Workflow
- **Local Development**: `make dev` for hot reload development
- **Code Quality**: Run `make lint format` before commits
- **Build Verification**: `make build` to ensure production readiness
- **Email Testing**: `make up` to start email testing services

## Git Conventions
- **Branch Naming**: `feature/description` or `fix/description`
- **Commit Messages**: Clear, descriptive messages in English
- **Language Mix**: UI text in Japanese, code/comments in English

## Environment Management
- **Multiple Environments**: Local, development, production
- **Environment Variables**: Proper separation of config per environment
- **Docker**: Multi-stage builds for different environments

## Performance Standards
- **Next.js Optimization**: Leverage App Router features
- **Bundle Analysis**: Monitor build output for optimization
- **Image Optimization**: Use Next.js Image component
- **SEO**: Proper meta tags and structured data

## Security Practices
- **Input Validation**: All user inputs validated with Zod
- **Environment Secrets**: Never commit sensitive data
- **SMTP Security**: Secure email configuration
- **Type Safety**: TypeScript prevents runtime errors