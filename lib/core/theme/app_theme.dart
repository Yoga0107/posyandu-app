import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // ─── Primary Blue ───
  static const Color primary        = Color(0xFF1565C0);
  static const Color primaryLight   = Color(0xFF1E88E5);
  static const Color primaryLighter = Color(0xFFBBDEFB);
  static const Color primaryDark    = Color(0xFF0D47A1);

  // ─── Accent Green ───
  static const Color accent         = Color(0xFF2E7D32);
  static const Color accentLight    = Color(0xFF43A047);
  static const Color accentLighter  = Color(0xFFC8E6C9);

  // ─── Orange (highlight/warning) ───
  static const Color orange         = Color(0xFFE65100);
  static const Color orangeLight    = Color(0xFFFF7043);
  static const Color orangeLighter  = Color(0xFFFFE0B2);

  // ─── Neutral ───
  static const Color white          = Color(0xFFFFFFFF);
  static const Color background     = Color(0xFFF0F4FF);
  static const Color surface        = Color(0xFFFFFFFF);
  static const Color divider        = Color(0xFFE3EAFD);
  static const Color textPrimary    = Color(0xFF1A237E);
  static const Color textSecondary  = Color(0xFF546E7A);
  static const Color textHint       = Color(0xFF90A4AE);
  static const Color border         = Color(0xFFCFD8DC);

  // ─── Status Gizi ───
  static const Color statusBaik        = Color(0xFF2E7D32);
  static const Color statusKurang      = Color(0xFFF57F17);
  static const Color statusBuruk       = Color(0xFFC62828);
  static const Color statusLebih       = Color(0xFF1565C0);
  static const Color statusWarning     = Color(0xFFFF6F00);

  // ─── Semantic ───
  static const Color error    = Color(0xFFB71C1C);
  static const Color success  = Color(0xFF2E7D32);
  static const Color warning  = Color(0xFFF57F17);
  static const Color info     = Color(0xFF1565C0);

  // ─── Gradient ───
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFFE65100), Color(0xFFFF7043)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color statusGiziColor(String? kode) {
    switch (kode) {
      // Old format (backward compat)
      case 'BBU_NORMAL':        return statusBaik;
      case 'BBU_KURANG':        return statusKurang;
      case 'BBU_SANGAT_KURANG': return statusBuruk;
      case 'BBU_LEBIH':         return statusLebih;
      // New Ryan ERD format
      case 'normal':            return statusBaik;
      case 'stunting':          return statusBuruk;
      case 'underweight':       return statusKurang;
      case 'overweight':        return statusLebih;
      case 'gizi-buruk':        return statusBuruk;
      // Dewasa/Lansia (IMT) — kode berbeda dari balita
      case 'kurus-berat':       return statusBuruk;
      case 'kurus-ringan':      return statusKurang;
      case 'gemuk-ringan':      return statusLebih;
      case 'gemuk-berat':       return statusBuruk;
      default:                  return textSecondary;
    }
  }
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        tertiary: AppColors.orange,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge:  GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        displayMedium: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        headlineLarge: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 24),
        headlineMedium:GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 20),
        headlineSmall: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 18),
        titleLarge:    GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 16),
        titleMedium:   GoogleFonts.poppins(fontWeight: FontWeight.w500, color: AppColors.textPrimary, fontSize: 14),
        bodyLarge:     GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 14),
        bodyMedium:    GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 13),
        bodySmall:     GoogleFonts.poppins(color: AppColors.textHint, fontSize: 12),
        labelLarge:    GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: AppColors.white,
        ),
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 2,
        shadowColor: AppColors.primary.withOpacity(0.12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 3,
          shadowColor: AppColors.primary.withOpacity(0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: GoogleFonts.poppins(color: AppColors.textHint, fontSize: 13),
        labelStyle: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 13),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.primaryLighter,
        labelStyle: GoogleFonts.poppins(fontSize: 12, color: AppColors.primary),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: GoogleFonts.poppins(color: AppColors.white, fontSize: 13),
      ),
    );
  }
}
