# 🤝 Contributing to Kotlinish

Thank you for your interest in contributing to Kotlinish! We love your input and want to make contributing as easy and transparent as possible.

## 🚀 Getting Started

1. **Fork** the repository
2. **Clone** your fork locally
3. **Create a branch** for your feature/fix
4. **Make your changes**
5. **Test** your changes
6. **Submit** a pull request

## 🎯 How Can I Contribute?

### 🐛 Reporting Bugs
- Use the bug report template
- Include clear reproduction steps
- Provide your environment details

### ✨ Suggesting Features
- Use the feature request template
- Explain the motivation and use case
- Consider how it fits with Kotlinish's philosophy

### 💻 Code Contributions
- Pick an issue labeled `good first issue` for beginners
- Check out our [roadmap](README.md#roadmap) for planned features
- Follow our coding standards (see below)

## 📋 Development Guidelines

### Code Style
- Follow standard Dart conventions
- Use meaningful variable and function names
- Add documentation for public APIs
- Keep functions small and focused

### Testing
- Write tests for new features and bug fixes
- Ensure all tests pass before submitting PR
- Test with both Dart and Flutter projects

### Commit Messages
We follow [Conventional Commits](/.github/COMMIT_CONVENTION.md):
```bash
feat(scope): add let function with null safety
fix(collections): resolve crash in firstOrNull  
docs(readme): update installation instructions
test(scope): add comprehensive tests for apply
```

**Install Git hooks** to validate commits automatically:
```bash
bash scripts/install-hooks.sh
```

## 🏗️ Project Structure

```
lib/
├── src/
│   ├── scope_functions/     # let, apply, run, also, with
│   ├── collections/         # Collection extensions
│   ├── async/              # Concurrency utilities
│   └── flutter/            # Flutter-specific extensions
├── kotlinish.dart          # Main export file
test/
├── scope_functions_test.dart
├── collections_test.dart
└── ...
```

## ⚡ Quick Development Setup

```bash
# Clone the repo
git clone https://github.com/your-username/kotlinish.git
cd kotlinish

# Get dependencies
dart pub get

# Run tests
dart test

# Run example (when available)
cd example
flutter run
```

## 🎯 Philosophy & Design Principles

- **Kotlin-inspired, not Kotlin-copied** - Adapt ideas to Dart's strengths
- **Flutter-friendly** - Play well with the Flutter ecosystem
- **Performance-conscious** - Don't sacrifice speed for convenience
- **Developer experience first** - APIs should feel natural and intuitive
- **Backward compatible** - Don't break existing code

## 🤔 Questions?

- Open a discussion in the Issues tab
- Check existing issues and discussions
- Be respectful and constructive

## 📄 Code of Conduct

- Be respectful and inclusive
- Help others learn and grow
- Focus on constructive feedback
- Keep discussions on-topic

---

**Ready to contribute? We're excited to see what you'll build! 🚀**