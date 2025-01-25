class WordStreamer {
  static Stream<String> streamWords(String text, int delayMs) async* {
    // If no delay, return the whole text at once
    if (delayMs <= 0) {
      yield text;
      return;
    }

    // Split into chunks instead of individual words for better performance
    final chunkSize = 3; // Process 3 words at a time
    final words = text.split(' ');
    String buffer = '';

    for (var i = 0; i < words.length; i += chunkSize) {
      buffer = words.skip(i).take(chunkSize).join(' ') + ' ';
      yield buffer;

      // Add a small delay between chunks
      await Future.delayed(Duration(milliseconds: delayMs));
    }
  }
}