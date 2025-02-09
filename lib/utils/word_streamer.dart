class WordStreamer {
  static Stream<String> streamWords(String text, int delayMs) async* {
    // If no delay, return the whole text at once
    if (delayMs <= 0) {
      yield text;
      return;
    }

    // Stream character by character, buffering until we hit a space
    StringBuffer buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);

      // When we hit a space or it's the last character, yield the buffer
      if (text[i] == ' ' || i == text.length - 1) {
        yield buffer.toString();
        await Future.delayed(Duration(milliseconds: delayMs));
        buffer.clear();
      }
    }
  }
}