class FavoriteQuote {
  final String text;
  final String author;

  FavoriteQuote({
    required this.text,
    required this.author,
  });

  factory FavoriteQuote.fromMap(Map<String, dynamic> map) {
    return FavoriteQuote(
      text: map['text'] ?? '',
      author: map['author'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'author': author,
    };
  }
}
