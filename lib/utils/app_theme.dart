import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor   = Color(0xFF1A1F3C);
  static const Color primaryLight   = Color(0xFF252A4A);
  static const Color accentColor    = Color(0xFFFF4D6A);
  static const Color purpleAccent   = Color(0xFF7B61FF);
  static const Color backgroundLight= Color(0xFFF0F2F8);
  static const Color cardWhite      = Color(0xFFFFFFFF);
  static const Color textDark       = Color(0xFF1A1F3C);
  static const Color textGrey       = Color(0xFF8A8FA8);
  static const Color textLight      = Color(0xFFFFFFFF);
  static const Color dividerColor   = Color(0xFFE8EAF2);
  static const Color successColor   = Color(0xFF4CAF50);
  static const Color orangeAccent   = Color(0xFFFFB347);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: accentColor,
        surface: cardWhite,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundLight,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textDark),
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          fontFamily: 'Poppins',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: dividerColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: accentColor, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: const TextStyle(color: textGrey, fontSize: 14),
        labelStyle: const TextStyle(color: textGrey, fontSize: 14),
      ),
      cardTheme: CardThemeData(
        color: cardWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        shadowColor: Color.fromRGBO(26, 31, 60, 0.08),
      ),
      textTheme: const TextTheme(
        headlineLarge:
            TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: textDark),
        headlineMedium:
            TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: textDark),
        headlineSmall:
            TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textDark),
        titleLarge:
            TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textDark),
        titleMedium:
            TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textDark),
        bodyLarge:
            TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: textDark),
        bodyMedium:
            TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: textGrey),
        labelLarge:
            TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textDark),
      ),
    );
  }
}

// ── AppCard — plain Container so ListTile ink works inside it ────────────────
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? borderRadius;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final br = BorderRadius.circular(borderRadius ?? 20);
    return Material(
      color: color ?? AppTheme.cardWhite,
      borderRadius: br,
      child: InkWell(
        onTap: onTap,
        borderRadius: br,
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: br,
            boxShadow: [
              BoxShadow(
                color: const Color.fromRGBO(26, 31, 60, 0.06),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class DarkCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const DarkCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(26, 31, 60, 0.30),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class PillTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const PillTab({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textGrey,
            fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
