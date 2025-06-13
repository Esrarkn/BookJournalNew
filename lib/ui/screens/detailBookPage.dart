import 'package:book_journal/core/theme.dart/appPalette.dart';
import 'package:book_journal/ui/screens/bookFormPage.dart';
import 'package:flutter/material.dart';
import 'package:book_journal/ui/models/book_model.dart';

class BookDetailPage extends StatefulWidget {
  final Book book;

  const BookDetailPage({Key? key, required this.book}) : super(key: key);

  @override
  _BookDetailPageState createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  late Book _book;

  @override
  void initState() {
    super.initState();
    _book = widget.book;
  }

  String? formatDate(DateTime? date) {
    if (date == null) return null;
    return "${date.day}.${date.month}.${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppPallete.gradient1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Icon(Icons.edit, size: 30, color: AppPallete.gradient3),
        onPressed: _editBook,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBookHeader(),
            const SizedBox(height: 24),
            _buildDetailSection("Kitabın Ana Konusu", _book.summary),
            _buildDetailSection("Kitap Sana Ne Hissettirdi?", _book.feelings),
            _buildDetailSection("Favori Alıntılar", _book.quotes),
          ],
        ),
      ),
    );
  }

  Widget _buildBookHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBookImage(),
        const SizedBox(width: 16),
        Expanded(child: _buildBookInfo()),
      ],
    );
  }

  Widget _buildBookImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: _book.imageUrl.isNotEmpty
          ? Image.network(
              _book.imageUrl,
              width: 120,
              height: 180,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                'assets/images/book.png',
                width: 120,
                height: 180,
                fit: BoxFit.cover,
              ),
            )
          : Image.asset(
              'assets/images/book.png',
              width: 120,
              height: 180,
              fit: BoxFit.cover,
            ),
    );
  }

  Widget _buildBookInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kitap Adı
        Text(
          _book.title.isNotEmpty ? _book.title : "Başlıksız Kitap",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppPallete.gradient3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),

        // Yazar
        Row(
          children: [
            Text(
              _book.author.isNotEmpty ? _book.author : "Bilinmeyen Yazar",
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey[700],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(",", style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[700],
                ),),
            ),
            Text(
              _book.category!.isNotEmpty ? _book.category! : "Bilinmeyen Kategori",
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey[700],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        const SizedBox(height: 12),
  const SizedBox(height: 12),
        // Başlangıç ve Bitiş Tarihleri
        if (_book.startDate != null || _book.endDate != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_book.startDate != null)
                _buildDateRow('Başlangıç:', formatDate(_book.startDate)!),
              if (_book.endDate != null)
                _buildDateRow('Bitiş:', formatDate(_book.endDate)!),
            ],
          ),
        const SizedBox(height: 12),

        // Açıklama (okuma durumu gibi)
        Text(
          _book.description.isNotEmpty
              ? _book.description
              : "Henüz tamamlanmadı.",
          style: TextStyle(fontSize: 13, color: Colors.grey[800]),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildDateRow(String label, String date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text(
            "$label $date",
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            content.isNotEmpty ? content : "Henüz eklenmedi.",
            style: const TextStyle(fontSize: 15),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Future<void> _editBook() async {
    final updatedBook = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BookFormPage(book: _book)),
    );

    if (updatedBook != null && updatedBook is Book) {
      setState(() {
        _book = updatedBook;
      });
    }
  }
}
