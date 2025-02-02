# Change Log

## [1.1.3] - 2024-02-01

Temporary chats and better model fetching.

### Enhancements

- **Improved model fetching**: Integrated a unified API for fetching the latest model information.
- **Added temporary chats**: Now you can create temporary chats that are not saved in the database.
- **Better response loading**: Added an indicator when waiting for AI responses.

### Bug Fixes

- **Empty message bubbles**: Fixed a bug where empty message bubbles were displayed.
- **Frozen chats**: Chats no longer freeze when streaming responses.
- **Broken theme**: The default theme colors for light mode have been fixed.
- **Async Analytics**: Analytics load in the background at startup now.

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
