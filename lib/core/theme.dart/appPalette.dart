import 'package:flutter/material.dart';

/// Açık Tema Renk Paleti
class AppPalette {
  // Ana Renkler
  static const Color primary = Color(0xFF818CF8); // modern mavi
  static const Color secondary = Color(0xFFED64A6); // modern pembe/mor
  static const Color accent = Color(0xFF4FACFE); // canlı mavi

  // Arkaplan & Yüzey
  static const Color background = Color(0xFFFAFAFA); // scaffold background
  static const Color surface = Color(0xFFFFFFFF); // card veya container background
  static const Color card = Color(0xCCFFFFFF); // istatistik kartları, küçük containerlar

  // Yazılar
  static const Color textPrimary = Color(0xFF1E293B); // başlıklar
  static const Color textSecondary = Color(0xFF64748B); // açıklamalar, alt metin
  static const Color textTertiary = Color(0xFF94A3B8); // placeholder, hint text

  // Dropdown & Border
  static const Color border = Color(0xFFE2E8F0); // dropdown border

  // Durum Renkleri
  static const Color success = Color(0xFF4C9A73); // okundu/başarılı
  static const Color warning = Color(0xFFF59E0B); // okunuyor / uyarı
  static const Color error = Color(0xFFEF4444);

  // Gradient
  static const LinearGradient appGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
    static const List<Color> feelingsCardGradient = [Color(0xFFF3E5F5), Color(0xFFFCE4EC)];
  static const Color feelingsIcon = Color.fromARGB(255, 170, 101, 182);
  static const Color feelingsText = Color(0xFF9C27B0);

  static const List<Color> quoteCardGradient = [Color(0xFFFFF8E1), Color(0xFFFFF3E0)];
  static const Color quoteIcon = Color(0xFFFFB300);
  static const Color quoteTitle = Color(0xFFFF8F00);


static const LinearGradient greenGradient = LinearGradient(
  colors: [primary,secondary, 
    
    
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);


}

/// Koyu Tema Renk Paleti
class AppDarkPalette {
  // Ana Renkler
  static const Color primary = Color(0xFF504B42); // haki kahve
  static const Color secondary = Color(0xFF965050); // sıcak kırmızı
  static const Color accent = Color(0xFF787369); // koyu gri

  // Arkaplan & Yüzey
  static const Color background = Color(0xFF0F172A); // scaffold background
  static const Color surface = Color(0xFF1E293B); // card veya container background
  static const Color card = Color(0xFF3A352D); // istatistik kartları, küçük containerlar

  // Yazılar
  static const Color textPrimary = Color(0xFFDCD7C8); // başlıklar
  static const Color textSecondary = Color(0xFFB4AAA0); // açıklamalar, alt metin
  static const Color textTertiary = Color(0xFF9A9387); // placeholder, hint text

  // Dropdown & Border
  static const Color border = Color(0xFF555148); // dropdown border koyu mod

  // Durum Renkleri
  static const Color success = Color(0xFF38C172);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFF87171);

  // Gradient
static const LinearGradient appGradient2 = LinearGradient(
  colors: [
    Color(0xFFEEEEEE), // Açık gri-beyaz ton
    Color(0xFFCCCCCC), // Orta gri ton
    Color(0xFFFFFFFF), // Saf beyaz
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
  static const LinearGradient appGradient = LinearGradient(
    colors: [Color(0xFF818CF8), Color(0xFFED64A6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

    static const List<Color> feelingsCardGradient = [Color(0xFFF3E5F5), Color(0xFFFCE4EC)];
  static const Color feelingsIcon = Color(0xFF9C27B0);

  static const List<Color> quoteCardGradient = [Color(0xFFFFF8E1), Color(0xFFFFF3E0)];
  static const Color quoteIcon = Color(0xFFFFB300);
  static const Color quoteTitle = Color(0xFFFF8F00);
}
