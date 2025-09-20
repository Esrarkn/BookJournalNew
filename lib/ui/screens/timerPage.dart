/*import 'dart:async';
import 'package:book_journal/core/theme.dart/appPalette.dart';
import 'package:book_journal/ui/models/book.dart';
import 'package:book_journal/ui/widgets/appBackground.dart';
import 'package:book_journal/ui/widgets/appHeader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TimerPage extends StatefulWidget {
  final Book book;

  const TimerPage({Key? key, required this.book}) : super(key: key);

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> with TickerProviderStateMixin {
  Timer? _timer;
  int _seconds = 0;
  bool _isRunning = false;
  bool _isPaused = false;
  int _goalMinutes = 25;
  List<int> _sessions = [];

  late AnimationController _pulseController;
  late AnimationController _progressController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    // Demo verisi
    _sessions = [45, 30, 60, 25, 35]; 
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _progressController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_isPaused) {
      _isPaused = false;
    } else {
      _seconds = 0;
    }
    
    setState(() {
      _isRunning = true;
    });

    _pulseController.repeat(reverse: true);
    HapticFeedback.mediumImpact();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
      
      if (_goalMinutes > 0) {
        _progressController.animateTo(_seconds / (_goalMinutes * 60));
      }
      
      if (_goalMinutes > 0 && _seconds == _goalMinutes * 60) {
        HapticFeedback.heavyImpact();
        _showGoalReachedDialog();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _pulseController.stop();
    setState(() {
      _isRunning = false;
      _isPaused = true;
    });
    HapticFeedback.lightImpact();
  }

  void _stopTimer() {
    _timer?.cancel();
    _pulseController.stop();
    _progressController.reset();
    
    if (_seconds > 60) {
      _sessions.insert(0, (_seconds / 60).round());
      if (_sessions.length > 10) {
        _sessions = _sessions.take(10).toList();
      }
    }
    
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _seconds = 0;
    });
    
    HapticFeedback.lightImpact();
  }

  void _showGoalReachedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          title: Container(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppPalette.success, AppPalette.success.withOpacity(0.8)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.celebration, color: Colors.white, size: 30),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tebrikler!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppPalette.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '${_goalMinutes} dakikalık okuma hedefinizi başarıyla tamamladınız!\n\nDevam etmek ister misiniz?',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppPalette.textSecondary,
                height: 1.5,
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _stopTimer();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppPalette.textSecondary,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Bitir', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPalette.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Devam Et', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  String _formatTime(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppDarkPalette.background : AppPalette.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildModernHeader(isDark),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _buildBookCard(isDark),
                    const SizedBox(height: 40),
                    _buildModernTimer(isDark),
                    const SizedBox(height: 40),
                    _buildModernControls(isDark),
                    const SizedBox(height: 32),
                    _buildGoalSlider(isDark),
                    const SizedBox(height: 32),
                    _buildQuickStats(isDark),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (_isRunning) {
                _showExitDialog();
              } else {
                Navigator.pop(context);
              }
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? AppDarkPalette.surface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: isDark ? AppDarkPalette.textPrimary : AppPalette.textPrimary,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Okuma Seansı',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppDarkPalette.textPrimary : AppPalette.textPrimary,
                  ),
                ),
                Text(
                  'Odaklanma zamanı',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppDarkPalette.textSecondary : AppPalette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (_isRunning)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppPalette.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppPalette.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Aktif',
                    style: TextStyle(
                      color: AppPalette.success,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBookCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppPalette.primary.withOpacity(0.1),
            AppPalette.secondary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppPalette.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Hero(
            tag: 'book-${widget.book.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: widget.book.imageUrl.isNotEmpty
                  ? Image.network(
                      widget.book.imageUrl,
                      width: 80,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _placeholderBookImage();
                      },
                    )
                  : _placeholderBookImage(),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.book.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppDarkPalette.textPrimary : AppPalette.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.book.author,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppDarkPalette.textSecondary : AppPalette.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppPalette.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.category,
                        size: 14,
                        color: AppPalette.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.book.category ?? 'Genel',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppPalette.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderBookImage() {
    return Container(
      width: 80,
      height: 100,
      decoration: BoxDecoration(
        gradient: AppPalette.appGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.menu_book, color: Colors.white, size: 32),
    );
  }

  Widget _buildModernTimer(bool isDark) {
    final progress = _goalMinutes > 0 ? (_seconds / (_goalMinutes * 60)).clamp(0.0, 1.0) : 0.0;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isRunning ? _pulseAnimation.value : 1.0,
          child: Container(
            width: 300,
            height: 300,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        Colors.grey.shade50,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                      BoxShadow(
                        color: Colors.white,
                        blurRadius: 20,
                        offset: const Offset(-10, -10),
                      ),
                    ],
                  ),
                ),
                
                // Progress indicator
                SizedBox(
                  width: 280,
                  height: 280,
                  child: AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 12,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress >= 1.0 ? AppPalette.success : AppPalette.primary,
                        ),
                        strokeCap: StrokeCap.round,
                      );
                    },
                  ),
                ),

                // Timer content
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatTime(_seconds),
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w700,
                        color: AppPalette.primary,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Hedef: ${_goalMinutes} dk',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (progress > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: (progress >= 1.0 ? AppPalette.success : AppPalette.primary).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${(progress * 100).toInt()}% tamamlandı',
                          style: TextStyle(
                            fontSize: 14,
                            color: progress >= 1.0 ? AppPalette.success : AppPalette.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernControls(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Stop button
        AnimatedOpacity(
          opacity: (_isRunning || _isPaused) ? 1.0 : 0.3,
          duration: const Duration(milliseconds: 200),
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return GestureDetector(
                onTapDown: (_) => _scaleController.forward(),
                onTapUp: (_) => _scaleController.reverse(),
                onTapCancel: () => _scaleController.reverse(),
                onTap: (_isRunning || _isPaused) ? _stopTimer : null,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppPalette.error,
                          AppPalette.error.withOpacity(0.8),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppPalette.error.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.stop_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(width: 40),
        
        // Play/Pause button
        GestureDetector(
          onTapDown: (_) => _scaleController.forward(),
          onTapUp: (_) => _scaleController.reverse(),
          onTapCancel: () => _scaleController.reverse(),
          onTap: _isRunning ? _pauseTimer : _startTimer,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: AppPalette.appGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppPalette.primary.withOpacity(0.4),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 42,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGoalSlider(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppDarkPalette.surface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Okuma Hedefi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppDarkPalette.textPrimary : AppPalette.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppPalette.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_goalMinutes dk',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppPalette.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppPalette.primary,
              inactiveTrackColor: AppPalette.primary.withOpacity(0.2),
              thumbColor: AppPalette.primary,
              overlayColor: AppPalette.primary.withOpacity(0.2),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            ),
            child: Slider(
              value: _goalMinutes.toDouble(),
              min: 5,
              max: 120,
              divisions: 23,
              onChanged: _isRunning ? null : (value) {
                setState(() {
                  _goalMinutes = value.round();
                });
                HapticFeedback.selectionClick();
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '5 dk',
                style: TextStyle(
                  color: isDark ? AppDarkPalette.textTertiary : AppPalette.textTertiary,
                  fontSize: 12,
                ),
              ),
              Text(
                '120 dk',
                style: TextStyle(
                  color: isDark ? AppDarkPalette.textTertiary : AppPalette.textTertiary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppDarkPalette.surface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bu Hafta',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppDarkPalette.textPrimary : AppPalette.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '${_sessions.length}',
                  'Seans',
                  AppPalette.primary,
                  Icons.play_circle_outline,
                  isDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  '${_sessions.isNotEmpty ? _sessions.reduce((a, b) => a + b) : 0}',
                  'Toplam dk',
                  AppPalette.success,
                  Icons.schedule,
                  isDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  '${_sessions.isNotEmpty ? (_sessions.reduce((a, b) => a + b) / _sessions.length).round() : 0}',
                  'Ortalama dk',
                  AppPalette.warning,
                  Icons.trending_up,
                  isDark,
                ),
              ),
            ],
          ),
          if (_sessions.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'Son Seanslar',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? AppDarkPalette.textSecondary : AppPalette.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _sessions.take(5).length,
                itemBuilder: (context, index) {
                  final session = _sessions[index];
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppPalette.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '$session dk',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppPalette.primary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color color, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? AppDarkPalette.textTertiary : AppPalette.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Seansı sonlandır?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Okuma seansınız devam ediyor. Çıkmak istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Devam Et'),
          ),
          ElevatedButton(
            onPressed: () {
              _stopTimer();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPalette.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Çık'),
          ),
        ],
      ),
    );
  }
}*/
import 'dart:async';
import 'package:book_journal/core/theme.dart/appPalette.dart';
import 'package:book_journal/ui/models/book.dart';
import 'package:book_journal/ui/models/session.dart';
import 'package:book_journal/ui/widgets/appBackground.dart';
import 'package:book_journal/ui/widgets/appHeader.dart';
import 'package:book_journal/data/repository/firebaseBookRepository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TimerPage extends StatefulWidget {
  final Book book;

  const TimerPage({Key? key, required this.book}) : super(key: key);

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> with TickerProviderStateMixin {
  Timer? _timer;
  int _seconds = 0;
  bool _isRunning = false;
  bool _isPaused = false;
  int _goalMinutes = 25;

  late Stream<List<Session>> _sessionsStream;

  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;

  final FirebaseBookRepository _repository = FirebaseBookRepository();

  @override
  void initState() {
    super.initState();

    _sessionsStream = _repository.watchSessionsForBook(widget.book.id);

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_isPaused) {
      _isPaused = false;
    } else {
      _seconds = 0;
    }

    setState(() {
      _isRunning = true;
    });

    _pulseController.repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });

      if (_goalMinutes > 0) {
        _progressController.animateTo(_seconds / (_goalMinutes * 60));
      }

      if (_goalMinutes > 0 && _seconds == _goalMinutes * 60) {
        HapticFeedback.heavyImpact();
        _showGoalReachedDialog();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _pulseController.stop();
    setState(() {
      _isRunning = false;
      _isPaused = true;
    });
  }

  void _stopTimer() async {
    _timer?.cancel();
    _pulseController.stop();
    _progressController.reset();

    if (_seconds > 60) {
      final minutes = (_seconds / 60).round();
      await _repository.addSession(widget.book.id, minutes);
    }

    setState(() {
      _isRunning = false;
      _isPaused = false;
      _seconds = 0;
    });

    HapticFeedback.lightImpact();
  }

  void _showGoalReachedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.celebration, color: AppPalette.success, size: 28),
              const SizedBox(width: 12),
              const Text('Tebrikler!'),
            ],
          ),
          content: Text(
            '${_goalMinutes} dakikalık okuma hedefinizi tamamladınız!\n\nDevam etmek ister misiniz?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _stopTimer();
              },
              child: const Text('Bitir'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPalette.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Devam Et'),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  Widget _placeholderBookImage() {
    return Container(
      width: 60,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppPalette.primary, Colors.purple.shade300],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.menu_book, color: Colors.white, size: 24),
    );
  }

  Widget _buildBookInfo(bool isDark) {
    final cardColor = isDark ? AppDarkPalette.card : AppPalette.card;
    final textPrimary =
        isDark ? AppDarkPalette.textPrimary : AppPalette.textPrimary;
    final textSecondary =
        isDark ? AppDarkPalette.textSecondary : AppPalette.textSecondary;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child:
                widget.book.imageUrl.isNotEmpty
                    ? Image.network(
                      widget.book.imageUrl,
                      width: 60,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print('Resim yükleme hatası: $error');
                        return _placeholderBookImage();
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 60,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              value:
                                  loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                            ),
                          ),
                        );
                      },
                    )
                    : _placeholderBookImage(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.book.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.book.author,
                  style: TextStyle(fontSize: 14, color: textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.category, size: 14, color: AppPalette.primary),
                    const SizedBox(width: 4),
                    Text(
                      widget.book.category ?? 'Genel',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppPalette.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimer(bool isDark) {
    final progress =
        _goalMinutes > 0
            ? (_seconds / (_goalMinutes * 60)).clamp(0.0, 1.0)
            : 0.0;
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isRunning ? _pulseAnimation.value : 1.0,
          child: Container(
            width: 280,
            height: 280,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 280,
                  height: 280,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
                SizedBox(
                  width: 280,
                  height: 280,
                  child: AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress >= 1.0
                              ? AppPalette.success
                              : AppPalette.primary,
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.9),
                        Colors.grey.shade50,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatTime(_seconds),
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppPalette.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Hedef: ${_goalMinutes}dk',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (progress > 0)
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                progress >= 1.0
                                    ? AppPalette.success
                                    : AppPalette.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildControls(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        AnimatedOpacity(
          opacity: (_isRunning || _isPaused) ? 1.0 : 0.5,
          duration: const Duration(milliseconds: 200),
          child: GestureDetector(
            onTap: (_isRunning || _isPaused) ? _stopTimer : null,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.red.shade400,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.stop, color: Colors.white),
            ),
          ),
        ),
        GestureDetector(
          onTap: _isRunning ? _pauseTimer : _startTimer,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppPalette.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isRunning ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 36,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalSetter(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              if (_goalMinutes > 5) _goalMinutes -= 5;
            });
          },
          icon: const Icon(Icons.remove_circle_outline),
        ),
        const SizedBox(width: 12),
        Text(
          'Hedef: $_goalMinutes dk',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 12),
        IconButton(
          onPressed: () {
            setState(() {
              _goalMinutes += 5;
            });
          },
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: AppBackground(
        child: Column(
          children: [
            AppHeader(
              icon: Icons.arrow_back_ios,
              title: 'Okuma Zamanı',
              onBack: () {
                if (_isRunning) {
                  _showExitDialog();
                } else {
                  Navigator.pop(context);
                }
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildBookInfo(isDark),
                    const SizedBox(height: 30),
                    _buildTimer(isDark),
                    const SizedBox(height: 30),
                    _buildControls(isDark),
                    const SizedBox(height: 30),
                    _buildGoalSetter(isDark),
                    const SizedBox(height: 30),
                    StreamBuilder<List<Session>>(
                      stream: _sessionsStream,
                      builder: (context, snapshot) {
                        final sessions = snapshot.data ?? [];
                        return _buildEnhancedStats(isDark, sessions);
                      },
                    ),
                    const SizedBox(height: 30),
                    StreamBuilder<List<Session>>(
                      stream: _sessionsStream,
                      builder: (context, snapshot) {
                        final sessions = snapshot.data ?? [];
                        return _buildEnhancedRecentSessions(isDark, sessions);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widgetlar _buildBookInfo, _placeholderBookImage, _buildTimer, _buildControls, _buildGoalSetter aynı kalabilir ---
  // İstatistik ve seans listesi artık Stream ile geliyor

  Widget _buildEnhancedStats(bool isDark, List<Session> sessions) {
    final weeklyGoal = 300;
    final weeklyProgress =
        sessions.isNotEmpty
            ? sessions.fold<int>(0, (sum, s) => sum + s.minutes)
            : 0;
    final weeklyProgressPercent =
        weeklyGoal > 0 ? (weeklyProgress / weeklyGoal).clamp(0.0, 1.0) : 0.0;
    final dailyAverage = sessions.isNotEmpty ? (weeklyProgress / 7).round() : 0;
    final currentStreak = 3;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppDarkPalette.card : AppPalette.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bu Hafta İlerleme',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color:
                  isDark ? AppDarkPalette.textPrimary : AppPalette.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: weeklyProgressPercent,
            backgroundColor: Colors.grey.shade300,
            color:
                weeklyProgressPercent >= 1.0
                    ? AppPalette.success
                    : AppPalette.primary,
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Text('${weeklyProgressPercent * 100 ~/ 1}% tamamlandı'),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildEnhancedStatItem(
                '${sessions.length}',
                'Toplam Seans',
                Icons.play_circle_outline,
                AppPalette.primary,
              ),
              _buildEnhancedStatItem(
                '$dailyAverage',
                'Günlük Ortalama',
                Icons.trending_up,
                AppPalette.success,
              ),
              _buildEnhancedStatItem(
                '$currentStreak',
                'Gün Üst Üste',
                Icons.local_fire_department,
                AppPalette.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedStatItem(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEnhancedRecentSessions(bool isDark, List<Session> sessions) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppDarkPalette.card : AppPalette.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Son Okuma Seansları',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (sessions.isEmpty)
            Text('Henüz seans kaydınız yok')
          else
            Column(
              children:
                  sessions.take(5).map((session) {
                    return Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppPalette.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text('${session.minutes} dakika okuma'),
                        ),
                        Text(_formatSessionDate(session.date)),
                      ],
                    );
                  }).toList(),
            ),
        ],
      ),
    );
  }

  String _formatSessionDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) return 'Bugün';
    if (difference.inDays == 1) return 'Dün';
    if (difference.inDays < 7) return '${difference.inDays} gün önce';

    return '${date.day}/${date.month}';
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Okuma devam ediyor'),
            content: const Text(
              'Seansı durdurmak istediğinizden emin misiniz?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hayır'),
              ),
              ElevatedButton(
                onPressed: () {
                  _stopTimer();
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Evet'),
              ),
            ],
          ),
    );
  }
}
