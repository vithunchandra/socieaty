import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socieaty/core/theme/app_pallete.dart';

class CustomTextTheme {
  CustomTextTheme._();

  static final TextTheme lightTextTheme = TextTheme(
    // Large titles for welcome screens and major headers
    displayLarge: GoogleFonts.inter(
      fontSize: 57,
      color: AppPallete.lightColorOnSurface,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
    ),
    // Section headers and feature titles
    displayMedium: GoogleFonts.inter(
      fontSize: 45,
      color: AppPallete.lightColorOnSurface,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
    ),
    // Post titles and major content headers
    displaySmall: GoogleFonts.inter(
      fontSize: 36,
      color: AppPallete.lightColorOnSurface,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.25,
    ),
    // Livestream titles and important notifications
    headlineLarge: GoogleFonts.inter(
      fontSize: 32,
      color: AppPallete.lightColorOnSurface,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.25,
    ),
    // Food titles and category headers
    headlineMedium: GoogleFonts.inter(
      fontSize: 28,
      color: AppPallete.lightColorOnSurface,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
    ),
    // Sub-section headers
    headlineSmall: GoogleFonts.inter(
      fontSize: 24,
      color: AppPallete.lightColorOnSurface,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
    ),
    // Navigation titles and important buttons
    titleLarge: GoogleFonts.roboto(
      fontSize: 22,
      color: AppPallete.lightColorOnSurface,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
    ),
    // Card titles and menu items
    titleMedium: GoogleFonts.roboto(
      fontSize: 18,
      color: AppPallete.lightColorOnSurface,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
    ),
    // List items and secondary text
    titleSmall: GoogleFonts.roboto(
      fontSize: 16,
      color: AppPallete.lightColorOnSurface,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    // Main content text
    bodyLarge: GoogleFonts.roboto(
      fontSize: 16,
      color: AppPallete.lightColorOnSurface,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.5,
    ),
    // Comments and descriptions
    bodyMedium: GoogleFonts.roboto(
      fontSize: 14,
      color: AppPallete.lightColorOnSurface,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.25,
    ),
    // Timestamps and secondary information
    bodySmall: GoogleFonts.roboto(
      fontSize: 12,
      color: AppPallete.lightColorOnSurface,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.4,
    ),
    // Button text and important actions
    labelLarge: GoogleFonts.roboto(
      fontSize: 14,
      color: AppPallete.lightColorOnSurface,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    // Small button text and tags
    labelMedium: GoogleFonts.roboto(
      fontSize: 12,
      color: AppPallete.lightColorOnSurface,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
    // Smallest UI elements
    labelSmall: GoogleFonts.roboto(
      fontSize: 11,
      color: AppPallete.lightColorOnSurface,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
  );

  static final TextTheme darkTextTheme = TextTheme(
    displayLarge: GoogleFonts.inter(
      fontSize: 57,
      color: AppPallete.darkColorOnSurface,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
    ),
    displayMedium: GoogleFonts.inter(
      fontSize: 45,
      color: AppPallete.darkColorOnSurface,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
    ),
    displaySmall: GoogleFonts.inter(
      fontSize: 36,
      color: AppPallete.darkColorOnSurface,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.25,
    ),
    headlineLarge: GoogleFonts.inter(
      fontSize: 32,
      color: AppPallete.darkColorOnSurface,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.25,
    ),
    headlineMedium: GoogleFonts.inter(
      fontSize: 28,
      color: AppPallete.darkColorOnSurface,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
    ),
    headlineSmall: GoogleFonts.inter(
      fontSize: 24,
      color: AppPallete.darkColorOnSurface,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
    ),
    titleLarge: GoogleFonts.roboto(
      fontSize: 22,
      color: AppPallete.darkColorOnSurface,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
    ),
    titleMedium: GoogleFonts.roboto(
      fontSize: 18,
      color: AppPallete.darkColorOnSurface,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
    ),
    titleSmall: GoogleFonts.roboto(
      fontSize: 16,
      color: AppPallete.darkColorOnSurface,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    bodyLarge: GoogleFonts.roboto(
      fontSize: 16,
      color: AppPallete.darkColorOnSurface,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.5,
    ),
    bodyMedium: GoogleFonts.roboto(
      fontSize: 14,
      color: AppPallete.darkColorOnSurface,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.25,
    ),
    bodySmall: GoogleFonts.roboto(
      fontSize: 12,
      color: AppPallete.darkColorOnSurface,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.4,
    ),
    labelLarge: GoogleFonts.roboto(
      fontSize: 14,
      color: AppPallete.darkColorOnSurface,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    labelMedium: GoogleFonts.roboto(
      fontSize: 12,
      color: AppPallete.darkColorOnSurface,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
    labelSmall: GoogleFonts.roboto(
      fontSize: 11,
      color: AppPallete.darkColorOnSurface,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
  );
}
