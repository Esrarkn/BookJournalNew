/*import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:book_journal/core/theme.dart/appPalette.dart';
import 'package:book_journal/data/bloc/book_bloc/book_bloc.dart';
import 'package:book_journal/data/bloc/book_bloc/book_event.dart';
import 'package:book_journal/data/bloc/book_bloc/book_state.dart';
import 'package:book_journal/ui/models/book_model.dart';
import 'package:book_journal/ui/screens/widgets/categorySelector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

class BookFormPage extends StatefulWidget {
  final Book? book;
  const BookFormPage({this.book});

  @override
  State<BookFormPage> createState() => _BookFormPageState();
}

class _BookFormPageState extends State<BookFormPage> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _summaryController = TextEditingController();
  final _feelingsController = TextEditingController();
  final _quotesController = TextEditingController();
  final _searchController = TextEditingController();

  String? _bookImage;
  bool _showSuggestions = false;
  ReadingStatus _status = ReadingStatus.okunuyor;
  DateTime? _startDate;
  DateTime? _endDate;
  List<String> _categories = [];
  String? _selectedEmoji;

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
      _bookImage = book.imageUrl;
      _status = book.status;
      _startDate = book.startDate;
      _endDate = book.endDate;
      _categories=_categories;
    }
  }

  void _selectBook(Book book) {
    setState(() {
      _searchController.clear();
      _titleController.text = book.title;
      _authorController.text = book.author;
      _bookImage = book.imageUrl.isNotEmpty ? book.imageUrl : null;
      _showSuggestions = false;
    });
  }

  void _saveBook() async {
    // Başlangıç ve bitiş tarihlerini kontrol et
    if (_startDate != null &&
        _endDate != null &&
        _startDate!.isAfter(_endDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Bitiş tarihi başlangıç tarihinden önce olamaz!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_titleController.text.isEmpty || _authorController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Kitap adı ve yazar boş olamaz!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    Future<void> _showCompletionDialog() async {
      List<String> emojis = ['😍', '🙂', '😐', '😢', '😡'];

      await AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.topSlide,
        title: 'Kitabı Tamamladın!',
        desc: 'Kitabı nasıl değerlendirirsin?',
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Kitabı nasıl değerlendirirsin?",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 12,
              children:
                  emojis
                      .map(
                        (emoji) => GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedEmoji = emoji;
                            });
                            Navigator.of(context).pop();
                          },
                          child: Text(emoji, style: TextStyle(fontSize: 30)),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
        btnCancelOnPress: () {
          _selectedEmoji = null;
        },
        btnCancelText: "Vazgeç",
        btnCancelColor: AppPallete.gradient2,
        dismissOnTouchOutside: false,
        dialogBackgroundColor: AppPallete.backgroundColor,
        buttonsTextStyle: TextStyle(color: AppPallete.gradient3),
      ).show();
    }

    // Eğer bitiş tarihi var ve emoji seçilmemişse, emoji seçimi yap
    if (_endDate != null && _selectedEmoji == null) {
      await _showCompletionDialog();
      if (_selectedEmoji == null) {
        // Kullanıcı dialogu kapatıp seçim yapmadan dönerse kaydetmeyi durdur
        return;
      }
    }

    // Bitiş tarihi kontrolü ve status güncellemesi
    if (_endDate != null) {
      _status = ReadingStatus.okundu;
    } else {
      _status = ReadingStatus.okunuyor;
    }

    final book = Book(
      id: widget.book?.id ?? Uuid().v4(),
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      summary: _summaryController.text.trim(),
      feelings: _feelingsController.text.trim(),
      quotes: _quotesController.text.trim(),
      imageUrl: _bookImage ?? '',
      imagePath: '',
      description:
          _selectedEmoji ??
          '', // Burada emoji'yi description'a ekliyoruz (istersen ayrı alan yaparız)
      status: _status,
      startDate: _startDate,
      endDate: _endDate, 
      categories: _categories.first,
    );

    context.read<BookBloc>().add(ClearSearchResultsEvent());
    widget.book == null
        ? context.read<BookBloc>().add(AddBook(book))
        : context.read<BookBloc>().add(UpdateBook(book));
  }

  Future<void> _selectDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          isStart
              ? (_startDate ?? DateTime.now())
              : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => isStart ? _startDate = picked : _endDate = picked);
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    ),
  );
Widget _buildSearchSuggestions(BookState state) {
  if (state is BookLoading) return Center(child: CircularProgressIndicator());
  
  if (state is BookLoaded) {
    if (state.filteredBooks.isEmpty) return Text("Sonuç bulunamadı.");
    
    return SizedBox(
      height: 200,
      child: ListView.builder(
        itemCount: state.filteredBooks.length,
        itemBuilder: (context, index) {
          final book = state.filteredBooks[index];
          
          return ListTile(
            leading: book.imageUrl.isNotEmpty
                ? Image.network(
                    book.imageUrl,
                    width: 50,
                    height: 75,
                    fit: BoxFit.cover,
                  )
                : Icon(Icons.book, size: 50),
            title: Text(book.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(book.author), // Yazar adı
                SizedBox(height: 4), // Biraz boşluk
                // Kitap kategorileri
              ],
            ),
            onTap: () => _selectBook(book),
          );
        },
      ),
    );
  }
  
 if (state is BookError) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text("Hata: ${state.message ?? "Kitaplar yüklenirken hata oluştu"}"),
      backgroundColor: Colors.red,
    ),
  );
}

  
  return SizedBox.shrink();
}
  Widget _buildCategorySelector() {
    return CategorySelector(
      existingCategories: _categories, // Kategorileri al
    );
  }
  @override
  Widget build(BuildContext context) {
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
        ),
      );
      Navigator.pop(
        context,
        state is BookUpdatedSuccess ? state.book : true,
      );
    } else if (state is BookError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Hata: ${state.message ?? "Kitaplar yüklenirken hata oluştu"}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  },
child: Scaffold(
        appBar: AppBar(title: Text("Kitap Günlüğü")),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8,
                ),
                child: TextFormField(
                  controller: _searchController,
                  onChanged: (value) {
                    context.read<BookBloc>().add(SearchBooksFromGoogle(value));
                    setState(() => _showSuggestions = true);
                  },
                  style: TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Kitap ara...',
                    hintStyle: TextStyle(color: AppPallete.gradient1),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 20,
                      color: AppPallete.gradient1,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.clear,
                        size: 20,
                        color: AppPallete.gradient1,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        context.read<BookBloc>().add(ClearSearchResultsEvent());
                        setState(() => _showSuggestions = false);
                      },
                    ),
                    filled: true,
                    isDense: true,
                    fillColor: AppPallete.backgroundColor,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              if (_showSuggestions)
                BlocBuilder<BookBloc, BookState>(
                  builder: (_, state) => _buildSearchSuggestions(state),
                ),
              SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child:
                        _bookImage != null && _bookImage!.isNotEmpty
                            ? Image.network(
                              _bookImage!,
                              width: 100,
                              height: 150,
                              fit: BoxFit.cover,
                            )
                            : Image.asset(
                              'assets/images/book.png',
                              width: 100,
                              height: 150,
                            ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _titleController.text.isNotEmpty
                              ? _titleController.text
                              : "Kitap Adı",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppPallete.gradient2,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          _authorController.text.isNotEmpty
                              ? _authorController.text
                              : "Yazar",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppPallete.gradient2,
                          ),
                        ),
                        SizedBox(height: 10),
                         _buildCategorySelector(),
                        
                        Row(
                          children: [
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () => _selectDate(true),
                                icon: Icon(
                                  Icons.calendar_today,
                                  color: AppPallete.gradient1,
                                ),
                                label: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    _startDate != null
                                        ? "Başlangıç: ${_startDate!.day}.${_startDate!.month}.${_startDate!.year}"
                                        : "Başlangıç Tarihi",
                                    style: TextStyle(
                                      color: AppPallete.gradient1,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () => _selectDate(false),
                                icon: Icon(
                                  Icons.calendar_today,
                                  color: AppPallete.gradient1,
                                ),
                                label: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    _endDate != null
                                        ? "Bitiş: ${_endDate!.day}.${_endDate!.month}.${_endDate!.year}"
                                        : "Bitiş Tarihi",
                                    style: TextStyle(
                                      color: AppPallete.gradient1,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              _buildTextField(
                _summaryController,
                "Kitabın Ana Konusu",
                maxLines: 3,
              ),
              _buildTextField(
                _feelingsController,
                "Kitap Sana Ne Hissettirdi?",
                maxLines: 3,
              ),
              _buildTextField(
                _quotesController,
                "Favori Alıntıların",
                maxLines: 3,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveBook,
                child: Text(widget.book == null ? "Kaydet" : "Güncelle"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/