/// storage_service.dart
///
/// This service handles all local persistence operations. It utilizes:
/// - flutter_secure_storage for storing credentials (Stripe Secret API Key and Terminal ID) safely.
/// - shared_preferences for non-sensitive configurations (like the stored logo path).
/// - path_provider & dart:io to copy and persist the custom logo file locally.
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class StorageService {
  // --- Secure Storage Keys ---
  static const String _keyStripeSecret = 'stripe_secret_key';
  static const String _keyTerminalId = 'stripe_terminal_id';
  
  // --- Shared Preferences Keys ---
  static const String _keyLogoPath = 'company_logo_path';
  static const String _keyBrandColor = 'brand_color';
  static const String _keyIsMockMode = 'pos_is_mock_mode';
  static const String _keyIsTestMode = 'pos_is_test_mode';
  static const String _keyAssociationName = 'association_name';
  static const String _keyShortText = 'short_text';

  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;

  StorageService({
    required FlutterSecureStorage secureStorage,
    required SharedPreferences prefs,
  })  : _secureStorage = secureStorage,
        _prefs = prefs;

  /// Factory initializer to resolve dependencies asynchronously before application startup.
  static Future<StorageService> initialize() async {
    const secureStorage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
    final prefs = await SharedPreferences.getInstance();
    return StorageService(secureStorage: secureStorage, prefs: prefs);
  }

  // --- Stripe Credentials Handling ---

  /// Reads the stored Stripe Secret Key securely.
  Future<String?> getStripeSecretKey() async {
    return await _secureStorage.read(key: _keyStripeSecret);
  }

  /// Writes the Stripe Secret Key securely.
  Future<void> setStripeSecretKey(String secretKey) async {
    await _secureStorage.write(key: _keyStripeSecret, value: secretKey);
  }

  /// Reads the stored Stripe Terminal Reader ID securely.
  Future<String?> getTerminalId() async {
    return await _secureStorage.read(key: _keyTerminalId);
  }

  /// Writes the Stripe Terminal Reader ID securely.
  Future<void> setTerminalId(String terminalId) async {
    await _secureStorage.write(key: _keyTerminalId, value: terminalId);
  }

  // --- Brand Color operations ---
  int? getBrandColor(){
    return _prefs.getInt(_keyBrandColor);
  }

  Future<bool> setBrandColor(int colorValue){
    return _prefs.setInt(_keyBrandColor, colorValue);
  }

  // --- Company Logo Operations ---

  /// Reads the saved company logo local file path.
  String? getLogoPath() {
    return _prefs.getString(_keyLogoPath);
  }

  /// Saves a custom selected logo image into the app's local documents directory.
  /// This ensures the image is persisted on disk and won't be deleted as cache.
  Future<String> saveLogo(File sourceFile) async {
    try {
      final Directory docDir = await getApplicationDocumentsDirectory();
      final String fileExtension = p.extension(sourceFile.path);
      final String newFileName = 'company_logo_${DateTime.now().millisecondsSinceEpoch}$fileExtension';
      final String destinationPath = p.join(docDir.path, newFileName);
      
      // Copy source file to permanent storage
      final File savedFile = await sourceFile.copy(destinationPath);
      
      // Save path to preferences
      await _prefs.setString(_keyLogoPath, savedFile.path);
      return savedFile.path;
    } catch (e) {
      throw Exception('Failed to save company logo locally: $e');
    }
  }

  /// Clears the saved logo path from memory.
  Future<void> clearLogo() async {
    await _prefs.remove(_keyLogoPath);
  }

  // --- Mock Mode Configuration ---

  /// Check if the POS is running in "Mock Reader / Sandbox" mode for demo purposes.
  bool isMockMode() {
    return _prefs.getBool(_keyIsMockMode) ?? false;
  }
  /// Check if the POS is running in "Integration test" mode for demo purposes.
  bool isTestMode() {
    return _prefs.getBool(_keyIsTestMode) ?? false;
  }

  /// Toggles mock reader simulation mode.
  Future<void> setMockMode(bool enabled) async {
    await _prefs.setBool(_keyIsMockMode, enabled);
  }
  /// Toggles test integration  mode.
  Future<void> setTestMode(bool enabled) async {
    await _prefs.setBool(_keyIsTestMode, enabled);
  }

  // --- Association & Short Text Configuration ---

  /// Gets the stored Association Name, defaulting to "Association Al-Karam".
  String getAssociationName() {
    return _prefs.getString(_keyAssociationName) ?? 'Votre association';
  }

  /// Sets the stored Association Name.
  Future<void> setAssociationName(String value) async {
    await _prefs.setString(_keyAssociationName, value);
  }

  /// Gets the stored short text for calls to action, with default.
  String getShortText() {
    return _prefs.getString(_keyShortText) ?? 
        'Soutenez notre association. Chaque contribution fait la différence.';
  }

  /// Sets the stored short text for calls to action.
  Future<void> setShortText(String value) async {
    await _prefs.setString(_keyShortText, value);
  }

  // --- Configuration Checks ---

  /// Determines if the application has been fully configured.
  /// If Stripe Secret and Terminal Reader ID exist (or if Mock Mode is enabled), returns true.
  Future<bool> isConfigured() async {
    if (isMockMode()) {
      return true;
    }
    final secret = await getStripeSecretKey();
    final terminal = await getTerminalId();
    return secret != null && secret.isNotEmpty && terminal != null && terminal.isNotEmpty;
  }

  /// Clears all local configurations to support re-entering setup details.
  Future<void> resetAll() async {
    await _secureStorage.delete(key: _keyStripeSecret);
    await _secureStorage.delete(key: _keyTerminalId);
    await _prefs.remove(_keyLogoPath);
    await _prefs.remove(_keyIsMockMode);
    await _prefs.remove(_keyAssociationName);
    await _prefs.remove(_keyShortText);
  }
}
