# Contributing to Portfolio CMS

Thank you for your interest in contributing to Portfolio CMS! This document provides guidelines and instructions for contributing.

## How to Contribute

### Reporting Bugs

1. Check if the bug has already been reported in [Issues](https://github.com/yourusername/portfolio/issues)
2. If not, create a new issue with:
   - Clear title and description
   - Steps to reproduce
   - Expected vs actual behavior
   - Screenshots (if applicable)
   - Environment details (Flutter version, OS, etc.)

### Suggesting Features

1. Check if the feature has already been suggested
2. Create a new issue with:
   - Clear description of the feature
   - Use case and benefits
   - Mockups or examples (if applicable)

### Code Contributions

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes**
   - Follow the code style
   - Add comments for complex logic
   - Update documentation if needed
4. **Test your changes**
   - Run the app and test functionality
   - Check for linter errors: `flutter analyze`
5. **Commit your changes**
   ```bash
   git commit -m "Add: Description of your feature"
   ```
6. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```
7. **Create a Pull Request**
   - Provide a clear description
   - Reference related issues
   - Add screenshots if UI changes

## Code Style

- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions focused and small
- Use `flutter format` before committing

## Project Structure

- `lib/core/` - Core services, repositories, config
- `lib/features/` - Feature modules
- `lib/models/` - Data models
- `lib/shared/` - Shared widgets, utils, constants
- `lib/views/` - UI screens
- `docs/` - Documentation

## Testing

Before submitting:

- [ ] Code compiles without errors
- [ ] No linter warnings: `flutter analyze`
- [ ] App runs on web/mobile
- [ ] New features are tested
- [ ] Documentation updated (if needed)

## Questions?

Feel free to open an issue for questions or discussions!

Thank you for contributing! 🎉

