import 'package:book_journal/data/bloc/goal_bloc/goal_bloc.dart';
import 'package:book_journal/data/bloc/goal_bloc/goal_event.dart';
import 'package:book_journal/data/bloc/goal_bloc/goal_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookGoalsPage extends StatefulWidget {
  const BookGoalsPage({super.key});

  @override
  State<BookGoalsPage> createState() => _BookGoalsPageState();
}

class _BookGoalsPageState extends State<BookGoalsPage> {
  final _monthlyController = TextEditingController();
  final _yearlyController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
    int _yearlyGoal = 0; // Yıllık hedef
  int _yearlyProgress = 0; // Yıllık ilerleme

  void _saveGoals() {
    if (_formKey.currentState!.validate()) {
      final monthlyGoal = int.parse(_monthlyController.text);
      final yearlyGoal = int.parse(_yearlyController.text);

      // Bloc'a hedefleri gönderiyoruz
      BlocProvider.of<GoalBloc>(context).add(AddGoal(
        targetBooks: monthlyGoal,
        targetDate: DateTime.now().add(const Duration(days: 30)), // Örnek tarih
      ));

      // Burada yıllık hedef eklemeyi de yapabiliriz.

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hedefler kaydedildi!')),
      );
    }
  }

  void _toggleProgress(int index, bool isMonthly) {
    setState(() {
      if (isMonthly) {
        // Monthly hedef ilerlemesi
      } else {
        // Yıllık hedef ilerlemesi
      }
    });
  }

  void _incrementProgress(bool isMonthly) {
    // Hedef ilerlemesi arttırılacak
  }

  List<Widget> _buildProgressBoxes(int goal, int progress, bool isMonthly) {
    return List.generate(goal, (index) {
      bool isChecked = index < progress;
      return GestureDetector(
        onTap: () => _toggleProgress(index, isMonthly),
        child: Container(
          margin: const EdgeInsets.all(4),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isChecked ? Colors.green : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.black26),
          ),
          child: isChecked
              ? const Icon(Icons.check, color: Colors.white, size: 20)
              : null,
        ),
      );
    });
  }

  @override
  void dispose() {
    _monthlyController.dispose();
    _yearlyController.dispose();
    super.dispose();
  }
@override
Widget build(BuildContext context) {
  return BlocProvider(
  create: (context) => GoalBloc(),
  child: Scaffold(
    appBar: AppBar(
      title: const Text('Kitap Okuma Hedefleri'),
      centerTitle: true,
    ),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            const Text('🎯 Hedefini Belirle', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextFormField(
              controller: _monthlyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Aylık Hedef (Kitap)',
                border: OutlineInputBorder(),
              ),
              validator: (val) => val == null || val.isEmpty || int.tryParse(val) == null ? 'Geçerli bir sayı girin' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _yearlyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Yıllık Hedef (Kitap)',
                border: OutlineInputBorder(),
              ),
              validator: (val) => val == null || val.isEmpty || int.tryParse(val) == null ? 'Geçerli bir sayı girin' : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveGoals,
              child: const Text('Kaydet'),
            ),
            // BlocBuilder kullanımı
            BlocBuilder<GoalBloc, GoalState>(
              builder: (context, state) {
                if (state is GoalLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is GoalLoaded) {
                  return Column(
                    children: [
                      const SizedBox(height: 24),
                      Text('📆 Aylık İlerleme (${state.completedBooks} / ${state.targetBooks})'),
                      Wrap(
                        children: _buildProgressBoxes(state.targetBooks, state.completedBooks, true),
                      ),
                    ],
                  );
                } else if (state is GoalError) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    ),
  ),
);

}

}
