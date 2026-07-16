/// setup_screen.dart
///
/// This screen collects the initial terminal configurations, including:
/// 1. Interactive Company Logo Upload using the image_picker package.
/// 2. Stripe Secret Key.
/// 3. Stripe Terminal ID.
/// 4. Sandbox/Simulator Toggle to test the client offline or in demo environments.
/// All configurations are saved securely via StorageService, and the user is routed
/// to the checkout dashboard.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants.dart';
import '../../services/storage_service.dart';
import '../payment/payment_screen.dart';

class SetupScreen extends StatefulWidget {
  final StorageService storageService;

  const SetupScreen({
    Key? key,
    required this.storageService,
  }) : super(key: key);

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _secretKeyController = TextEditingController();
  final _terminalIdController = TextEditingController();
  final _associationNameController = TextEditingController();
  final _shortTextController = TextEditingController();
  
  File? _logoFile;
  bool _isMockMode = false;
  bool _isTestMode = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingConfigurations();
  }

  /// Prefills any existing settings if we are modifying credentials.
  Future<void> _loadExistingConfigurations() async {
    final secret = await widget.storageService.getStripeSecretKey();
    final terminal = await widget.storageService.getTerminalId();
    final logoPath = widget.storageService.getLogoPath();
    final isMock = widget.storageService.isMockMode();
    final isTest = widget.storageService.isTestMode();
    final associationName = widget.storageService.getAssociationName();
    final shortText = widget.storageService.getShortText();

    setState(() {
      _secretKeyController.text = secret ?? '';
      _terminalIdController.text = terminal ?? '';
      _associationNameController.text = associationName;
      _shortTextController.text = shortText;
      _isMockMode = isMock;
      _isTestMode = isTest;
      if (logoPath != null && logoPath.isNotEmpty) {
        _logoFile = File(logoPath);
      }
    });
  }

  /// Triggers the device's file picker or gallery to choose a brand logo.
  Future<void> _pickLogo() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 400,
        maxHeight: 400,
      );
      if (image != null) {
        setState(() {
          _logoFile = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to select image: $e')),
      );
    }
  }

  /// Persists credentials and transitions state safely.
  Future<void> _handleSubmit() async {
    // If mock mode is selected, we bypass strict field validation
    if (!_isMockMode && !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Process Logo saving if provided
      if (_logoFile != null) {
        await widget.storageService.saveLogo(_logoFile!);
      } else {
        await widget.storageService.clearLogo();
      }

      // 2. Save Mock Mode
      await widget.storageService.setMockMode(_isMockMode);
      // 2. Save Mock Mode
      await widget.storageService.setTestMode(_isTestMode);

      // Save custom association fields
      await widget.storageService.setAssociationName(_associationNameController.text.trim());
      await widget.storageService.setShortText(_shortTextController.text.trim());

      // 3. Save Stripe Keys
      if (!_isMockMode) {
        await widget.storageService.setStripeSecretKey(_secretKeyController.text.trim());
        await widget.storageService.setTerminalId(_terminalIdController.text.trim());
      } else {
        // Clear old production credentials in mock state
        await widget.storageService.setStripeSecretKey('');
        await widget.storageService.setTerminalId('');
      }

      // 4. Success Transition
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PaymentScreen(storageService: widget.storageService),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppConstants.error,
            content: Text('Impossible d\'enregistrer les paramètres: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _secretKeyController.dispose();
    _terminalIdController.dispose();
    _associationNameController.dispose();
    _shortTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Repeating background pattern as mandated by design specifications
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppConstants.backgroundPattern),
            repeat: ImageRepeat.repeat,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Header Block ---
                        const Text(
                          'Configurez votre borne de paiement',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.8,
                            color: AppConstants.foreground,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        const Text(
                          'Saisissez les information de votre compte et de votre terminal Stripe pour commencer.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppConstants.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: 32.0),

                        // --- Image/Logo Picker Section ---
                        const Text(
                          'Logo',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppConstants.foreground),
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          children: [
                            Container(
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(
                                color: AppConstants.secondary,
                                border: Border.all(color: AppConstants.border, width: 1.0),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: _logoFile != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.file(_logoFile!, fit: BoxFit.cover),
                                    )
                                  : const Icon(
                                      Icons.business,
                                      color: AppConstants.mutedForeground,
                                      size: 32,
                                    ),
                            ),
                            const SizedBox(width: 16.0),
                            OutlinedButton.icon(
                              onPressed: _pickLogo,
                              icon: const Icon(Icons.add_photo_alternate_outlined, size: 16),
                              label: const Text('Choisissez votre logo'),
                            ),
                            if (_logoFile != null) ...[
                              const SizedBox(width: 8.0),
                              TextButton(
                                onPressed: () => setState(() => _logoFile = null),
                                child: const Text('Clear', style: TextStyle(color: Colors.red)),
                              ),
                            ]
                          ],
                        ),
                        const SizedBox(height: 24.0),

                        // --- Association Customization Fields ---
                        const Text(
                          'Nom de l\'association / Établissement',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppConstants.foreground),
                        ),
                        const SizedBox(height: 8.0),
                        TextFormField(
                          controller: _associationNameController,
                          decoration: const InputDecoration(
                            hintText: 'Ex: Association Al-Salam',
                            prefixIcon: Icon(Icons.favorite_outline, size: 16),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter the association name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20.0),

                        const Text(
                          'Texte d\'appel aux dons (court)',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppConstants.foreground),
                        ),
                        const SizedBox(height: 8.0),
                        TextFormField(
                          controller: _shortTextController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            hintText: 'Ex: Soutenez nos actions. Chaque don compte.',
                            prefixIcon: Icon(Icons.description_outlined, size: 16),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Saisissez votre texte d\'appel aux dons';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24.0),

                        // --- Sandbox Simulation Toggle ---
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          decoration: BoxDecoration(
                            color: AppConstants.secondary,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: AppConstants.border, width: 1.0),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Mock Reader / Sandbox',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Simule les paiements sans accès au réseau.',
                                      style: TextStyle(fontSize: 11, color: AppConstants.mutedForeground),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _isMockMode,
                                activeColor: AppConstants.primary,
                                onChanged: (value) {
                                  setState(() {
                                    _isMockMode = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24.0),


                        // --- Integration test Toggle ---
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 101, 232, 188),
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: AppConstants.border, width: 1.0),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Mode test',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppConstants.accentForeground),
                                    ),
                                    Text(
                                      'Teste votre integration avec un terminal de test.',
                                      style: TextStyle(fontSize: 11, color: AppConstants.accentForeground),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _isTestMode,
                                activeColor: AppConstants.secondary,
                                onChanged: (value) {
                                  setState(() {
                                    _isTestMode = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24.0),

                        // --- Dynamic Form Fields ---
                        if (!_isMockMode) ...[
                          // Stripe Secret Key
                          const Text(
                            'Stripe Secret API Key',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppConstants.foreground),
                          ),
                          const SizedBox(height: 8.0),
                          TextFormField(
                            controller: _secretKeyController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              hintText: 'sk_...',
                              prefixIcon: Icon(Icons.vpn_key_outlined, size: 16),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Saisissez votre clé Stripe';
                              }
                              if (!value.startsWith('sk_')) {
                                return 'Saisissez une clé valide qui commence par sk_';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20.0),

                          // Stripe Terminal ID
                          const Text(
                            'Stripe Terminal Reader ID',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppConstants.foreground),
                          ),
                          const SizedBox(height: 8.0),
                          TextFormField(
                            controller: _terminalIdController,
                            decoration: const InputDecoration(
                              hintText: 'tmr_...',
                              prefixIcon: Icon(Icons.chrome_reader_mode_outlined, size: 16),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Saisissez l\id de votre terminal Stripe';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32.0),
                        ] else ...[
                          const SizedBox(height: 16.0),
                        ],

                        // --- Submit Action Button ---
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSubmit,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text('Initialiser la borne'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
