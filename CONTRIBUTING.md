# Contributing to ChatForge

First off, thank you for considering contributing to ChatForge! It's people like you that make ChatForge such a great tool.

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to [project email].

## How Can I Contribute?

### Reporting Bugs

#### Before Submitting A Bug Report

* Check the documentation for a list of common questions and problems.
* Perform a cursory search to see if the bug has already been reported.
* Ensure you're using the latest version of the app.
* Check if the issue is specific to a platform (Android, iOS, Web, etc.).

#### How Do I Submit A (Good) Bug Report?

Bugs are tracked as GitHub issues. Create an issue and provide the following information:

* Use a clear and descriptive title
* Describe the exact steps which reproduce the problem
* Provide specific examples to demonstrate the steps
* Describe the behavior you observed after following the steps
* Explain which behavior you expected to see instead and why
* Include screenshots and animated GIFs if possible
* Include your environment details:
    * Device/OS version
    * App version
    * Backend type (if applicable)
    * AI provider being used
* Include any relevant logs or error messages

### Suggesting Enhancements

#### Before Submitting An Enhancement Suggestion

* Check if there's already a package that provides that enhancement.
* Check the issues list to see if it's already been suggested.
* Verify that your enhancement is consistent with the app's architecture.

#### How Do I Submit A (Good) Enhancement Suggestion?

Enhancement suggestions are tracked as GitHub issues. Create an issue and provide the following information:

* Use a clear and descriptive title
* Provide a step-by-step description of the suggested enhancement
* Provide specific examples to demonstrate the proposed enhancement
* Describe the current behavior and explain why it's insufficient
* Explain why this enhancement would be useful to most ChatForge users
* List some other applications where this enhancement exists, if applicable
* Specify which version of ChatForge you're using
* Specify the platform you're using (Android, iOS, Web, etc.)

### Pull Requests

#### Development Process

1. Fork the repo and create your branch from `main`.
2. If you've added code that should be tested, add tests.
3. If you've changed APIs, update the documentation.
4. Ensure all tests pass.
5. Make sure your code follows the existing style guidelines.
6. Write a good commit message.

#### Pull Request Process

1. Update the README.md with details of changes if applicable.
2. Update the documentation with any new dependencies, platform requirements, etc.
3. The PR will be merged once you have the sign-off of two maintainers.

### Styleguides

#### Git Commit Messages

* Use the present tense ("Add feature" not "Added feature")
* Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
* Limit the first line to 72 characters or less
* Reference issues and pull requests liberally after the first line
* Consider starting the commit message with an applicable emoji:
    * 🎨 `:art:` when improving the format/structure of the code
    * 🐎 `:racehorse:` when improving performance
    * 🚱 `:non-potable_water:` when plugging memory leaks
    * 📝 `:memo:` when writing docs
    * 🐛 `:bug:` when fixing a bug
    * 🔥 `:fire:` when removing code or files
    * 💚 `:green_heart:` when fixing CI
    * ✅ `:white_check_mark:` when adding tests
    * 🔒 `:lock:` when dealing with security
    * ⬆️ `:arrow_up:` when upgrading dependencies
    * ⬇️ `:arrow_down:` when downgrading dependencies

#### Dart Style Guide

Follow the [official Dart style guide](https://dart.dev/guides/language/effective-dart/style) and these additional rules:

* Use `final` or `const` whenever possible
* Sort imports alphabetically
* Group imports by type (dart, package, relative)
* Use explicit types for public APIs
* Document all public APIs with dartdoc comments
* Keep lines under 80 characters
* Use trailing commas for better formatting

```dart
// Good
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../services/auth_service.dart';

/// A widget that displays user information.
class UserInfoWidget extends StatelessWidget {
  final User user;
  final VoidCallback onLogout;

  const UserInfoWidget({
    required this.user,
    required this.onLogout,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(user.name),
          ElevatedButton(
            onPressed: onLogout,
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
```

#### Documentation Styleguide

* Use [Markdown](https://guides.github.com/features/mastering-markdown/).
* Document all public APIs.
* Include code examples for complex functionality.
* Keep documentation up to date with code changes.
* Reference the version number when documenting features.

### Testing Guidelines

* Write tests for all new features and bug fixes
* Maintain or improve test coverage with each PR
* Follow the testing pyramid:
    * Unit tests for business logic
    * Widget tests for UI components
    * Integration tests for critical user flows

#### Example Test Structure

```dart
void main() {
  group('UserRepository', () {
    late UserRepository repository;
    late MockAuthService authService;

    setUp(() {
      authService = MockAuthService();
      repository = UserRepository(authService);
    });

    test('getCurrentUser returns user when authenticated', () async {
      // Arrange
      final expectedUser = User(id: '1', name: 'Test User');
      when(authService.currentUser).thenReturn(expectedUser);

      // Act
      final result = await repository.getCurrentUser();

      // Assert
      expect(result, expectedUser);
    });
  });
}
```

### Branch Naming Convention

* Feature branches: `feature/description`
* Bug fix branches: `fix/description`
* Documentation branches: `docs/description`
* Performance improvement branches: `perf/description`

Example: `feature/add-gemini-support`

### Review Process

1. **Code Quality**
    * Follows style guide
    * No code smells
    * Appropriate error handling
    * Proper null safety usage

2. **Testing**
    * Adequate test coverage
    * Tests pass
    * Edge cases covered
    * Performance impact considered

3. **Documentation**
    * Code is self-documenting
    * Comments where necessary
    * API documentation updated
    * README updated if needed

4. **Security**
    * No sensitive data exposed
    * Proper input validation
    * Secure API usage
    * Authentication/Authorization handled correctly

### Development Environment Setup

1. Install Flutter SDK (latest stable version)
2. Install Android Studio or VS Code with Flutter plugins
3. Clone the repository
4. Run `flutter pub get`
5. Setup your `.env` file based on `.env.example`
6. Run tests: `flutter test`
7. Start the app: `flutter run`

### First Time Contributors

Look for issues tagged with `good first issue` or `help wanted`. These are carefully selected for new contributors.

## License

By contributing, you agree that your contributions will be licensed under the project's license terms.

Remember, every contribution matters, whether it's:
* Writing tutorials or blog posts
* Improving documentation
* Submitting bug reports and feature requests
* Writing code which can be incorporated into the project
* Answering questions in discussions or issues
* Reviewing pull requests

Thank you for contributing to ChatForge! 🚀