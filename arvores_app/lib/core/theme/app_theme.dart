import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Color Palette — soft, professional, easy on the eyes
// ─────────────────────────────────────────────────────────────────────────────
abstract class AppColors {
  // Backgrounds
  static const background   = Color(0xFFF7F8FC);
  static const surface      = Color(0xFFFFFFFF);
  static const surfaceAlt   = Color(0xFFF0F2FA);

  // Brand
  static const primary      = Color(0xFF4A6CF7); // indigo-blue
  static const primaryLight = Color(0xFFEEF1FE);
  static const secondary    = Color(0xFF7C3AED); // violet
  static const secondaryLight = Color(0xFFF3EFFE);

  // Semantic
  static const success      = Color(0xFF10B981);
  static const successLight = Color(0xFFECFDF5);
  static const warning      = Color(0xFFF59E0B);
  static const warningLight = Color(0xFFFFFBEB);
  static const error        = Color(0xFFEF4444);
  static const errorLight   = Color(0xFFFEF2F2);

  // Text
  static const textPrimary  = Color(0xFF1E293B);
  static const textSecondary= Color(0xFF64748B);
  static const textDisabled = Color(0xFFCBD5E1);

  // Borders / Dividers
  static const border       = Color(0xFFE2E8F0);
  static const divider      = Color(0xFFF1F5F9);

  // Node colors per structure
  static const splayNode    = Color(0xFF4A6CF7);
  static const treapNode    = Color(0xFF7C3AED);
  static const trieNode     = Color(0xFF10B981);
  static const patriciaNode = Color(0xFFF59E0B);
  static const kdNode       = Color(0xFFEF4444);
}

// ─────────────────────────────────────────────────────────────────────────────
// Structure metadata (used on cards and tree viewer)
// ─────────────────────────────────────────────────────────────────────────────
enum TreeStructure { splay, treap, trie, patricia, kdTree }

extension TreeStructureInfo on TreeStructure {
  String get title {
    switch (this) {
      case TreeStructure.splay:    return 'Splay Tree';
      case TreeStructure.treap:    return 'Treap';
      case TreeStructure.trie:     return 'Trie';
      case TreeStructure.patricia: return 'Patricia Tree';
      case TreeStructure.kdTree:   return 'KD-Tree';
    }
  }

  String get subtitle {
    switch (this) {
      case TreeStructure.splay:    return 'BST auto-ajustável';
      case TreeStructure.treap:    return 'BST + Heap probabilístico';
      case TreeStructure.trie:     return 'Árvore de prefixos';
      case TreeStructure.patricia: return 'Radix Tree compacta';
      case TreeStructure.kdTree:   return 'Busca espacial 2D';
    }
  }

  String get avgComplexity {
    switch (this) {
      case TreeStructure.splay:    return 'O(log n) amortizado';
      case TreeStructure.treap:    return 'O(log n) esperado';
      case TreeStructure.trie:     return 'O(m) por operação';
      case TreeStructure.patricia: return 'O(m) por operação';
      case TreeStructure.kdTree:   return 'O(√n) busca 2D';
    }
  }

  Color get color {
    switch (this) {
      case TreeStructure.splay:    return AppColors.splayNode;
      case TreeStructure.treap:    return AppColors.treapNode;
      case TreeStructure.trie:     return AppColors.trieNode;
      case TreeStructure.patricia: return AppColors.patriciaNode;
      case TreeStructure.kdTree:   return AppColors.kdNode;
    }
  }

  Color get lightColor {
    switch (this) {
      case TreeStructure.splay:    return AppColors.primaryLight;
      case TreeStructure.treap:    return AppColors.secondaryLight;
      case TreeStructure.trie:     return AppColors.successLight;
      case TreeStructure.patricia: return AppColors.warningLight;
      case TreeStructure.kdTree:   return AppColors.errorLight;
    }
  }

  String get icon {
    switch (this) {
      case TreeStructure.splay:    return '↺';
      case TreeStructure.treap:    return '⚖';
      case TreeStructure.trie:     return '⌨';
      case TreeStructure.patricia: return '⚡';
      case TreeStructure.kdTree:   return '⊕';
    }
  }

  String get description {
    switch (this) {
      case TreeStructure.splay:
        return 'Move o nó acessado para a raiz via rotações (Zig, Zig-Zig, Zig-Zag), '
               'promovendo localidade temporal e cache eficiente.';
      case TreeStructure.treap:
        return 'Combina BST (por chave) com heap (por prioridade aleatória), '
               'garantindo balanceamento probabilístico sem rotações complexas.';
      case TreeStructure.trie:
        return 'Armazena strings compartilhando prefixos em nós comuns. '
               'Ideal para autocompletar, dicionários e busca por prefixo.';
      case TreeStructure.patricia:
        return 'Radix Tree compacta: comprime caminhos com um único filho, '
               'reduzindo espaço e acelerando buscas em conjuntos de strings.';
      case TreeStructure.kdTree:
        return 'Particiona espaço 2D alternando eixos (x, y). Suporta busca '
               'por vizinho mais próximo e busca por intervalo em O(√n).';
    }
  }

  bool get isStringBased =>
      this == TreeStructure.trie || this == TreeStructure.patricia;

  bool get isSpatial => this == TreeStructure.kdTree;
}

// ─────────────────────────────────────────────────────────────────────────────
// App Theme
// ─────────────────────────────────────────────────────────────────────────────
abstract class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        background: AppColors.background,
        surface: AppColors.surface,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
      dividerColor: AppColors.border,
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceAlt,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textDisabled),
        labelStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceAlt,
        selectedColor: AppColors.primaryLight,
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
    );
  }
}
