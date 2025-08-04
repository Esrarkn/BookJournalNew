import 'package:book_journal/core/theme.dart/appPalette.dart';
import 'package:book_journal/data/bloc/goal_bloc/goal_bloc.dart';
import 'package:book_journal/data/bloc/goal_bloc/goal_event.dart';
import 'package:book_journal/data/bloc/goal_bloc/goal_state.dart';
import 'package:book_journal/ui/models/bookGoal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

class BookGoalsPage extends StatefulWidget {
  const BookGoalsPage({super.key});

  @override
  State<BookGoalsPage> createState() => _BookGoalsPageState();
}

class _BookGoalsPageState extends State<BookGoalsPage> {
  final _monthlyController = TextEditingController();
  final _yearlyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late GoalBloc _goalBloc;

  @override
  void initState() {
    super.initState();
    _goalBloc = context.read<GoalBloc>();
    _goalBloc.add(LoadGoal());
  }

  @override
  void dispose() {
    _monthlyController.dispose();
    _yearlyController.dispose();
    super.dispose();
  }

  void _saveGoals(BookGoal currentGoal) {
    if (!_formKey.currentState!.validate()) return;

    final monthlyGoal = int.parse(_monthlyController.text);
    final yearlyGoal = int.parse(_yearlyController.text);

    // İlerlemeleri hedef sınırlarında tut
    int monthlyProgress = currentGoal.monthlyProgress;
    int yearlyProgress = currentGoal.yearlyProgress;

    if (monthlyProgress > monthlyGoal) monthlyProgress = monthlyGoal;
    if (yearlyProgress > yearlyGoal) yearlyProgress = yearlyGoal;

    // Aylık ilerleme yıllıktan fazla olamaz
    if (monthlyProgress > yearlyProgress) yearlyProgress = monthlyProgress;

    final updatedGoal = currentGoal.copyWith(
      monthlyGoal: monthlyGoal,
      yearlyGoal: yearlyGoal,
      monthlyProgress: monthlyProgress,
      yearlyProgress: yearlyProgress,
    );

    _goalBloc.add(UpdateGoal(updatedGoal));
  }

void _updateProgress(bool isMonthly, int index, BookGoal currentGoal) {
  int newProgress = (index < (isMonthly ? currentGoal.monthlyProgress : currentGoal.yearlyProgress))
      ? index
      : index + 1;

  if (isMonthly && newProgress > currentGoal.monthlyGoal) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Aylık ilerleme aylık hedefi aşamaz!')),
    );
    return;
  }
  if (!isMonthly) {
    if (newProgress > currentGoal.yearlyGoal) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yıllık ilerleme yıllık hedefi aşamaz!')),
      );
      return;
    }
    if (newProgress < currentGoal.monthlyProgress) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yıllık ilerleme aylık ilerlemeden küçük olamaz!')),
      );
      return;
    }
  }

  int updatedMonthlyProgress = currentGoal.monthlyProgress;
  int updatedYearlyProgress = currentGoal.yearlyProgress;

  if (isMonthly) {
    updatedMonthlyProgress = newProgress;
    if (updatedYearlyProgress < updatedMonthlyProgress) {
      updatedYearlyProgress = updatedMonthlyProgress;
    }
  } else {
    updatedYearlyProgress = newProgress;
    if (updatedYearlyProgress < updatedMonthlyProgress) {
      updatedMonthlyProgress = updatedYearlyProgress;
    }
  }

  _goalBloc.add(
    UpdateProgressLocal(
      monthlyProgress: updatedMonthlyProgress,
      yearlyProgress: updatedYearlyProgress,
    ),
  );
}


  List<Widget> _buildProgressBoxes(
    BookGoal currentGoal,
    int goal,
    int progress,
    bool isMonthly,
  ) {
    return List.generate(goal, (index) {
      final isChecked = index < progress;
      return GestureDetector(
        onTap: () => _updateProgress(isMonthly, index, currentGoal),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.all(4),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isChecked ? Colors.green : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black26),
            boxShadow:
                isChecked
                    ? [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.6),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ]
                    : null,
          ),
          child:
              isChecked
                  ? const Icon(Icons.check, color: Colors.white, size: 22)
                  : null,
        ),
      );
    });
  }

  InputDecoration _buildInputDecoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: TextStyle(color: AppPallete.gradient2),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppPallete.gradient2, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppPallete.gradient3, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red, width: 2),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 Kitap Okuma Hedeflerin'),
        centerTitle: true,
      ),
      body: BlocConsumer<GoalBloc, GoalState>(
        listener: (context, state) {
          if (state is GoalFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is GoalLoadSuccess) {
            _monthlyController.text = state.bookGoal.monthlyGoal.toString();
            _yearlyController.text = state.bookGoal.yearlyGoal.toString();

            // Hedeflerin tamamlanma kontrolü
            final goal = state.bookGoal;
            if (goal.monthlyProgress >= goal.monthlyGoal &&
                goal.yearlyProgress >= goal.yearlyGoal &&
                goal.monthlyGoal > 0 &&
                goal.yearlyGoal > 0) {
              // Tebrik dialogunu göster
              showDialog(
                context: context,
                builder:
                    (_) => AlertDialog(
                      title: const Text("Tebrikler! 🎉"),
                      content: const Text(
                        "Aylık ve yıllık hedeflerinizi tamamladınız!",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text("Tamam"),
                        ),
                      ],
                    ),
              );
            }
          }
        },
        builder: (context, state) {
          if (state is GoalLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is GoalLoadSuccess) {
            final goal = state.bookGoal;

            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🎯 Hedef Belirle',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppPallete.gradient2,
                        ),
                      ),
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _monthlyController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: _buildInputDecoration(
                          'Aylık Hedef (Kitap)',
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty)
                            return 'Lütfen aylık hedef girin';
                          final monthlyValue = int.tryParse(val);
                          final yearlyValue =
                              int.tryParse(_yearlyController.text) ?? 0;

                          if (monthlyValue == null)
                            return 'Geçerli bir sayı girin';
                          if (yearlyValue == 0)
                            return 'Önce yıllık hedefi girin';
                          if (monthlyValue > yearlyValue)
                            return 'Aylık hedef yıllık hedeften fazla olamaz';

                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _yearlyController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: _buildInputDecoration(
                          'Yıllık Hedef (Kitap)',
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty)
                            return 'Lütfen yıllık hedef girin';
                          final yearlyValue = int.tryParse(val);
                          final monthlyValue =
                              int.tryParse(_monthlyController.text) ?? 0;

                          if (yearlyValue == null)
                            return 'Geçerli bir sayı girin';
                          if (yearlyValue < monthlyValue)
                            return 'Yıllık hedef aylık hedeften küçük olamaz';

                          return null;
                        },
                      ),

                      const SizedBox(height: 30),

                      if (goal.monthlyGoal > 0)
                        _buildProgressSection(
                          title: '📆 Aylık İlerleme',
                          goal: goal.monthlyGoal,
                          progress: goal.monthlyProgress,
                          isMonthly: true,
                          currentGoal: goal,
                        ),

                      const SizedBox(height: 20),

                      if (goal.yearlyGoal > 0)
                        _buildProgressSection(
                          title: '📅 Yıllık İlerleme',
                          goal: goal.yearlyGoal,
                          progress: goal.yearlyProgress,
                          isMonthly: false,
                          currentGoal: goal,
                        ),

                      const SizedBox(height: 40),

                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () => _saveGoals(goal),
                          icon: const Icon(
                            Icons.save,
                            color: AppPallete.gradient3,
                          ),
                          label: const Text(
                            'Hedefleri Kaydet',
                            style: TextStyle(color: AppPallete.gradient3),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppPallete.gradient2,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            textStyle: const TextStyle(fontSize: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else if (state is GoalFailure) {
            return Center(
              child: Text(
                'Hata: ${state.message}',
                style: const TextStyle(color: Colors.red, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildProgressSection({
    required String title,
    required int goal,
    required int progress,
    required bool isMonthly,
    required BookGoal currentGoal,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title ($progress / $goal)',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _buildProgressBoxes(currentGoal, goal, progress, isMonthly),
        ),
      ],
    );
  }
}
