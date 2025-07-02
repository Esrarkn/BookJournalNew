enum ReadingStatus {
  okunuyor,
  okundu,
  tumKitaplar,
}

extension ReadingStatusExtension on ReadingStatus {
  static ReadingStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'okunuyor':
        return ReadingStatus.okunuyor;
      case 'okundu':
        return ReadingStatus.okundu;
      case 'tumkitaplar':
        return ReadingStatus.tumKitaplar;
      default:
        return ReadingStatus.tumKitaplar;
    }
  }

  String get stringValue {
    switch (this) {
      case ReadingStatus.okunuyor:
        return 'okunuyor';
      case ReadingStatus.okundu:
        return 'okundu';
      case ReadingStatus.tumKitaplar:
        return 'tumKitaplar';
    }
  }
}

class Book {
  final String id;
  final String title;
  final String author;
  final String description;
  final String imageUrl;
  final String summary;
  final String feelings;
  final String quotes;
  final String imagePath;
  final ReadingStatus status;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? category;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.imageUrl,
    required this.summary,
    required this.feelings,
    required this.quotes,
    required this.imagePath,
    required this.status,
    this.startDate,
    this.endDate,
    this.category,
  });

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? description,
    String? imageUrl,
    String? summary,
    String? feelings,
    String? quotes,
    String? imagePath,
    ReadingStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    String? category,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      summary: summary ?? this.summary,
      feelings: feelings ?? this.feelings,
      quotes: quotes ?? this.quotes,
      imagePath: imagePath ?? this.imagePath,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      category: category ?? this.category,
    );
  }

  factory Book.fromGoogleApi(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] ?? {};

    return Book(
      id: json['id'] ?? '',
      title: volumeInfo['title'] ?? '',
      author: volumeInfo['authors']?.join(', ') ?? 'No Author',
      description: volumeInfo['description'] ?? 'No Description',
      imageUrl: volumeInfo['imageLinks']?['thumbnail'] ?? '',
      summary: '',
      feelings: '',
      quotes: '',
      imagePath: '',
      status: ReadingStatus.okunuyor,

    );
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      summary: map['summary'] ?? '',
      feelings: map['feelings'] ?? '',
      quotes: map['quotes'] ?? '',
      imagePath: map['imagePath'] ?? '',
      status: ReadingStatusExtension.fromString(map['status'] ?? 'okunuyor'),
      startDate: map['startDate'] != null ? DateTime.tryParse(map['startDate']) : null,
      endDate: map['endDate'] != null ? DateTime.tryParse(map['endDate']) : null,
      category: map["category"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'imageUrl': imageUrl,
      'summary': summary,
      'feelings': feelings,
      'quotes': quotes,
      'imagePath': imagePath,
      'status': status.stringValue,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      "category" : category,
    };
  }
} 