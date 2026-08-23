import 'package:flutter/material.dart';

/// Identidad "mercado fresco": terracota/cosecha sobre fondo cálido casi
/// negro, con verde oliva como acento secundario — distinta de ZYNC (cian)
/// y BarberFlow (dorado), evocando puestos de mercado y etiquetas de
/// producto en vez de neón tecnológico.
class AppColors {
  static const harvest = Color(0xFFE8863C);
  static const harvestDim = Color(0xFFB8672A);
  static const olive = Color(0xFF7C9A4E);
  static const background = Color(0xFF15120E);
  static const surface = Color(0xFF211C15);
  static const surfaceLight = Color(0xFF2E271C);
}

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.harvest,
        secondary: AppColors.olive,
        surface: AppColors.surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.harvest,
        elevation: 0,
        centerTitle: false,
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.surface,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.harvest,
        foregroundColor: Colors.black,
      ),
      fontFamily: 'Roboto',
    );
  }
}
