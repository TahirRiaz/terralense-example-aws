# Contributing to Terralense Example AWS

Thank you for your interest in contributing! This document provides guidelines for contributing to this example repository.

## Purpose

This repository serves as a realistic example of multi-project Terraform infrastructure to demonstrate the capabilities of Terralense. Contributions should maintain this purpose and add value for users learning about Terraform project organization and dependency management.

## How to Contribute

### Reporting Issues

If you find issues with the Terraform configurations:

1. Check existing issues to avoid duplicates
2. Create a new issue with:
   - Clear description of the problem
   - Steps to reproduce
   - Expected vs actual behavior
   - Terraform version and provider versions

### Suggesting Enhancements

For new features or improvements:

1. Open an issue describing the enhancement
2. Explain the use case and benefits
3. Discuss implementation approach
4. Wait for maintainer feedback before implementing

### Pull Requests

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/your-feature-name`
3. **Make your changes**:
   - Follow existing code style and conventions
   - Update documentation as needed
   - Ensure Terraform configurations are valid
4. **Test your changes**:
   ```bash
   terraform init
   terraform validate
   terraform plan
   ```
5. **Commit with clear messages**:
   ```
   feat: add CloudFront distribution to compute project

   - Add CloudFront distribution for CDN
   - Update ALB to work with CloudFront
   - Add CloudFront monitoring to monitoring project
   ```
6. **Push to your fork**: `git push origin feature/your-feature-name`
7. **Create a Pull Request**

## Coding Standards

### Terraform Style

Follow the [Terraform Style Guide](https://www.terraform.io/docs/language/syntax/style.html):

- Use 2 spaces for indentation
- Use snake_case for resource names
- Group related resources together
- Add comments for complex logic
- Use variables for configurable values

### File Organization

```
project/
├── backend.tf      # Backend configuration
├── versions.tf     # Terraform and provider versions
├── variables.tf    # Input variables
├── main.tf         # Main resources
├── data.tf         # Data sources (including remote state)
├── outputs.tf      # Output values
└── *.tf            # Additional logical groupings
```

### Variable Naming

- Use descriptive names: `db_instance_class` not `instance`
- Include type and description for all variables
- Provide sensible defaults where appropriate
- Group related variables together

### Documentation

- Update README.md for structural changes
- Add inline comments for complex logic
- Document all variables and outputs
- Include examples in module READMEs

## Testing

Before submitting:

1. **Validate syntax**:
   ```bash
   terraform fmt -check -recursive
   terraform validate
   ```

2. **Check for security issues**:
   ```bash
   # Install tfsec
   brew install tfsec

   # Run security scan
   tfsec .
   ```

3. **Test deployment** (if possible):
   - Deploy to a test AWS account
   - Verify all resources created successfully
   - Test cross-project dependencies
   - Clean up resources

## Project Structure Guidelines

### Adding New Projects

New projects should:

1. Have clear dependencies on existing projects
2. Use remote state for cross-project references
3. Follow the existing project numbering scheme
4. Include comprehensive outputs for dependent projects
5. Be documented in the main README.md

### Adding New Modules

New modules should:

1. Solve a reusable problem
2. Be well-documented with examples
3. Include all necessary variables and outputs
4. Follow module best practices
5. Be used in at least one project

## Dependency Management

When adding cross-project dependencies:

1. Always use `terraform_remote_state` data source
2. Reference outputs explicitly (don't assume structure)
3. Document dependencies in project README
4. Consider deployment order implications
5. Update DEPLOYMENT.md with new steps

## Review Process

1. Maintainers will review PRs within 1 week
2. Address feedback in your branch
3. Once approved, maintainers will merge
4. Delete your feature branch after merge

## Questions?

Open an issue with the `question` label or reach out to maintainers.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
