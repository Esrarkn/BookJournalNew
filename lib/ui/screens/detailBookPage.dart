import 'package:book_journal/ui/widgets/appBackground.dart';
import 'package:flutter/material.dart';
import 'package:book_journal/ui/models/book.dart';
import 'package:book_journal/ui/screens/bookFormPage.dart';
import 'package:book_journal/core/theme.dart/appPalette.dart';
import 'package:book_journal/ui/widgets/appHeader.dart';

class BookDetailPage extends StatefulWidget {
  final Book book;

  const BookDetailPage({Key? key, required this.book}) : super(key: key);

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  late Book _book;

  @override
  void initState() {
    super.initState();
    _book = widget.book;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: AppBackground(
        child: Column(
          children: [
            AppHeader(
              icon: Icons.arrow_back_ios,
              title: 'Kitap Detayı',
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBookCover(),
                    const SizedBox(height: 32),
                    _buildBookInfo(),
                    const SizedBox(height: 24),
                    _buildFeelingsSection(),
                    const SizedBox(height: 24),
                    _buildQuoteSection(),
                    const SizedBox(height: 100), // FAB için alan
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildBookCover() {
    return Center(
      child: Hero(
        tag: 'book-${_book.id}',
        child: Container(
          width: 160,
          height: 240,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _book.imageUrl.isNotEmpty
                ? Image.network(
                    _book.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholderCover();
                    },
                  )
                : _buildPlaceholderCover(),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderCover() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppPalette.primary,
            AppPalette.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.menu_book,
          size: 80,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBookInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _book.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _book.author,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          
          // Kategori ve durum
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildInfoChip(
                _book.category ?? 'Genel',
                Icons.category,
                Colors.blue.shade100,
                Colors.blue.shade700,
              ),
              _buildInfoChip(
                _book.status == ReadingStatus.okundu ? 'Okundu' : 'Okunuyor',
                _book.status == ReadingStatus.okundu ? Icons.check_circle : Icons.schedule,
                _book.status == ReadingStatus.okundu 
                    ? Colors.green.shade100 
                    : Colors.orange.shade100,
                _book.status == ReadingStatus.okundu 
                    ? Colors.green.shade700 
                    : Colors.orange.shade700,
              ),
            ],
          ),
          
          // Rating
          if (_book.rating != null && _book.rating! > 0) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: Colors.amber.shade700, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Puanım: ${_book.rating!}/5',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.amber.shade800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        Icons.star,
                        size: 16,
                        color: index < _book.rating! 
                            ? Colors.amber.shade600 
                            : Colors.grey.shade300,
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
          
          // Dates
          if (_book.startDate != null || _book.endDate != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                if (_book.startDate != null) ...[
                  Icon(Icons.play_arrow, color: Colors.grey.shade600, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    "${_book.startDate!.day}.${_book.startDate!.month}.${_book.startDate!.year}",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
                if (_book.startDate != null && _book.endDate != null) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.arrow_forward, color: Colors.grey.shade400, size: 12),
                  const SizedBox(width: 16),
                ],
                if (_book.endDate != null) ...[
                  Icon(Icons.check, color: Colors.grey.shade600, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    "${_book.endDate!.day}.${_book.endDate!.month}.${_book.endDate!.year}",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon, Color backgroundColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeelingsSection() {
    if (_book.feelings.isEmpty) return const SizedBox.shrink();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.pink.shade50,
            Colors.purple.shade50,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.pink.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.pink.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.favorite,
                  color: Colors.pink.shade600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Hislerim',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.pink.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _book.feelings,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade800,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteSection() {
    if (_book.quotes.isEmpty) return const SizedBox.shrink();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.shade50,
            Colors.orange.shade50,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.format_quote,
                  color: Colors.amber.shade700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Favori Alıntı',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.amber.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Text(
              '"${_book.quotes}"',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade800,
                fontStyle: FontStyle.italic,
                height: 1.6,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppPalette.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: _editBook,
        backgroundColor: AppPalette.primary,
        elevation: 0,
        child: const Icon(Icons.edit, color: Colors.white, size: 22),
      ),
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