import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:book_journal/core/theme.dart/appPalette.dart';
import 'package:book_journal/data/bloc/goal_bloc/goal_bloc.dart';
import 'package:book_journal/data/bloc/goal_bloc/goal_state.dart';
import 'package:book_journal/data/bloc/goal_bloc/goal_event.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int readCount = 10; // Örnek veri
  int readingCount = 3; // Örnek veri

  void _editGoal() async {
    final controller = TextEditingController();

    final result = await showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Okuma Hedefini Güncelle"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Hedef Kitap Sayısı"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          TextButton(
            onPressed: () {
              final goal = int.tryParse(controller.text);
              if (goal != null && goal > 0) {
                Navigator.pop(context, goal);
              }
            },
            child: const Text("Kaydet"),
          ),
        ],
      ),
    );

    if (result != null) {
      context.read<GoalBloc>().add(AddGoal(targetBooks: result, targetDate: DateTime.now()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.backgroundColor,
      appBar: AppBar(
        title: const Text("Profil"),
        backgroundColor: AppPallete.backgroundColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppPallete.greyColor,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 10),
            const Text(
              "Kullanıcı Adı",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text("Okuma tutkunu!", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatCard(title: "Okunan", count: readCount),
                _StatCard(title: "Okunuyor", count: readingCount),

                /// Hedef bloc ile dinleniyor:
                BlocBuilder<GoalBloc, GoalState>(
                  builder: (context, state) {
                    int goal = 0;

                    if (state is GoalLoaded) {
                      goal = state.targetBooks;
                    } else if (state is GoalProgressUpdated) {
                      goal = state.completedBooks;
                    }

                    return GestureDetector(
                      onTap: _editGoal,
                      child: _StatCard(
                        title: "Hedef",
                        count: goal,
                        showEditIcon: true,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Ayarlar"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Çıkış Yap"),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int count;
  final bool showEditIcon;

  const _StatCard({
    required this.title,
    required this.count,
    this.showEditIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppPallete.gradient2,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "$count",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppPallete.greyColor,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(color: AppPallete.greyColor),
              ),
              if (showEditIcon) const SizedBox(width: 4),
              if (showEditIcon)
                const Icon(Icons.edit, size: 16, color: AppPallete.greyColor),
            ],
          ),
        ],
      ),
    );
  }
}
