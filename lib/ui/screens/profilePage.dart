import 'package:book_journal/core/theme.dart/appPalette.dart';
import 'package:book_journal/data/bloc/goal_bloc/goal_bloc.dart';
import 'package:book_journal/data/bloc/goal_bloc/goal_event.dart';
import 'package:book_journal/data/bloc/goal_bloc/goal_state.dart';
import 'package:book_journal/main.dart';
import 'package:book_journal/ui/models/bookGoal.dart';
import 'package:book_journal/ui/models/user.dart';
import 'package:book_journal/ui/screens/bookGoalsPage.dart';
import 'package:book_journal/ui/widgets/appBackground.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  final AppUser user;
  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
    context.read<GoalBloc>().add(const LoadGoal());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.logout, color: Colors.red.shade700),
            ),
            const SizedBox(width: 12),
            const Text('Çıkış Yap'),
          ],
        ),
        content: const Text('Hesabınızdan çıkış yapmak istediğinizden emin misiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: isDark ? AppDarkPalette.background : AppPalette.background,
      body: AppBackground(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: BlocConsumer<GoalBloc, GoalState>(
                    listener: (context, state) {
                      if (state is GoalFailure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: colors.error,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is GoalLoading || state is GoalInitial) {
                        return Center(child: CircularProgressIndicator(color: colors.primary));
                      } else if (state is GoalLoadSuccess) {
                        return _buildProfileContent(state.bookGoal);
                      } else if (state is GoalFailure) {
                        return _buildErrorState(state.message);
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8)
          )
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppPalette.primary, AppPalette.secondary],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profil',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hesap bilgilerin ve istatistiklerin',
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.onSurface.withOpacity(0.7)
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(BookGoal goal) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserCard(),
          const SizedBox(height: 24),
          _buildReadingStats(goal),
          const SizedBox(height: 24),
          _buildSettingsSection(),
        ],
      ),
    );
  }

  Widget _buildUserCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
            ? [AppDarkPalette.primary.withOpacity(0.2), AppDarkPalette.secondary.withOpacity(0.2)]
            : [AppPalette.primary.withOpacity(0.1), AppPalette.secondary.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black12 : Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8)
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppPalette.primary,
            child: const Icon(Icons.person, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            widget.user.name?.isNotEmpty == true ? widget.user.name! : "İsimsiz Kullanıcı",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: colors.onSurface
            ),
          ),
          if (widget.user.email != null) ...[
            const SizedBox(height: 4),
            Text(
              widget.user.email!,
              style: TextStyle(
                fontSize: 14,
                color: colors.onSurface.withOpacity(0.7)
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            "${DateTime.now().difference(widget.user.createdAt ?? DateTime.now()).inDays} gündür üyesiniz",
            style: TextStyle(
              fontSize: 12,
              color: colors.onSurface.withOpacity(0.6)
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingStats(BookGoal goal) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black12 : Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4)
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppPalette.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)
                ),
                child: Icon(Icons.auto_stories, color: AppPalette.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Okuma İstatistikleri',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Toplam Kitap', '${goal.yearlyProgress}', Icons.library_books, AppPalette.primary),
              _buildStatItem('Bu Ay', '${goal.monthlyProgress}', Icons.calendar_month, AppPalette.secondary),
              _buildStatItem('Ortalama', '3.2/ay', Icons.trending_up, Colors.amber),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    final colors = Theme.of(context).colorScheme;
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colors.onSurface
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: colors.onSurface.withOpacity(0.6)
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black12 : Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4)
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            Icons.flag,
            'Hedeflerim',
            'Aylık ve yıllık hedefler',
            AppPalette.primary,
           onTap: () => Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => BookGoalsPage()),
),

          ),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          _buildSettingsTile(
            Icons.history,
            'Okuma Geçmişi',
            'Okuduğun kitaplar',
            Colors.green,
            onTap: () {},
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, mode, child) {
              return _buildSettingsTile(
                Icons.dark_mode,
                'Koyu Mod',
                mode == ThemeMode.dark ? 'Açık' : 'Kapalı',
                Colors.indigo,
                trailing: Switch(
                  value: mode == ThemeMode.dark,
                  activeColor: AppPalette.primary,
                  onChanged: (val) => themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light,
                ),
                onTap: () => themeNotifier.value = mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
              );
            },
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          _buildSettingsTile(
            Icons.logout,
            'Çıkış Yap',
            'Hesabından güvenli çıkış',
            Colors.red,
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, String subtitle, Color color,
      {Widget? trailing, VoidCallback? onTap}) {
    final colors = Theme.of(context).colorScheme;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.onSurface.withOpacity(0.7)
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    final colors = Theme.of(context).colorScheme;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: colors.error.withOpacity(0.1),
                shape: BoxShape.circle
              ),
              child: Icon(Icons.error_outline, size: 60, color: colors.error),
            ),
            const SizedBox(height: 24),
            Text(
              "Bir hata oluştu",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colors.onSurface
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: colors.onSurface.withOpacity(0.7)
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.read<GoalBloc>().add(const LoadGoal()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPalette.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Yeniden Dene', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}