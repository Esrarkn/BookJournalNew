import 'package:book_journal/data/bloc/book_bloc/book_event.dart';
import 'package:book_journal/data/bloc/book_bloc/book_state.dart';
import 'package:book_journal/data/repository/bookRepository.dart';
import 'package:book_journal/data/services/google_books_service.dart';
import 'package:book_journal/ui/models/book_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookBloc extends Bloc<BookEvent, BookState> {
  final BookRepository bookRepository;
  final GoogleBooksService _googleBooksService = GoogleBooksService();

  BookBloc({required this.bookRepository}) : super(BookInitial()) {
    on<LoadBooks>(_onLoadBooks);
    on<AddBook>(_onAddBook);
    on<SearchBooksFromGoogle>(_onSearchBooksFromGoogle);
    on<ClearSearchResultsEvent>(_onClearSearchResults);
    on<DeleteBook>(_onDeleteBook);
    on<UpdateBook>(_onUpdateBook);
    on<FetchBooks>(_onFetchBooks);
    on<FilterBooks>(_onFilterBooks);
     on<ReadingStats>(_onLoadReadingStats);
  }

  // Kitapları yüklerken filtreleme işlemi de yapılır
  void _onLoadBooks(LoadBooks event, Emitter<BookState> emit) async {
    emit(BookLoading());
    try {
      final books = await bookRepository.getBooks();
      final filteredBooks = _filterBooks(books, ReadingStatus.okunuyor);  // Başlangıçta okunuyor kitaplar
      emit(BookLoaded(books: books, filteredBooks: filteredBooks, filterStatus: ReadingStatus.okunuyor.toString()));
    } catch (e) {
      emit(BookError(message: "Kitaplar yüklenirken hata oluştu"));
    }
  }

  // Kitapları durumlarına göre filtreler
  void _onFilterBooks(FilterBooks event, Emitter<BookState> emit) {
    if (state is BookLoaded) {
      final currentState = state as BookLoaded;
      final filteredBooks = _filterBooks(currentState.books, event.status);
      emit(BookLoaded(
        books: currentState.books,
        filteredBooks: filteredBooks,
        filterStatus: event.status.name,
      ));
    }
  }
List<Book> _filterBooks(List<Book> books, ReadingStatus status) {
  switch (status) {
    case ReadingStatus.okunuyor:
      return books.where((book) => book.status == ReadingStatus.okunuyor).toList();
    case ReadingStatus.okundu:
      return books.where((book) => book.status == ReadingStatus.okundu).toList();
    case ReadingStatus.tumKitaplar:
      return books;
    // Yeni durumlar eklenirse buraya eklenmeli
  }
}


  void _onAddBook(AddBook event, Emitter<BookState> emit) async {
    try {
      await bookRepository.addBook(event.book);
      emit(BookAddedSuccess());
      add(FetchBooks());
    } catch (e) {
      emit(BookError(message: "Kitap eklenirken hata oluştu"));
    }
  }

  Future<void> _onSearchBooksFromGoogle(SearchBooksFromGoogle event, Emitter<BookState> emit) async {
    emit(BookLoading());
    try {
      final books = await _googleBooksService.fetchBooksFromGoogle(event.query);
      final filteredBooks = _filterBooks(books, ReadingStatus.okunuyor);  // Başlangıçta okunuyor kitaplar
      emit(BookLoaded(books: books, filteredBooks: filteredBooks, filterStatus: ReadingStatus.okunuyor.toString()));
    } catch (e) {
      emit(BookError(message: "Google kitapları alınamadı: $e"));
    }
  }

  void _onClearSearchResults(ClearSearchResultsEvent event, Emitter<BookState> emit) {
    emit(BookLoaded(books: [], filteredBooks: [], filterStatus: ReadingStatus.okunuyor.toString()));
  }

  void _onDeleteBook(DeleteBook event, Emitter<BookState> emit) async {
    try {
      await bookRepository.deleteBook(event.book);
      emit(BookDeletedSuccess());
      add(FetchBooks());
    } catch (e) {
      emit(BookError(message: "Kitap silinirken hata oluştu"));
    }
  }

  void _onUpdateBook(UpdateBook event, Emitter<BookState> emit) async {
    try {
      await bookRepository.updateBook(event.book);
      emit(BookUpdatedSuccess(book: event.book));
      add(FetchBooks());
    } catch (e) {
      emit(BookError(message: "Kitap güncellenirken hata oluştu"));
    }
  }

  void _onFetchBooks(FetchBooks event, Emitter<BookState> emit) async {
    try {
      final books = await bookRepository.getBooks();
      final filteredBooks = _filterBooks(books, ReadingStatus.okunuyor);  // Başlangıçta okunuyor kitaplar
      emit(BookLoaded(books: books, filteredBooks: filteredBooks, filterStatus: ReadingStatus.okunuyor.toString()));
    } catch (e) {
      emit(BookError(message: "Kitaplar yüklenirken hata oluştu"));
    }
  }
void _onLoadReadingStats(ReadingStats event, Emitter<BookState> emit) async {
  try {
    final books = await bookRepository.getBooks();
    final readBooks = books.where((book) => book.status == ReadingStatus.okundu).toList();
    final categoryCounts = <String, int>{};

    for (var book in readBooks) {
      final category = (book.category?.trim().toLowerCase() ?? '').isNotEmpty
    ? book.category!.trim().toLowerCase()
    : 'belirsiz';

      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
      print("Kategori sayıları: $categoryCounts");

    }

    emit(ReadingStatsLoaded(categoryCounts));
  } catch (e) {
    emit(BookError(message: "İstatistikler yüklenirken hata oluştu: $e"));
  }
}


}
