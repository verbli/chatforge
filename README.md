# ChatForge

ChatForge is a versatile, privacy-focused chat application that enables seamless interaction with Large Language Models (LLMs). Built with Flutter, it prioritizes user privacy by keeping data local while providing powerful features for both individual users and enterprises.

[![en](google_play.svg)](https://play.google.com/store/apps/details?id=org.verbli.chatforge)

## Support
If you find ChatForge useful and want to support its development, consider buying me a coffee! Your support helps keep this project alive and growing.


[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/yellow_img.png)](https://www.buymeacoffee.com/eshipman)


## Features

### Current Features
- **Local Storage**: All data is stored securely with SQLite, ensuring your conversations remain private
- **Multiple Conversations**: Manage and organize multiple chat sessions simultaneously
- **Conversation Rewind**: Edit previous messages and regenerate responses from any point
- **Custom Prompts & Settings**: Personalize system prompts and fine-tune model parameters
- **OpenAI Integration**: Seamless access to OpenAI's powerful language models

### Coming Soon
- Additional LLM Provider Support (Anthropic, Gemini, etc.)
- Detailed Usage Statistics and Analytics
- Cross-Platform Support (Web, Windows, Linux)
- External Backend Options (Supabase, Firebase, Appwrite, PocketBase)

## Installation

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK (latest stable version)
- Android Studio / VS Code with Flutter extensions

### Getting Started
1. Clone the repository
```bash
git clone https://github.com/verbli/chatforge.git
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run
```

## Building

### Build Variants
ChatForge supports multiple build configurations:

- **Community Edition** (GPLv3)
    - Free with ads
    - Local storage only
    - Basic features

- **Pro Edition** (GPLv3)
    - Ad-free experience

- **Enterprise Edition** (Commercial License)
    - _Coming Soon_

### Build Command
```bash
flutter build apk --dart-define=IS_PRO=true --dart-define=ENABLE_ADS=false
```

## Contributing
Contributions are welcome! Please read our [Contributing Guidelines](CONTRIBUTING.md) before submitting pull requests.

## License
ChatForge is released under GPLv3 for personal use only. For commercial use, [**contact](mailto:info@verbli.org)** for details

See the [LICENSE](LICENSE.md) file for details.

## Support
If you find ChatForge useful and want to support its development, consider buying me a coffee! Your support helps keep this project alive and growing.


[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/yellow_img.png)](https://www.buymeacoffee.com/eshipman)


### Perks for Members and Supporters
- Access to pro APK
- Have a say in development direction

## Acknowledgments
See [ACKNOWLEDGMENTS.md](ACKNOWLEDGMENTS.md) for a list of open source libraries used in this project.
