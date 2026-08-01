/// constants.dart
///
/// This file defines application-wide constants, including Stripe API endpoints,
/// default quick-select payment amounts, and visual constants such as theme colors
/// following a Shadcn-inspired minimalist color palette.
import 'package:flutter/material.dart';

class AppConstants {
  // --- Stripe API Endpoints ---
  static const String stripeBaseUrl = 'https://api.stripe.com/v1';
  static const String paymentIntentsEndpoint = '$stripeBaseUrl/payment_intents';
  
  // --- Sumup API Endpoints ---
  static const String sumupBaseUrl = 'https://api.sumup.com/v0.1/merchants';
  
  /// Formats the Stripe Terminal Reader process payment intent URL.
  static String processPaymentEndpoint(String readerId) => 
      '$stripeBaseUrl/terminal/readers/$readerId/process_payment_intent';
  
  /// Formats the Stripe Test Helper payment intent URL.
  static String simulateCardTap(String readerId) => 
      '$stripeBaseUrl/test_helpers/terminal/readers/$readerId/present_payment_method';

  /// Formats the Stripe Terminal Reader capture/retrieve URL for polling.
  static String readerEndpoint(String readerId) =>
      '$stripeBaseUrl/terminal/readers/$readerId';

  // --- Quick Select Amounts ---
  // Represented in dollars (will be converted to cents for Stripe API)
  static const List<double> quickAmounts = [10.0, 20.0, 30.0, 40.0, 50.0];

  // --- Shadcn-Style Slate Color Palette ---
  // Minimalist, high-contrast colors mirroring a professional slate-based theme.
  static const Color background = Color(0xFFFAFAFA); // slate-50
  static const Color foreground = Color(0xFF09090B); // slate-950
  
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardForeground = Color(0xFF09090B);
  
  static const Color border = Color(0xFFE4E4E7); // slate-200
  static const Color input = Color(0xFFE4E4E7);
  
  static const Color primary = Color(0xFF18181B); // slate-900
  static const Color primaryForeground = Color(0xFFFAFAFA); // slate-50
  
  static const Color secondary = Color(0xFFF4F4F5); // slate-100
  static const Color secondaryForeground = Color(0xFF18181B);
  
  static const Color muted = Color(0xFFF4F4F5);
  static const Color mutedForeground = Color(0xFF71717A); // slate-500
  
  static const Color accent = Color(0xFFF4F4F5);
  static const Color accentForeground = Color(0xFF18181B);

  static const Color success = Color(0xFF10B981); // emerald-500
  static const Color successForeground = Colors.white;

  static const Color error = Color(0xFFEF4444); // red-500
  
  // --- Asset Paths ---
  static const String backgroundPattern = 'assets/background-pattern.png';
}
