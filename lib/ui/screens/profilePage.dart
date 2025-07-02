import 'package:book_journal/ui/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:book_journal/data/bloc/goal_bloc/goal_bloc.dart';
import 'package:book_journal/data/bloc/goal_bloc/goal_event.dart';
import 'package:book_journal/data/bloc/goal_bloc/goal_state.dart';
import 'package:book_journal/ui/models/bookGoal.dart';
import 'package:book_journal/core/theme.dart/appPalette.dart';

class ProfilePage extends StatefulWidget {
  final AppUser user;
   ProfilePage({super.key,required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController monthlyController;
  late TextEditingController yearlyController;

  @override
  void initState() {
    super.initState();
    monthlyController = TextEditingController();
    yearlyController = TextEditingController();
    // Hedefi yükle
    context.read<GoalBloc>().add(const LoadGoal());
  }

  @override
  void dispose() {
    monthlyController.dispose();
    yearlyController.dispose();
    super.dispose();
  }

  void _editGoal(BookGoal? currentGoal) async {
    if (currentGoal != null) {
      monthlyController.text = currentGoal.monthlyGoal.toString();
      yearlyController.text = currentGoal.yearlyGoal.toString();
    } else {
      monthlyController.clear();
      yearlyController.clear();
    }

    final result = await showDialog<BookGoal>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Okuma Hedefini Güncelle"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: monthlyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Aylık Hedef Kitap Sayısı"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: yearlyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Yıllık Hedef Kitap Sayısı"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          TextButton(
            onPressed: () {
              final monthlyGoal = int.tryParse(monthlyController.text);
              final yearlyGoal = int.tryParse(yearlyController.text);

              if (monthlyGoal != null && monthlyGoal > 0 && yearlyGoal != null && yearlyGoal > 0) {
                Navigator.pop(
                  context,
                  BookGoal(
                    monthlyGoal: monthlyGoal,
                    yearlyGoal: yearlyGoal,
                    monthlyProgress: currentGoal?.monthlyProgress ?? 0,
                    yearlyProgress: currentGoal?.yearlyProgress ?? 0,
                  ),
                );
              } else {
                // Hata göster
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Geçersiz Giriş"),
                    content: const Text("Lütfen pozitif sayılar giriniz."),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Tamam"),
                      ),
                    ],
                  ),
                );
              }
            },
            child: const Text("Kaydet"),
          ),
        ],
      ),
    );

    if (result != null) {
      context.read<GoalBloc>().add(UpdateGoal(result));
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
      child: BlocConsumer<GoalBloc, GoalState>(
        listener: (context, state) {
          if (state is GoalFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is GoalInitial || state is GoalLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is GoalLoadSuccess) {
            final goal = state.bookGoal;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: AppPallete.greyColor,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.user.name?.isNotEmpty == true ? widget.user.name! : "İsimsiz Kullanıcı",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  if (widget.user.email != null)
                    Text(widget.user.email!, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 10),
                  const Text(
                    "Okuma alışkanlığını takip et!",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 30),

                  // Gelişmiş Hedef Kartları
                  _GoalCard(
                    title: "Aylık Hedef",
                    progress: goal.monthlyProgress,
                    total: goal.monthlyGoal,
                    onTap: () => _editGoal(goal),
                  ),
                  const SizedBox(height: 16),
                  _GoalCard(
                    title: "Yıllık Hedef",
                    progress: goal.yearlyProgress,
                    total: goal.yearlyGoal,
                    onTap: () => _editGoal(goal),
                  ),

                  const SizedBox(height: 30),
                  const Divider(),

                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text("Ayarlar"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
               ListTile(
  leading: const Icon(Icons.logout),
  title: const Text("Çıkış Yap"),
  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
  onTap: () async {
    await FirebaseAuth.instance.signOut();

    // Kullanıcıyı login ekranına yönlendir
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  },
),

                ],
              ),
            );
          } else if (state is GoalFailure) {
            return Center(
              child: Text(
                state.message,
                style: TextStyle(color: Colors.red[700]),
                textAlign: TextAlign.center,
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    ),
  );
}

}

class _StatCard extends StatelessWidget {
  final String title;
  final String label;
  final bool showEditIcon;

  const _StatCard({
    required this.title,
    required this.label,
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
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "$label",
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
class _GoalCard extends StatelessWidget {
  final String title;
  final int progress;
  final int total;
  final VoidCallback? onTap;

  const _GoalCard({
    required this.title,
    required this.progress,
    required this.total,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    double ratio = total > 0 ? progress / total : 0;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppPallete.gradient2,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$title: $progress / $total",
              style: const TextStyle(
                fontSize: 18,
                color: AppPallete.greyColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: ratio.clamp(0, 1),
              color: Colors.white,
              backgroundColor: Colors.white.withOpacity(0.2),
              minHeight: 5,
              borderRadius: BorderRadius.circular(10),
            ),
          ],
        ),
      ),
    );
  }
}
