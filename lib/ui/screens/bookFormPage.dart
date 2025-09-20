import 'dart:convert';
import 'dart:io';
import 'package:book_journal/core/theme.dart/appPalette.dart';
import 'package:book_journal/data/bloc/book_bloc/book_bloc.dart';
import 'package:book_journal/data/bloc/book_bloc/book_event.dart';
import 'package:book_journal/data/bloc/book_bloc/book_state.dart';
import 'package:book_journal/ui/models/book.dart';
import 'package:book_journal/ui/widgets/appBackground.dart';
import 'package:book_journal/ui/widgets/appHeader.dart';
import 'package:book_journal/ui/widgets/saveButton.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class BookFormPage extends StatefulWidget {
  final Book? book;
  const BookFormPage({this.book, Key? key}) : super(key: key);

  @override
  State<BookFormPage> createState() => _BookFormPageState();
}

class _BookFormPageState extends State<BookFormPage> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _summaryController = TextEditingController();
  final _feelingsController = TextEditingController();
  final _quotesController = TextEditingController();

  String? _bookImageUrl;
  bool _showSuggestions = false;
  bool _suggestionSelected = false;
  DateTime? _startDate;
  DateTime? _endDate;
  int _rating = 0;
  String _selectedCategory = 'Genel';

  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> _suggestions = [];

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Genel', 'icon': Icons.book, 'color': Colors.grey.shade600},
    {'name': 'Roman', 'icon': Icons.auto_stories, 'color': Colors.blue},
    {'name': 'Bilim Kurgu', 'icon': Icons.rocket_launch, 'color': Colors.purple},
    {'name': 'Fantastik', 'icon': Icons.auto_fix_high, 'color': Colors.pink},
    {'name': 'Polisiye', 'icon': Icons.search, 'color': Colors.orange},
    {'name': 'Biyografi', 'icon': Icons.person, 'color': Colors.green},
    {'name': 'Tarih', 'icon': Icons.history_edu, 'color': Colors.brown},
    {'name': 'Felsefe', 'icon': Icons.psychology, 'color': Colors.indigo},
    {'name': 'Bilim', 'icon': Icons.science, 'color': Colors.teal},
    {'name': 'Sanat', 'icon': Icons.palette, 'color': Colors.red},
    {'name': 'Kişisel Gelişim', 'icon': Icons.trending_up, 'color': Colors.amber.shade700},
    {'name': 'Çocuk', 'icon': Icons.child_care, 'color': Colors.cyan},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.book != null) {
      final book = widget.book!;
      _titleController.text = book.title;
      _authorController.text = book.author;
      _summaryController.text = book.summary;
      _feelingsController.text = book.feelings;
      _quotesController.text = book.quotes;
      _bookImageUrl = book.imageUrl.isNotEmpty ? book.imageUrl : null;
      _startDate = book.startDate;
      _endDate = book.endDate;
      _rating = book.rating ?? 0;
      _selectedCategory = (book.category != null && book.category!.isNotEmpty) ? book.category! : 'Genel';
    }
    _titleController.addListener(_titleListener);
  }

  @override
  void dispose() {
    _titleController.removeListener(_titleListener);
    _titleController.dispose();
    _authorController.dispose();
    _summaryController.dispose();
    _feelingsController.dispose();
    _quotesController.dispose();
    super.dispose();
  }

  Future<void> _fetchBookSuggestions(String query) async {
    final url = Uri.parse('https://www.googleapis.com/books/v1/volumes?q=$query&maxResults=10');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List items = data['items'] ?? [];
        setState(() {
          _suggestions = items.map<Map<String, dynamic>>((item) {
            final volumeInfo = item['volumeInfo'] ?? {};
            return {
              'title': volumeInfo['title'] ?? '',
              'authors': volumeInfo['authors'] ?? [],
              'imageLinks': volumeInfo['imageLinks'] ?? {},
              'categories': volumeInfo['categories'] ?? [],
              'description': volumeInfo['description'] ?? '',
            };
          }).toList();
          _showSuggestions = _suggestions.isNotEmpty;
        });
      } else {
        setState(() {
          _suggestions = [];
          _showSuggestions = false;
        });
      }
    } catch (e) {
      print('API Error: $e');
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
    }
  }

  String _mapGoogleCategoryToLocal(List<dynamic> googleCategories) {
    if (googleCategories.isEmpty) return 'Genel';
    final firstCategory = googleCategories.first.toString().toLowerCase();
    final categoryMap = {
      'fiction': 'Roman',
      'science fiction': 'Bilim Kurgu',
      'fantasy': 'Fantastik',
      'mystery': 'Polisiye',
      'detective': 'Polisiye',
      'thriller': 'Polisiye',
      'biography': 'Biyografi',
      'autobiography': 'Biyografi',
      'history': 'Tarih',
      'philosophy': 'Felsefe',
      'religion': 'Felsefe',
      'psychology': 'Felsefe',
      'science': 'Bilim',
      'art': 'Sanat',
      'poetry': 'Sanat',
      'self-help': 'Kişisel Gelişim',
      'business': 'Kişisel Gelişim',
      'health': 'Kişisel Gelişim',
      'fitness': 'Kişisel Gelişim',
      'juvenile': 'Çocuk',
      'young adult': 'Roman',
      'romance': 'Roman',
      'horror': 'Fantastik',
      'cooking': 'Genel',
      'travel': 'Genel',
      'sports': 'Genel',
      'true crime': 'Polisiye',
    };
    for (final entry in categoryMap.entries) {
      if (firstCategory.contains(entry.key)) return entry.value;
    }
    return 'Genel';
  }

  void _titleListener() {
    if (_suggestionSelected) {
      _suggestionSelected = false;
      return;
    }
    final text = _titleController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _showSuggestions = false;
        _suggestions = [];
      });
    } else {
      _fetchBookSuggestions(text);
    }
  }

  Future<void> pickAndUploadImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 80);
    if (pickedFile == null) return;
    File file = File(pickedFile.path);
    String fileName = '${Uuid().v4()}.${file.path.split('.').last}';
    try {
      final ref = FirebaseStorage.instance.ref().child('images/$fileName');
      await ref.putFile(file);
      final downloadURL = await ref.getDownloadURL();
      setState(() {
        _bookImageUrl = downloadURL;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Görsel yüklenirken hata oluştu.")),
      );
    }
  }

  void _selectBookFromSuggestion(Map<String, dynamic> book) {
    final imageUrl = book['imageLinks']?['thumbnail'] ?? '';
    final authors = (book['authors'] as List<dynamic>?)?.join(', ') ?? 'Bilinmeyen yazar';
    final categories = book['categories'] as List<dynamic>? ?? [];
    final suggestedCategory = _mapGoogleCategoryToLocal(categories);

    _titleController.removeListener(_titleListener);
    
    setState(() {
      _titleController.text = book['title'] ?? '';
      _authorController.text = authors;
      _bookImageUrl = imageUrl.isNotEmpty ? imageUrl : null;
      _selectedCategory = suggestedCategory;
      _titleController.selection = TextSelection.fromPosition(
        TextPosition(offset: _titleController.text.length),
      );
      _showSuggestions = false;
      _suggestions = [];
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      _titleController.addListener(_titleListener);
    });

    if (categories.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kategori otomatik olarak "$suggestedCategory" seçildi'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
    FocusScope.of(context).unfocus();
  }

  void _saveBook() {
    if (_titleController.text.isEmpty || _authorController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kitap adı ve yazar boş olamaz!"), backgroundColor: Colors.red),
      );
      return;
    }

    if (_rating > 0 && _endDate == null) {
      _endDate = DateTime.now();
    }

    final book = Book(
      id: widget.book?.id ?? Uuid().v4(),
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      summary: _summaryController.text.trim(),
      feelings: _feelingsController.text.trim(),
      quotes: _quotesController.text.trim(),
      imageUrl: _bookImageUrl ?? '',
      imagePath: '',
      description: '',
      status: (_endDate != null || _rating > 0)
          ? ReadingStatus.okundu
          : ReadingStatus.okunuyor,
      startDate: _startDate,
      endDate: _endDate,
      category: _selectedCategory,
      rating: _rating,
    );

    context.read<BookBloc>().add(ClearSearchResultsEvent());
    if (widget.book == null) {
      context.read<BookBloc>().add(AddBook(book));
    } else {
      context.read<BookBloc>().add(UpdateBook(book));
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Fotoğraf Seç", style: TextStyle(fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.photo_library, color: Colors.blue),
              ),
              title: const Text("Galeriden Seç"),
              onTap: () {
                Navigator.pop(context);
                pickAndUploadImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.camera_alt, color: Colors.green),
              ),
              title: const Text("Fotoğraf Çek"),
              onTap: () {
                Navigator.pop(context);
                pickAndUploadImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Kategori Seç", style: TextStyle(fontWeight: FontWeight.w600)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = _selectedCategory == category['name'];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isSelected ? category['color'].withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: Icon(
                    category['icon'],
                    color: category['color'],
                  ),
                  title: Text(
                    category['name'],
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? category['color'] : Colors.black87,
                    ),
                  ),
                  trailing: isSelected ? Icon(Icons.check_circle, color: category['color']) : null,
                  onTap: () {
                    setState(() {
                      _selectedCategory = category['name'];
                    });
                    Navigator.pop(context);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildBookImage(String? imageUrl, {double width = 140, double height = 200}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppPalette.primary,
            AppPalette.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppPalette.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: imageUrl != null && imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                width: width,
                height: height,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.menu_book, size: 60, color: Colors.white);
                },
              )
            : const Icon(Icons.menu_book, size: 60, color: Colors.white),
      ),
    );
  }

  Widget _buildModernTextField(
    TextEditingController controller, 
    String hint, {
    int maxLines = 1, 
    IconData? icon,
    String? label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(color: Colors.black87, fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              prefixIcon: icon != null 
                  ? Icon(icon, color: Colors.grey.shade600, size: 20) 
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: icon != null ? 12 : 16, 
                vertical: maxLines > 1 ? 16 : 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernSection({
    required String title,
    required IconData icon,
    required Widget child,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    final selectedCategoryData = _categories.firstWhere(
      (cat) => cat['name'] == _selectedCategory,
      orElse: () => _categories[0],
    );

    return GestureDetector(
      onTap: _showCategoryDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(selectedCategoryData['icon'], color: selectedCategoryData['color'], size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedCategory,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStars() {
    return Row(
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () => setState(() => _rating = index + 1),
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(
              Icons.star,
              size: 28,
              color: index < _rating ? Colors.amber.shade600 : Colors.grey.shade300,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _endDate != null
                  ? "${_endDate!.day}.${_endDate!.month}.${_endDate!.year}"
                  : "Bitiş tarihi seç (opsiyonel)",
              style: TextStyle(
                fontSize: 15,
                color: _endDate != null ? Colors.black87 : Colors.grey.shade500,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (pickedDate != null) {
                setState(() => _endDate = pickedDate);
              }
            },
            child: Text("Seç", style: TextStyle(color: AppPalette.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    if (!_showSuggestions || _suggestions.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 200),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _suggestions.length,
          itemBuilder: (context, index) {
            final book = _suggestions[index];
            final imageUrl = book['imageLinks']?['thumbnail'] ?? '';
            final authors = (book['authors'] as List<dynamic>?)?.join(', ') ?? 'Bilinmeyen yazar';

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: SizedBox(
                width: 35,
                height: 50,
                child: imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.book, size: 16),
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.book, size: 16),
                      ),
              ),
              title: Text(
                book['title'] ?? '',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                authors,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => _selectBookFromSuggestion(book),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return BlocListener<BookBloc, BookState>(
      listener: (context, state) {
        if (state is BookAddedSuccess || state is BookUpdatedSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state is BookAddedSuccess
                    ? "Kitap başarıyla eklendi!"
                    : "Kitap başarıyla güncellendi!",
              ),
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context, true);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: AppBackground(
          child: Column(
            children: [
              AppHeader(
                icon: Icons.arrow_back_ios,
                title: widget.book != null ? "Kitap Güncelle" : "Yeni Kitap Ekle",
                onBack: () => Navigator.pop(context),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Kitap resmi
                      Center(
                        child: Stack(
                          children: [
                            buildBookImage(_bookImageUrl, 
                                width: screenWidth * 0.32, 
                                height: screenWidth * 0.45),
                            Positioned(
                              bottom: -4,
                              right: -4,
                              child: GestureDetector(
                                onTap: _showImageSourceDialog,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.edit, color: Colors.grey, size: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Kitap bilgileri
                      _buildModernSection(
                        title: 'Kitap Bilgileri',
                        icon: Icons.menu_book,
                        color: Colors.blue.shade600,
                        child: Column(
                          children: [
                            Column(
                              children: [
                                _buildModernTextField(_titleController, 'Kitap adını yazın...', 
                                    icon: Icons.title, label: 'Kitap Adı'),
                                _buildSearchSuggestions(),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildModernTextField(_authorController, "Yazar adını yazın...", 
                                icon: Icons.person, label: 'Yazar'),
                            const SizedBox(height: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Kategori',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildCategorySelector(),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Duygular
                      _buildModernSection(
                        title: 'Bu kitap sana neler hissettirdi?',
                        icon: Icons.favorite,
                        color: Colors.pink.shade500,
                        child: _buildModernTextField(
                          _feelingsController,
                          'Bu kitabı okurken neler hissettin? Duygularını paylaş...',
                          maxLines: 4,
                        ),
                      ),

                      // Alıntılar
                      _buildModernSection(
                        title: 'Favori alıntın',
                        icon: Icons.format_quote,
                        color: Colors.orange.shade600,
                        child: _buildModernTextField(
                          _quotesController,
                          'Bu kitaptan seni en çok etkileyen alıntı neydi?',
                          maxLines: 3,
                        ),
                      ),

                      // Değerlendirme
                      _buildModernSection(
                        title: 'Değerlendirme',
                        icon: Icons.star,
                        color: Colors.green.shade600,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Puanım',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildRatingStars(),
                            const SizedBox(height: 24),
                            const Text(
                              'Okuma Tarihi',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildDateSelector(),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppPalette.primary.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: SaveButton(
                          text: widget.book == null ? "Kitabı Ekle" : "Güncelle",
                          onPressed: _saveBook,
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}