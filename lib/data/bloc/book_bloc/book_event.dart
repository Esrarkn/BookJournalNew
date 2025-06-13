import 'package:book_journal/ui/models/book_model.dart';
import 'package:equatable/equatable.dart';

abstract class BookEvent extends Equatable {
  const BookEvent();
  @override
  List<Object> get props => [];
}

class LoadBooks extends BookEvent {}

class FetchBooks extends BookEvent {}

class AddBook extends BookEvent {
  final Book book;
  const AddBook(this.book);
  @override
  List<Object> get props => [book];
}

class DeleteBook extends BookEvent {
  final Book book;
  const DeleteBook(this.book);
  @override
  List<Object> get props => [book];
}

class UpdateBook extends BookEvent {
  final Book book;
  const UpdateBook(this.book);
  @override
  List<Object> get props => [book];
}

class SearchBooksFromGoogle extends BookEvent {
  final String query;
  const SearchBooksFromGoogle(this.query);
  @override
  List<Object> get props => [query];
}

class ClearSearchResultsEvent extends BookEvent {}

class FilterBooks extends BookEvent {
  final ReadingStatus status;  // enum tipinde olması gerekiyor
  const FilterBooks({required this.status});
  
  @override
  List<Object> get props => [status];
}
class ReadingStats extends BookEvent{}
