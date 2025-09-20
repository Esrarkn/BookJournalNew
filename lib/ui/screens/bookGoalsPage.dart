import 'package:book_journal/core/theme.dart/appPalette.dart';
import 'package:book_journal/data/bloc/goal_bloc/goal_bloc.dart';
import 'package:book_journal/data/bloc/goal_bloc/goal_event.dart';
import 'package:book_journal/data/bloc/goal_bloc/goal_state.dart';
import 'package:book_journal/ui/models/bookGoal.dart';
import 'package:book_journal/ui/widgets/appBackground.dart';
import 'package:book_journal/ui/widgets/appHeader.dart';
import 'package:book_journal/ui/widgets/saveButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';

class BookGoalsPage extends StatefulWidget {
  const BookGoalsPage({super.key});

  @override
  State<BookGoalsPage> createState() => _BookGoalsPageState();
}

class _BookGoalsPageState extends State<BookGoalsPage> with TickerProviderStateMixin {
  final _monthlyController = TextEditingController();
  final _yearlyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  late GoalBloc _goalBloc;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _goalBloc = context.read<GoalBloc>();
    _goalBloc.add(LoadGoal());
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _monthlyController.dispose();
    _yearlyController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _saveGoals(BookGoal currentGoal) {
    if (!_formKey.currentState!.validate()) return;

    final monthlyGoal = int.parse(_monthlyController.text);
    final yearlyGoal = int.parse(_yearlyController.text);

    int monthlyProgress = currentGoal.monthlyProgress;
    int yearlyProgress = currentGoal.yearlyProgress;

    if (monthlyProgress > monthlyGoal) monthlyProgress = monthlyGoal;
    if (yearlyProgress > yearlyGoal) yearlyProgress = yearlyGoal;
    if (monthlyProgress > yearlyProgress) yearlyProgress = monthlyProgress;

    final updatedGoal = currentGoal.copyWith(
      monthlyGoal: monthlyGoal,
      yearlyGoal: yearlyGoal,
      monthlyProgress: monthlyProgress,
      yearlyProgress: yearlyProgress,
    );

    _goalBloc.add(UpdateGoal(updatedGoal));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Hedefler başarıyla kaydedildi!'),
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _updateProgress(bool isMonthly, int index, BookGoal currentGoal) {
    int newProgress = (index < (isMonthly ? currentGoal.monthlyProgress : currentGoal.yearlyProgress))
        ? index
        : index + 1;

    if (isMonthly && newProgress > currentGoal.monthlyGoal) {
      _showErrorSnackBar('Aylık ilerleme aylık hedefi aşamaz!');
      return;
    }
    if (!isMonthly) {
      if (newProgress > currentGoal.yearlyGoal) {
        _showErrorSnackBar('Yıllık ilerleme yıllık hedefi aşamaz!');
        return;
      }
      if (newProgress < currentGoal.monthlyProgress) {
        _showErrorSnackBar('Yıllık ilerleme aylık ilerlemeden küçük olamaz!');
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: AppBackground(
        child: Column(
          children: [
            _buildModernHeader(context),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: BlocConsumer<GoalBloc, GoalState>(
                  listener: (context, state) {
                    if (state is GoalFailure) {
                      _showErrorSnackBar(state.message);
                    } else if (state is GoalLoadSuccess) {
                      _monthlyController.text = state.bookGoal.monthlyGoal.toString();
                      _yearlyController.text = state.bookGoal.yearlyGoal.toString();

                      final goal = state.bookGoal;
                      if (goal.monthlyProgress >= goal.monthlyGoal &&
                          goal.yearlyProgress >= goal.yearlyGoal &&
                          goal.monthlyGoal > 0 &&
                          goal.yearlyGoal > 0) {
                        _showCelebrationDialog();
                      }
                    }
                  },
                  builder: (context, state) {
                    if (state is GoalLoading) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(AppPalette.primary),
                        ),
                      );
                    } else if (state is GoalLoadSuccess) {
                      return _buildGoalContent(state.bookGoal);
                    } else if (state is GoalFailure) {
                      return _buildErrorState(state.message);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
Widget _buildModernHeader(BuildContext context) {
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
          color: colors.shadow.withOpacity(0.05),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: SafeArea(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.primary, colors.secondary],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(LucideIcons.target, color: colors.onPrimary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Okuma Hedefleri',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Hedeflerini belirle ve takip et',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}


  Widget _buildGoalContent(BookGoal goal) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildGoalInputSection(goal),
            const SizedBox(height: 32),
            if (goal.monthlyGoal > 0) ...[
              _buildProgressCard(
                title: 'Aylık İlerleme',
                progress: goal.monthlyProgress,
                total: goal.monthlyGoal,
                color: Colors.blue,
                isMonthly: true,
                currentGoal: goal,
              ),
              const SizedBox(height: 24),
            ],
            if (goal.yearlyGoal > 0) ...[
              _buildProgressCard(
                title: 'Yıllık İlerleme',
                progress: goal.yearlyProgress,
                total: goal.yearlyGoal,
                color: Colors.green,
                isMonthly: false,
                currentGoal: goal,
              ),
              const SizedBox(height: 32),
            ],
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppPalette.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: SaveButton(
                text: "Hedefleri Kaydet",
                onPressed: () => _saveGoals(goal),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalInputSection(BookGoal goal) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(LucideIcons.target, size: 32, color: Colors.red),
              ),
              const SizedBox(width: 12),
              const Text(
                'Hedeflerini Belirle',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildModernTextField(
            controller: _monthlyController,
            label: 'Aylık Hedef',
            hint: 'Bu ay kaç kitap okumayı planlıyorsun?',
            icon: Icons.calendar_today,
          ),
          const SizedBox(height: 20),
          _buildModernTextField(
            controller: _yearlyController,
            label: 'Yıllık Hedef',
            hint: 'Bu yıl kaç kitap okumayı planlıyorsun?',
            icon: Icons.calendar_month,
          ),
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(color: Colors.black87, fontSize: 16),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              prefixIcon: Icon(icon, color: Colors.grey.shade600, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            ),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return label.toLowerCase().contains('aylık') 
                    ? 'Lütfen aylık hedef girin' 
                    : 'Lütfen yıllık hedef girin';
              }
              final value = int.tryParse(val);
              if (value == null || value <= 0) return 'Geçerli bir sayı girin';
              
              if (label.toLowerCase().contains('aylık')) {
                final yearlyValue = int.tryParse(_yearlyController.text) ?? 0;
                if (yearlyValue > 0 && value > yearlyValue) {
                  return 'Aylık hedef yıllık hedeften fazla olamaz';
                }
              } else {
                final monthlyValue = int.tryParse(_monthlyController.text) ?? 0;
                if (monthlyValue > 0 && value < monthlyValue) {
                  return 'Yıllık hedef aylık hedeften küçük olamaz';
                }
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard({
    required String title,
    required int progress,
    required int total,
    required Color color,
    required bool isMonthly,
    required BookGoal currentGoal,
  }) {
    final percentage = total > 0 ? (progress / total) : 0.0;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isMonthly ? Icons.calendar_month : Icons.calendar_month_outlined,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    Text(
                      '$progress / $total kitap',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(percentage * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Progress bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  height: 8,
                  width: MediaQuery.of(context).size.width * percentage,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Book grid
          if (total > 0) _buildBookGrid(total, progress, isMonthly, currentGoal, color),
        ],
      ),
    );
  }

  Widget _buildBookGrid(int total, int progress, bool isMonthly, BookGoal currentGoal, Color color) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(total, (index) {
        final isCompleted = index < progress;
        return GestureDetector(
          onTap: () => _updateProgress(isMonthly, index, currentGoal),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted ? color : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isCompleted ? color : Colors.grey.shade300,
                width: 1.5,
              ),
              boxShadow: isCompleted
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: isCompleted
                ? Icon(
                    Icons.menu_book,
                    color: Colors.white,
                    size: 20,
                  )
                : Icon(
                    Icons.menu_book_outlined,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
          ),
        );
      }),
    );
  }

  void _showCelebrationDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.celebration, color: Colors.amber.shade700),
            ),
            const SizedBox(width: 12),
            const Text(
              "Tebrikler!",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        content: const Text(
          "Aylık ve yıllık hedeflerinizi tamamladınız! Harika bir başarı!",
          style: TextStyle(
            fontSize: 15,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              backgroundColor: AppPalette.primary.withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              "Teşekkürler!",
              style: TextStyle(
                color: AppPalette.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Bir hata oluştu",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              _goalBloc.add(LoadGoal());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPalette.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Yeniden Dene',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}