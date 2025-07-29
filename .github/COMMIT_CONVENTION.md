# 📝 Commit Convention

Kotlinish follows the **Conventional Commits** specification to keep our commit history clean and meaningful.

## 🎯 Format

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

## 📋 Types

| Type | Description | Example |
|------|-------------|---------|
| `feat` | New feature | `feat(scope): add let function` |
| `fix` | Bug fix | `fix(collections): resolve null safety in firstOrNull` |
| `docs` | Documentation | `docs(readme): add usage examples` |
| `style` | Code style changes | `style: format code with dart format` |
| `refactor` | Code refactoring | `refactor(scope): simplify apply implementation` |
| `perf` | Performance improvements | `perf(async): optimize isolate pool` |
| `test` | Add/update tests | `test(scope): add tests for run function` |
| `build` | Build system changes | `build: update pubspec dependencies` |
| `ci` | CI/CD changes | `ci: add flutter integration tests` |
| `chore` | Maintenance tasks | `chore: update gitignore` |

## 🎯 Scopes

| Scope | Description |
|-------|-------------|
| `scope` | Scope functions (let, apply, run, also, with) |
| `collections` | Collection extensions and utilities |
| `async` | Concurrency and async utilities |
| `flutter` | Flutter-specific integrations |
| `core` | Core framework functionality |
| `types` | Type extensions (String, int, etc.) |
| `null` | Null safety utilities |

## ✨ Examples

### ✅ Good Commits

```bash
feat(scope): add let function with null safety
fix(collections): resolve crash in firstOrNull with empty list
docs(readme): add installation instructions
test(scope): add comprehensive tests for apply function
perf(async): improve isolate pool performance by 25%
refactor(core): simplify extension registration
style: format all files with dart format
ci: add codecov integration
```

### ❌ Bad Commits

```bash
# Too vague
fix: bug fix
update readme
add stuff

# No scope when needed
feat: new function
fix: broken thing

# Too long description
feat(scope): add a new scope function called let that allows you to perform operations on an object and return a result
```

## 🚀 Advanced Examples

### With Body
```
feat(async): add Channel class for isolate communication

Implements bidirectional communication between isolates
using Dart's SendPort and ReceivePort primitives.
Includes automatic serialization and error handling.

Closes #42
```

### Breaking Changes
```
feat(scope)!: change apply function signature

BREAKING CHANGE: apply now returns void instead of the original object
to match Kotlin's behavior more closely.

Migration: use also() instead of apply() if you need the return value.
```

### Multiple Scopes
```
feat(scope,flutter): add widget-aware scope functions

Adds buildContext-aware versions of scope functions
that automatically handle widget lifecycle.
```

## 🔧 Tools

### Commitizen (Optional)
```bash
# Install globally
npm install -g commitizen cz-conventional-changelog

# Use for commits
git cz
```

### VS Code Extension
Search for "Conventional Commits" in VS Code extensions.

## 📏 Guidelines

- **Keep descriptions under 72 characters**
- **Use present tense** ("add" not "added")
- **Use lowercase** for type and scope
- **No period at the end** of description
- **Reference issues** when applicable (`Closes #123`)
- **Use body for context** when needed
- **Mark breaking changes** with `!` or `BREAKING CHANGE:`

---

**Remember:** Good commits tell a story! 📖