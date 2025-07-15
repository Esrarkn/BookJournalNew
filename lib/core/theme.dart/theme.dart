import 'package:book_journal/core/theme.dart/appPalette.dart';
import 'package:flutter/material.dart';
import 'package\:book\_journal/core/theme.dart/appPalette.dart';
import 'package\:flutter/material.dart';

class AppTheme {
static _border([Color color = AppPallete.borderColor]) => OutlineInputBorder(
borderSide: BorderSide(color: color, width: 3),
borderRadius: BorderRadius.circular(10),
);
static final lightThemeMode = ThemeData.dark().copyWith(
scaffoldBackgroundColor: AppPallete.backgroundColor,
bottomNavigationBarTheme: BottomNavigationBarThemeData(
backgroundColor: AppPallete.backgroundColor
),
appBarTheme: AppBarTheme(
backgroundColor: AppPallete.backgroundColor,
),
chipTheme: ChipThemeData(
color: MaterialStatePropertyAll(AppPallete.backgroundColor),
side: BorderSide.none,
),
inputDecorationTheme: InputDecorationTheme(
contentPadding: EdgeInsets.all(27),
border: _border(),
enabledBorder: _border(),
focusedBorder: _border(AppPallete.gradient2),
errorBorder: _border(AppPallete.errorColor),
),
 navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppPallete.backgroundColor,
      indicatorColor: AppPallete.gradient1.withOpacity(0.2),
      iconTheme: MaterialStateProperty.resolveWith<IconThemeData>(
        (states) => IconThemeData(
          color: states.contains(MaterialState.selected)
              ? AppPallete.gradient3
              : AppPallete.gradient1,
        ),
      ),
 ),
);
  static _borderDark([Color color = AppDarkPallete.borderColor]) =>
      OutlineInputBorder(
        borderSide: BorderSide(color: color, width: 3),
        borderRadius: BorderRadius.circular(10),
      );

  static final darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: AppDarkPallete.backgroundColor,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppDarkPallete.backgroundColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppDarkPallete.backgroundColor,
      iconTheme: IconThemeData(color: AppDarkPallete.gradient3),
      titleTextStyle: TextStyle(color: AppDarkPallete.textPrimary, fontSize: 20),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppDarkPallete.backgroundColor,
      side: BorderSide.none,
      labelStyle: TextStyle(color: AppDarkPallete.textPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: EdgeInsets.all(27),
      border: _borderDark(),
      enabledBorder: _borderDark(),
      focusedBorder: _borderDark(AppDarkPallete.gradient2),
      errorBorder: _borderDark(AppDarkPallete.gradient3), // errorColor yoksa
      hintStyle: TextStyle(color: AppDarkPallete.textSecondary),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppDarkPallete.backgroundColor,
      indicatorColor: AppDarkPallete.gradient1.withOpacity(0.2),
      iconTheme: MaterialStateProperty.resolveWith<IconThemeData>(
        (states) => IconThemeData(
          color: states.contains(MaterialState.selected)
              ? AppDarkPallete.gradient3
              : AppDarkPallete.gradient1,
        ),
      ),
    ),
  );
}


/*class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    scaffoldBackgroundColor: AppPallete.backgroundColor,
    colorScheme: const ColorScheme.light(
      primary: AppPallete.gradient1,
      secondary: Color(0xFF03DAC6),
      background: AppPallete.backgroundColor,
      surface: Color(0xFFFFFFFF),
      error: Color(0xFFB00020),
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onBackground: Colors.black,
      onSurface: Colors.black,
      onError: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPallete.backgroundColor,
      foregroundColor: Colors.black,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black, fontSize: 16),
      bodyMedium: TextStyle(color: Colors.black87, fontSize: 14),
      titleLarge: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppPallete.gradient2,
      selectedItemColor: AppPallete.gradient3,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFFFFFFF),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color:AppPallete.backgroundColor, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      hintStyle: const TextStyle(color: Colors.black45),
      labelStyle: const TextStyle(color: Colors.black87),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppPallete.backgroundColor,
      indicatorColor: Colors.white,
      labelTextStyle: MaterialStateProperty.all(
        const TextStyle(color:AppPallete.gradient1, fontWeight: FontWeight.w600),
      ),
      iconTheme: MaterialStateProperty.resolveWith<IconThemeData>(
        (states) => IconThemeData(
          color: states.contains(MaterialState.selected)
              ? AppPallete.gradient3
              : Colors.grey,
        ),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.all(const Color(0xFF6200EE)),
      trackColor: MaterialStateProperty.all(const Color(0xFFBB86FC)),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFF1E1E1E),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFBB86FC),
      secondary: Color(0xFF03DAC6),
      background: Color(0xFF121212),
      surface: Color(0xFF1E1E1E),
      error: Color(0xFFCF6679),
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onBackground: Colors.white,
      onSurface: Colors.white,
      onError: Colors.black,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
      bodyMedium: TextStyle(color: Colors.white70, fontSize: 14),
      titleLarge: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      selectedItemColor: Color(0xFFBB86FC),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2C2C2C),
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFBB86FC)),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF03DAC6), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      hintStyle: const TextStyle(color: Colors.white70),
      labelStyle: const TextStyle(color: Colors.white),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF1E1E1E),
      indicatorColor: const Color(0xFFBB86FC).withOpacity(0.2),
      labelTextStyle: MaterialStateProperty.all(
        const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      iconTheme: MaterialStateProperty.resolveWith<IconThemeData>(
        (states) => IconThemeData(
          color: states.contains(MaterialState.selected)
              ? const Color(0xFFBB86FC)
              : Colors.grey,
        ),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.all(const Color(0xFFBB86FC)),
      trackColor: MaterialStateProperty.all(const Color(0xFF3700B3)),
    ),
  );
}
*/