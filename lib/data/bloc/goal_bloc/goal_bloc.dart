import 'package:bloc/bloc.dart';
import 'package:book_journal/data/bloc/goal_bloc/goal_event.dart';
import 'package:book_journal/data/bloc/goal_bloc/goal_state.dart';

// Hedef Bloc
class GoalBloc extends Bloc<GoalEvent, GoalState> {
  // Başlangıç durumu
  GoalBloc() : super(GoalInitial()) {
    on<AddGoal>((event, emit) async {
      // Hedef ekleniyor, loading durumu başlatılıyor
      emit(GoalLoading());

      try {
        // Burada hedefi kaydedebiliriz (veritabanı işlemleri vs.)
        // Başlangıçta tamamlanan kitap sayısı sıfır olacak
        emit(GoalLoaded(
          targetBooks: event.targetBooks,
          completedBooks: 0, // Başlangıçta tamamlanan kitap sayısı sıfır
        ));
      } catch (e) {
        emit(GoalError("Bir hata oluştu."));
      }
    });

    on<IncrementGoalProgress>((event, emit) {
      if (state is GoalLoaded) {
        final currentState = state as GoalLoaded;
        final updatedProgress = currentState.completedBooks + 1;

        emit(GoalProgressUpdated(completedBooks: updatedProgress));
      }
    });

    on<ToggleGoalProgress>((event, emit) {
      if (state is GoalLoaded) {
        final currentState = state as GoalLoaded;
        final updatedProgress = currentState.completedBooks + (event.isMonthly ? 1 : 0);

        emit(GoalProgressUpdated(completedBooks: updatedProgress));
      }
    });
  }

  @override
  Stream<GoalState> mapEventToState(GoalEvent event) async* {
    // Bu kısmı artık kullanmıyoruz çünkü on<AddGoal> zaten eventi işliyor
  }
}
