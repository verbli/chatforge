class WordStreamer {
  static Stream<String> streamWords(String text, int delayMs) async* {
    int index = 0;

    while (index < text.length) {
      // If we're at a whitespace character, consume all consecutive whitespace
      if (text[index].trim().isEmpty) {
        int whitespaceEnd = index;
        while (whitespaceEnd < text.length && text[whitespaceEnd].trim().isEmpty) {
          whitespaceEnd++;
        }
        yield text.substring(index, whitespaceEnd);
        index = whitespaceEnd;
        if (delayMs > 0) {
          await Future.delayed(Duration(milliseconds: delayMs));
        }
        continue;
      }

      // If we're at a non-whitespace character, consume until we hit whitespace
      int wordEnd = index;
      while (wordEnd < text.length && text[wordEnd].trim().isNotEmpty) {
        wordEnd++;
      }
      yield text.substring(index, wordEnd);
      index = wordEnd;

      if (delayMs > 0) {
        await Future.delayed(Duration(milliseconds: delayMs));
      }
    }
  }
}