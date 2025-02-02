# ChatForge

ChatForge is a versatile, privacy-focused chat application that enables seamless interaction with Large Language Models (LLMs). Built with Flutter, it prioritizes user privacy by keeping data local while providing powerful features for both individual users and enterprises. With support for multiple AI providers and customizable themes, ChatForge offers a premium chat experience without compromising on privacy.

[![en](google_play.svg)](https://play.google.com/store/apps/details?id=org.verbli.chatforge)

## Support
If you find ChatForge useful and want to support its development, consider buying me a coffee! Your support helps keep this project alive and growing.


[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/yellow_img.png)](https://www.buymeacoffee.com/eshipman)


## Features

### Current Features
- **Privacy-First Architecture**
  - Local SQLite storage for all conversations and settings
  - No data collection or tracking
  - Optional temporary chats that delete on close

- **Advanced Chat Features**
  - Multiple concurrent conversations with different models
  - Edit and regenerate from any point in chat history
  - Markdown and code syntax highlighting
  - Word-by-word streaming for natural response flow

- **AI Provider Integration**
  - Support for OpenAI, Anthropic Claude, and Google Gemini
  - Dynamic model fetching and capabilities detection
  - Fine-grained control over model parameters
  - Customizable system prompts per conversation

- **Rich UI/UX**
  - Multiple theme options (ChatForge, ChatGPT, Claude, Gemini styles)
  - Light/dark mode support
  - Responsive design for mobile and desktop
  - Custom syntax highlighting themes

- **Linux Desktop**: Run ChatForge on Linux!

### Coming Soon
- Detailed Usage Statistics and Analytics
- Cross-Platform Support (Web, Windows)
- External Backend Options (Supabase, Firebase, Appwrite, PocketBase)

### Pro Features
- Ad-free experience

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

#### Community Edition (GPLv3)
- Free with ads
- Local storage only
- All core features included
- Basic customization options

#### Pro Edition (GPLv3)
- Ad-free experience

#### Enterprise Edition (Commercial License)
- _Coming Soon_
- Custom branding

### Build Commands
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
