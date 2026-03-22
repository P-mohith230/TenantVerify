import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  static const EdgeInsets horizontalXs = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: xl);

  static const EdgeInsets verticalXs = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: xl);
}

class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
}

extension TextStyleContext on BuildContext {
  TextTheme get textStyles => Theme.of(this).textTheme;
}

extension TextStyleExtensions on TextStyle {
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);
  TextStyle get normal => copyWith(fontWeight: FontWeight.w400);
  TextStyle get light => copyWith(fontWeight: FontWeight.w300);
  TextStyle withColor(Color color) => copyWith(color: color);
  TextStyle withSize(double size) => copyWith(fontSize: size);
}

/// TenantVerify Brand Colors - Dark Futuristic Theme
class AppColors {
  // Primary: Neon Green (Trust/Verified)
  static const Color neonGreen = Color(0xFF00FF88);
  static const Color neonGreenDark = Color(0xFF00CC6A);
  static const Color neonGreenLight = Color(0xFF66FFBB);
  static const Color neonGreenGlow = Color(0x4000FF88);
  
  // Secondary: Electric Blue
  static const Color electricBlue = Color(0xFF00D4FF);
  static const Color electricBlueDark = Color(0xFF00A8CC);
  static const Color electricBlueGlow = Color(0x4000D4FF);
  
  // Accent: Cyber Purple
  static const Color cyberPurple = Color(0xFF9D4EDD);
  static const Color cyberPurpleGlow = Color(0x409D4EDD);
  
  // Warning: Amber
  static const Color warning = Color(0xFFFFB800);
  static const Color warningGlow = Color(0x40FFB800);
  
  // Error: Neon Red
  static const Color error = Color(0xFFFF3366);
  static const Color errorGlow = Color(0x40FF3366);
  
  // Background Grays - Deep Space
  static const Color background = Color(0xFF0A0E17);
  static const Color surface = Color(0xFF12151F);
  static const Color surfaceLight = Color(0xFF1A1F2E);
  static const Color surfaceLighter = Color(0xFF232836);
  static const Color cardBorder = Color(0xFF2A3042);
  
  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B8C9);
  static const Color textMuted = Color(0xFF6B7280);
  
  // Gradients
  static const LinearGradient neonGradient = LinearGradient(
    colors: [neonGreen, electricBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient purpleGradient = LinearGradient(
    colors: [cyberPurple, electricBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1A1F2E), Color(0xFF12151F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Legacy compatibility
  static const Color primary = neonGreen;
  static const Color primaryLight = neonGreenLight;
  static const Color primaryDark = neonGreenDark;
  static const Color accent = electricBlue;
  static const Color success = neonGreen;
  static const Color successLight = neonGreenGlow;
  static const Color neutral50 = surfaceLighter;
  static const Color neutral100 = surfaceLight;
  static const Color neutral200 = cardBorder;
  static const Color neutral300 = Color(0xFF3D4556);
  static const Color neutral400 = textMuted;
  static const Color neutral500 = Color(0xFF8892A5);
  static const Color neutral600 = textSecondary;
  static const Color neutral700 = Color(0xFFD1D5DB);
  static const Color neutral800 = Color(0xFFE5E7EB);
  static const Color neutral900 = textPrimary;
}

class FontSizes {
  static const double displayLarge = 57.0;
  static const double displayMedium = 45.0;
  static const double displaySmall = 36.0;
  static const double headlineLarge = 32.0;
  static const double headlineMedium = 28.0;
  static const double headlineSmall = 24.0;
  static const double titleLarge = 22.0;
  static const double titleMedium = 16.0;
  static const double titleSmall = 14.0;
  static const double labelLarge = 14.0;
  static const double labelMedium = 12.0;
  static const double labelSmall = 11.0;
  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;
}

ThemeData get lightTheme => darkTheme; // Default to dark theme

ThemeData get darkTheme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.dark(
    primary: AppColors.neonGreen,
    onPrimary: AppColors.background,
    primaryContainer: AppColors.neonGreenDark,
    onPrimaryContainer: AppColors.textPrimary,
    secondary: AppColors.electricBlue,
    onSecondary: AppColors.background,
    tertiary: AppColors.cyberPurple,
    onTertiary: AppColors.textPrimary,
    error: AppColors.error,
    onError: AppColors.textPrimary,
    errorContainer: AppColors.errorGlow,
    onErrorContainer: AppColors.error,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    surfaceContainerHighest: AppColors.surfaceLight,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.cardBorder,
    shadow: Colors.black,
    inversePrimary: AppColors.neonGreenDark,
  ),
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.background,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: AppColors.textPrimary,
    elevation: 0,
    scrolledUnderElevation: 0,
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    color: AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      side: const BorderSide(color: AppColors.cardBorder, width: 1),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.neonGreen,
      foregroundColor: AppColors.background,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.neonGreen,
      side: const BorderSide(color: AppColors.neonGreen),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.neonGreen,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceLight,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: AppColors.cardBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: AppColors.cardBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: AppColors.neonGreen, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: AppColors.error),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    labelStyle: const TextStyle(color: AppColors.textSecondary),
    hintStyle: const TextStyle(color: AppColors.textMuted),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: AppColors.surfaceLight,
    selectedColor: AppColors.neonGreenGlow,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
  ),
  dividerColor: AppColors.cardBorder,
  dialogTheme: DialogThemeData(
    backgroundColor: AppColors.surface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: AppColors.surface,
    modalBackgroundColor: AppColors.surface,
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: AppColors.surfaceLight,
    contentTextStyle: const TextStyle(color: AppColors.textPrimary),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
    behavior: SnackBarBehavior.floating,
  ),
  textTheme: _buildTextTheme(),
);

TextTheme _buildTextTheme() {
  return TextTheme(
    displayLarge: GoogleFonts.spaceMono(
      fontSize: FontSizes.displayLarge, 
      fontWeight: FontWeight.w700, 
      letterSpacing: -2,
      color: AppColors.textPrimary,
    ),
    displayMedium: GoogleFonts.spaceMono(
      fontSize: FontSizes.displayMedium, 
      fontWeight: FontWeight.w700,
      letterSpacing: -1,
      color: AppColors.textPrimary,
    ),
    displaySmall: GoogleFonts.spaceMono(
      fontSize: FontSizes.displaySmall, 
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    headlineLarge: GoogleFonts.inter(
      fontSize: FontSizes.headlineLarge, 
      fontWeight: FontWeight.w700, 
      letterSpacing: -0.5,
      color: AppColors.textPrimary,
    ),
    headlineMedium: GoogleFonts.inter(
      fontSize: FontSizes.headlineMedium, 
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    headlineSmall: GoogleFonts.inter(
      fontSize: FontSizes.headlineSmall, 
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    titleLarge: GoogleFonts.inter(
      fontSize: FontSizes.titleLarge, 
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: FontSizes.titleMedium, 
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: FontSizes.titleSmall, 
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: FontSizes.labelLarge, 
      fontWeight: FontWeight.w500, 
      letterSpacing: 0.1,
      color: AppColors.textPrimary,
    ),
    labelMedium: GoogleFonts.spaceMono(
      fontSize: FontSizes.labelMedium, 
      fontWeight: FontWeight.w500, 
      letterSpacing: 0.5,
      color: AppColors.textSecondary,
    ),
    labelSmall: GoogleFonts.spaceMono(
      fontSize: FontSizes.labelSmall, 
      fontWeight: FontWeight.w500, 
      letterSpacing: 0.5,
      color: AppColors.textMuted,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: FontSizes.bodyLarge, 
      fontWeight: FontWeight.w400, 
      letterSpacing: 0.15,
      color: AppColors.textPrimary,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: FontSizes.bodyMedium, 
      fontWeight: FontWeight.w400, 
      letterSpacing: 0.25,
      color: AppColors.textSecondary,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: FontSizes.bodySmall, 
      fontWeight: FontWeight.w400, 
      letterSpacing: 0.4,
      color: AppColors.textMuted,
    ),
  );
}

// Glow box decoration helper
BoxDecoration glowDecoration({
  Color color = AppColors.neonGreen,
  double glowRadius = 20,
  double borderRadius = AppRadius.lg,
  Color? backgroundColor,
}) {
  return BoxDecoration(
    color: backgroundColor ?? AppColors.surface,
    borderRadius: BorderRadius.circular(borderRadius),
    border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
    boxShadow: [
      BoxShadow(
        color: color.withValues(alpha: 0.3),
        blurRadius: glowRadius,
        spreadRadius: 0,
      ),
    ],
  );
}

// Animated gradient border
class GradientBorderPainter extends CustomPainter {
  final double progress;
  final double borderWidth;
  final double borderRadius;
  
  GradientBorderPainter({
    required this.progress,
    this.borderWidth = 2,
    this.borderRadius = AppRadius.lg,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    
    final gradient = SweepGradient(
      startAngle: 0,
      endAngle: 3.14159 * 2,
      colors: const [
        AppColors.neonGreen,
        AppColors.electricBlue,
        AppColors.cyberPurple,
        AppColors.neonGreen,
      ],
      transform: GradientRotation(progress * 3.14159 * 2),
    );
    
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    
    canvas.drawRRect(rrect, paint);
  }
  
  @override
  bool shouldRepaint(GradientBorderPainter oldDelegate) => 
      oldDelegate.progress != progress;
}
