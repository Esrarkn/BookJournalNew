import 'package:book_journal/ui/models/book_model.dart';
import 'package:equatable/equatable.dart';

abstract class BookState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BookInitial extends BookState {}

class BookLoading extends BookState {}

class BookLoaded extends BookState {
  final List<Book> books;
  final List<Book> filteredBooks;
  final String filterStatus;

  BookLoaded({
    required this.books,
    required this.filteredBooks,
    required this.filterStatus,
  });

  @override
  List<Object?> get props => [books, filteredBooks, filterStatus];
}

class BookAddedSuccess extends BookState {}

class BookError extends BookState {
  final String message;

  BookError({required this.message});

  @override
  List<Object?> get props => [message];
}

class BookUpdatedSuccess extends BookState {
  final Book book;

  BookUpdatedSuccess({required this.book});

  @override
  List<Object?> get props => [book];
}

class BookDeletedSuccess extends BookState {}

class BookSearchSuccess extends BookState {
  final List<Book> searchResults;

  BookSearchSuccess({required this.searchResults});

  @override
  List<Object?> get props => [searchResults];
}
class ReadingStatsLoaded extends BookState {
  final Map<String, int> categoryCounts;

  ReadingStatsLoaded(this.categoryCounts);

  @override
  List<Object?> get props => [categoryCounts];
}