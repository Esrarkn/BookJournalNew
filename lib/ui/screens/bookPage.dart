import 'package:book_journal/core/theme.dart/appPalette.dart';
import 'package:book_journal/ui/screens/bookFormPage.dart';
import 'package:book_journal/ui/widgets/appBackground.dart';
import 'package:book_journal/ui/widgets/bookCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:book_journal/data/bloc/book_bloc/book_bloc.dart';
import 'package:book_journal/data/bloc/book_bloc/book_event.dart';
import 'package:book_journal/data/bloc/book_bloc/book_state.dart';
import 'package:book_journal/ui/models/book.dart';
import 'package:book_journal/ui/screens/timerPage.dart';
import 'package:iconsax/iconsax.dart';

class BookPage extends StatefulWidget {
  final String userId;

  const BookPage({Key? key, required this.userId}) : super(key: key);
  
  @override
  _BookPageState createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> with TickerProviderStateMixin {
  ReadingStatus _filterStatus = ReadingStatus.tumKitaplar;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    
    context.read<BookBloc>().add(LoadBooks());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<BookBloc>().add(FetchBooks());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _updateFilter(ReadingStatus newStatus) {
    setState(() {
      _filterStatus = newStatus;
    });
    context.read<BookBloc>().add(FilterBooks(status: newStatus));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      floatingActionButton: Container(
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
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookFormPage(),
              ),
            ).then((_) {
              context.read<BookBloc>().add(FetchBooks());
            });
          },
          backgroundColor: AppPalette.primary,
          elevation: 0,
          child: const Icon(Iconsax.add, color: Colors.white, size: 28),
        ),
      ),
      body: AppBackground(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildModernHeader(isDark),
              _buildCurrentlyReadingSection(isDark),
              _buildStatsSection(isDark),
              Expanded(child: _buildBooksList(isDark)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppPalette.primary,
                        AppPalette.primary.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Iconsax.book_1, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _isSearching
                      ? _buildSearchField()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'SoulBook',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Ruhuna dokunan kitapların yolculuğu',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        if (_isSearching) {
                          _searchController.clear();
                          context.read<BookBloc>().add(FilterBooks(status: _filterStatus));
                        }
                        _isSearching = !_isSearching;
                      });
                    },
                    icon: Icon(
                      _isSearching ? Iconsax.close_circle : Iconsax.search_normal,
                      color: Colors.grey.shade700,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        style: const TextStyle(color: Colors.black87, fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Kitap veya yazar ara...',
          hintStyle: TextStyle(color: Colors.grey.shade500),
          border: InputBorder.none,
          prefixIcon: Icon(Iconsax.search_normal, color: Colors.grey.shade500, size: 20),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: (query) {
          context.read<BookBloc>().add(SearchBooks(query: query));
        },
      ),
    );
  }

  Widget _buildCurrentlyReadingSection(bool isDark) {
    return BlocBuilder<BookBloc, BookState>(
      builder: (context, state) {
        List<Book> readingBooks = [];
        if (state is BookLoaded) {
          readingBooks = state.books
              .where((b) => b.status == ReadingStatus.okunuyor)
              .toList();
        }

        if (readingBooks.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Şu An Okuyorum',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: readingBooks.length,
                  itemBuilder: (context, index) {
                    final book = readingBooks[index];
                    return Container(
                      width: 300,
                      margin: EdgeInsets.only(
                        right: index == readingBooks.length - 1 ? 0 : 16,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TimerPage(book: book),
                              ),
                            ).then((_) {
                              context.read<BookBloc>().add(FetchBooks());
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: 
            [AppPalette.primary.withOpacity(0.2), AppPalette.secondary.withOpacity(0.2)
        
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: book.imageUrl.isNotEmpty
                                        ? Image.network(
                                            book.imageUrl,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            color: AppPalette.primary.withOpacity(0.1),
                                            child: Icon(
                                              Iconsax.book_1,
                                              color: AppPalette.primary,
                                              size: 24,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppPalette.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          "Okuma zamanı",
                                          style: TextStyle(
                                            color: AppPalette.primary,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        book.title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                          height: 1.2,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        book.author,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppPalette.primary.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Iconsax.play_circle,
                                    color: AppPalette.primary,
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsSection(bool isDark) {
    return BlocBuilder<BookBloc, BookState>(
      builder: (context, state) {
        int totalBooks = 0;
        int readingBooks = 0;
        int completedBooks = 0;

        if (state is BookLoaded) {
          totalBooks = state.books.length;
          readingBooks = state.books.where((b) => b.status == ReadingStatus.okunuyor).length;
          completedBooks = state.books.where((b) => b.status == ReadingStatus.okundu).length;
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildStatItem(
                "$totalBooks",
                "Toplam",
                AppPalette.primary,
                _filterStatus == ReadingStatus.tumKitaplar,
                () => _updateFilter(ReadingStatus.tumKitaplar),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.grey.withOpacity(0.2),
                margin: const EdgeInsets.symmetric(horizontal: 24),
              ),
              _buildStatItem(
                "$readingBooks",
                "Okunuyor",
                Colors.orange,
                _filterStatus == ReadingStatus.okunuyor,
                () => _updateFilter(ReadingStatus.okunuyor),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.grey.withOpacity(0.2),
                margin: const EdgeInsets.symmetric(horizontal: 24),
              ),
              _buildStatItem(
                "$completedBooks",
                "Tamamlandı",
                Colors.green,
                _filterStatus == ReadingStatus.okundu,
                () => _updateFilter(ReadingStatus.okundu),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    String number,
    String label,
    Color color,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          ),
          child: Column(
            children: [
              Text(
                number,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? color : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? color : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBooksList(bool isDark) {
    return BlocBuilder<BookBloc, BookState>(
      builder: (context, state) {
        if (state is BookLoading) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppPalette.primary),
            ),
          );
        } else if (state is BookLoaded) {
          final books = state.filteredBooks;
          if (books.isEmpty) return _buildEmptyState();
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
            itemCount: books.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: BookCard(book: books[index]),
            ),
          );
        } else if (state is BookError) {
          return _buildErrorState(state.message);
        }
        return _buildEmptyState();
      },
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppPalette.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.book_1,
              size: 60,
              color: AppPalette.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _isSearching ? "Aradığınız kitap bulunamadı" : "Kitap koleksiyonunuz boş",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _isSearching 
              ? "Farklı anahtar kelimeler deneyin" 
              : "İlk kitabınızı ekleyerek başlayın",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          if (!_isSearching) ...[
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookFormPage(),
                  ),
                ).then((_) {
                  context.read<BookBloc>().add(FetchBooks());
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPalette.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'İlk Kitabı Ekle',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.warning_2,
              size: 60,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Bir hata oluştu",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              context.read<BookBloc>().add(FetchBooks());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPalette.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Yeniden Dene',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}