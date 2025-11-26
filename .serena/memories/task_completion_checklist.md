# Task Completion Checklist

## Before Completing Any Development Task

### Code Quality Checks (Required)

#### 1. Biome Code Quality
```bash
# Run all checks before committing
make lint          # Check for linting errors
make format        # Format code consistently
make build         # Ensure production build works

# Alternative from web/ directory:
npm run check:fix  # Run all checks and auto-fix issues
npm run type-check # TypeScript type checking
```

#### 2. Manual Code Review
- **TypeScript**: Ensure no `any` types, proper type definitions
- **Import Organization**: Clean import statements, proper aliases
- **Component Structure**: Follow established patterns
- **Error Handling**: Proper error boundaries and validation

### Functionality Testing

#### 3. Development Server Testing  
```bash
# Start development environment
make dev           # http://localhost:3000
```
- **Page Navigation**: Test all routes work correctly
- **Form Functionality**: Test contact and recruitment forms
- **Responsive Design**: Check mobile and desktop layouts
- **Browser Console**: No JavaScript errors

#### 4. Email Testing (If Applicable)
```bash
# Start email testing service
make up            # MailHog/Mailcatcher at http://localhost:8025
```
- **Form Submissions**: Test email sending through forms
- **Email Templates**: Verify email content and formatting
- **SMTP Connectivity**: Ensure emails are received in testing UI

### Build and Production Readiness

#### 5. Production Build Verification
```bash
make build         # Ensure build succeeds without errors
make start         # Test production build locally
```
- **Build Output**: No errors or critical warnings
- **Asset Optimization**: Check bundle sizes are reasonable
- **Runtime Testing**: Test critical functionality in production mode

### Documentation and Environment

#### 6. Environment Configuration
- **Environment Variables**: Ensure all required vars are documented
- **Docker Configuration**: Test relevant Docker commands if needed
- **Documentation Updates**: Update relevant documentation if changes affect setup

#### 7. Feature-Specific Checks

##### Contact Form Tasks:
- [ ] Form validation works (required fields, email format)
- [ ] Success page displays after submission
- [ ] Email is sent and received in testing environment
- [ ] Error handling for failed email sends

##### Recruitment Entry Tasks:
- [ ] All form fields validated correctly
- [ ] File uploads work (if applicable)
- [ ] Confirmation flow works end-to-end
- [ ] Email notifications sent to appropriate recipients

##### UI/Component Tasks:
- [ ] Component renders correctly on all screen sizes
- [ ] Accessibility standards met (proper ARIA labels, keyboard navigation)
- [ ] Performance impact is minimal
- [ ] Integrates properly with existing design system

### Final Verification Steps

#### 8. Cross-Platform Testing
- **Different Browsers**: Test in Chrome, Firefox, Safari
- **Mobile Devices**: Test responsive behavior
- **Email Clients**: Test email rendering if email changes made

#### 9. Git and Version Control
```bash
git status         # Review all changed files
git diff          # Review all changes before committing
```
- **Staged Changes**: Only include relevant changes
- **Commit Message**: Clear, descriptive commit message
- **Branch Status**: Working on appropriate branch

### Emergency Rollback Procedures
- **Docker Reset**: `make destroy` if Docker issues occur
- **Node Modules**: Delete `node_modules` and run `make install` if dependency issues
- **Git Reset**: Know how to revert changes if issues found after commit

## Required Commands Before Any Commit
```bash
# Minimum required workflow:
make lint format build

# Recommended full workflow:
make install       # Ensure dependencies up to date
make up           # Start email testing (if needed)
make dev          # Manual testing
make lint format build  # Code quality and build verification
```

## Notes
- **Never commit code that fails `make build`**
- **Always test email functionality if touching forms**
- **Check both Japanese and English text display properly**
- **Verify mobile responsiveness for all UI changes**