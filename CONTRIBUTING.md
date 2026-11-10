# Contributing Guidelines

Thank you for considering contributing to chrono32-watch! We welcome contributions from everyone.

---

## Code of Conduct

This project adheres to our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

---

## How Can I Contribute?

### Reporting Bugs

Before creating a bug report, check the [issue tracker](https://github.com/thatcoderphil12/chrono32-watch/issues) to see if it has already been reported.

When creating a bug report, please include:

* **A clear, descriptive title**
* **Steps to reproduce the issue**
* **Expected vs. actual behavior**
* **Screenshots or logs** (if applicable)
* **Environment details** (OS, compiler version, toolchain versions)

### Suggesting Enhancements

Feature requests are tracked as GitHub issues. Please provide:

* **A clear summary** of the feature
* **The problem it solves** or why it would be useful
* **Proposed solution or design** (if any)

### Pull Requests

1. **Fork the repository** and create your branch from `main`:
```bash
git checkout -b feature/my-new-feature

```


2. **Write or update tests** for your changes.
3. **Ensure all tests pass** locally before submitting.
4. **Open a PR** with a **Conventional Commit title** (e.g., `feat(core): add thread-safe caching layer`) that summarizes your changes and links any related issues (e.g., `Closes #123`).

---

## Commit Message Guidelines & PR Style

We strictly follow the **Conventional Commits** specification. This convention helps automatically generate changelogs and manage version bumps.

### Commit Format

```text
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]

```

### Allowed Types

* **`feat`**: A new feature (corresponds to a minor semantic version bump).
* **`fix`**: A bug fix (corresponds to a patch semantic version bump).
* **`docs`**: Documentation only changes.
* **`style`**: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc.).
* **`refactor`**: A code change that neither fixes a bug nor adds a feature.
* **`perf`**: A code change that improves performance.
* **`test`**: Adding missing tests or correcting existing tests.
* **`chore`**: Changes to the build process or auxiliary tools and libraries.

### Pull Request Title Style

Your pull request title must also follow the Conventional Commits format. When your PR is merged, the title will be used for the squash commit or merge commit message.

* *Example:* `feat(swift): integrate new feature update`
* *Example:* `fix(cpp): resolve memory leak in parser`
