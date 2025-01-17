# Change Log

## [1.1.2] - 2024-01-17

Bug fixes and smoother streaming for a better chat experience.

### Enhancements

- **Improved streaming visuals**: Experience smoother, more responsive updates during AI responses.

### Bug Fixes

- **Multiline message input**: Resolved issues that prevented proper line brper line breaks when composing longer messages.
- **Theme colors**: Fixed color inconsistencies and improved overall UI coherence.
- **Message bubble edits**: Removed the extra confirmation prompt, streamlining the editing process.
- **Database concurrency**: Addressed conflicts that could cause intermittent data corruption.
- **Data clearing**: Ensured that clearing data fully resets user information as expected.
- **Markdown toggling**: Fixed the bug preventing markdown rendering preferences from taking effect.
- **System prompt retention**: Preserved custom system prompts when switching providers mid• conversation.


## [1.1.0] - 2024-01-05

Improved AI provider support, expanded model settings, and revamed various UIs.

### Added

- Support for Gemini and Anthropic
- AI model fetching to dynamically retrieve available models
- Additional model settings for supported providers: presence and frequency penalties
- Support for Linux
- More themes to mimic popular apps (ChatGPT, Claude, and Gemini)
- Feature to clear stored data

### Improved

- Enhanced chat creation UI
- Improved AI provider UI

## [1.0.1] - 2024-11-29

Improved app launch time (6 seconds to 2 seconds in test environment).

### Added

- Added a splash screen with animated progress bar

### Changed

- Reworked initialization to load services in parallel

## [1.0.0] - 2024-11-27

Initial release.

- Local storage w/ SQLite
- Multiple conversations
- Conversation rewind
- Custom system prompts and model settings
- OpenAI integration
