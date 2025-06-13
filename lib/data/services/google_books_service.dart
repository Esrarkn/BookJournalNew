import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:book_journal/ui/models/book_model.dart';

class GoogleBooksService {
  final String baseUrl = 'https://www.googleapis.com/books/v1/volumes';

  Future<List<Book>> fetchBooksFromGoogle(String query) async {
    final response = await http.get(Uri.parse('$baseUrl?q=$query'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List items = data['items'] ?? [];

      return items.map<Book>((item) => Book.fromGoogleApi(item)).toList();
    } else {
      throw Exception('Google Books API isteği başarısız oldu. Hata kodu: ${response.statusCode}');
    }
  }
}
