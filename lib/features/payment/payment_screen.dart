/// payment_screen.dart
///
/// This is the primary checkout dashboard. It splits the widescreen layout into:
/// - A beautiful sticky backdrop top bar with branding, connection status, and config gear.
/// - A centered main section containing the basmalah placeholder, call to action text,
///   and checkout deck housing the AmountGrid quick checkout board.
/// - A sticky backdrop bottom bar containing the custom horizontal stepper.
/// It coordinates state transitions from Step 1 (Awaiting Amount) to Step 2 (Processing Card),
/// and Step 3 (Captured & Approved) with real-time logging.
import 'dart:async';
import 'dart:io';
import 'dart:ui'; // Required for ImageFilter (Backdrop blur)
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../services/storage_service.dart';
import '../../services/stripe_service.dart';
import '../setup/setup_screen.dart';
import 'widgets/amount_grid.dart';
import 'widgets/custom_stepper.dart';
import 'widgets/payment_dialog.dart';

class PaymentScreen extends StatefulWidget {
  final StorageService storageService;

  const PaymentScreen({
    Key? key,
    required this.storageService,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final StripeService _stripeService = StripeService();
  
  int _currentCheckoutStep = 1; // 1 = Select, 2 = Processing, 3 = Approved
  String? _logoFilePath;
  bool _isMockMode = false;
  bool _isTestMode = false;
  String _associationName = 'Votre nom d\'association';
  String _shortText = 'Soutenez notre association. Chaque contribution fait la différence.';

  @override
  void initState() {
    super.initState();
    _loadMerchantDetails();
  }

  /// Initialized the company logo path and mock status for local presentation.
  void _loadMerchantDetails() {
    setState(() {
      _logoFilePath = widget.storageService.getLogoPath();
      _isMockMode = widget.storageService.isMockMode();
      _isTestMode = widget.storageService.isTestMode();
      _associationName = widget.storageService.getAssociationName();
      _shortText = widget.storageService.getShortText();
    });
  }

  /// Executes the transaction pipeline:
  /// Creates the async future, opens the transaction modal, pushes updates to a log stream,
  /// updates step phases, and manages post-approval UI reset.
  Future<void> _initiateTerminalTransaction(double amount) async {
    // Transition UI to Step 2 (Processing)
    setState(() {
      _currentCheckoutStep = 2;
    });

    // We instantiate a stream controller to broadcast direct status changes
    // from StripeService straight into the dialog box console.
    final StreamController<String> statusStreamController = StreamController<String>();

    // Start the transaction future
    final Future<Map<String, dynamic>> transactionFuture = _stripeService.processPayment(
      amount: amount,
      storage: widget.storageService,
      onStatusUpdate: (message) {
        statusStreamController.add(message);
      },
    );

    // Launch Checkout Dialog Box
    final bool? wasCaptured = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Prevent backdrop tapping from breaking connection
      builder: (context) {
        return PaymentDialog(
          amount: amount,
          paymentFuture: transactionFuture,
          statusStream: statusStreamController.stream,
        );
      },
    );

    // Close the logging stream
    await statusStreamController.close();

    if (wasCaptured == true) {
      // Transition UI to Step 3 (Approved & Finalized)
      setState(() {
        _currentCheckoutStep = 3;
      });

      // Display approval message or let the success state persist briefly
      await Future.delayed(const Duration(seconds: 1));
    }

    // Reset workflow to Step 1 (Awaiting selection)
    if (mounted) {
      setState(() {
        _currentCheckoutStep = 1;
      });
    }
  }

  /// Reroutes to setup screen to update tokens or keys.
  void _navigateToSettings() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => SetupScreen(storageService: widget.storageService),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // --- Layer 1: Mandated repeating background pattern ---
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AppConstants.backgroundPattern),
                  repeat: ImageRepeat.repeat,
                ),
              ),
            ),
          ),

          // --- Layer 2: Main Scrollable Content ---
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    children: [
                      // Space for sticky top bar
                      const SizedBox(height: 94.0),

                      // --- Placeholder for basmalah.png ---
                      Image.asset(
                        'assets/basmalah.png',
                        height: 100,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          // Clean visual fallback when the image doesn't exist in assets yet
                          return Container(
                            height: 70,
                            width: 260,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(color: AppConstants.border.withOpacity(0.5), width: 1.0),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.image_outlined, color: AppConstants.mutedForeground, size: 20),
                                SizedBox(width: 8.0),
                                Text(
                                  'basmalah.png placeholder',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppConstants.mutedForeground,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16.0),

                      // --- Short Description Text below Image ---
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          _shortText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22.0,
                            height: 1.4,
                            color: AppConstants.mutedForeground,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28.0),

                      // --- Main Checkout Card containing presets ---
                      Card(
                        elevation: 0,
                        color: const Color.fromARGB(147, 255, 255, 255),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: AppConstants.border, width: 1.0),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: 
                            Padding(
                              padding: const EdgeInsets.all(28.0),
                              child: AmountGrid(
                                onAmountSelected: _initiateTerminalTransaction,
                              ),
                            ),
                      ),

                      // Space for sticky bottom stepper
                      const SizedBox(height: 104.0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // --- Layer 3: Sticky Top Bar with Backdrop Blur ---
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  height: 74.0,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(0),
                    border: const Border(
                      bottom: BorderSide(color: AppConstants.border, width: 1.0),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: SafeArea(
                    bottom: false,
                    child: Row(
                      children: [
                        // Logo / Branding Node
                        Container(
                          height: 38,
                          width: 38,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6.0),
                            border: Border.all(color: AppConstants.border, width: 1.0),
                          ),
                          child: _logoFilePath != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(6.0),
                                  child: Image.file(File(_logoFilePath!), fit: BoxFit.cover),
                                )
                              : const Icon(Icons.favorite_outline, color: AppConstants.primary, size: 20),
                        ),
                        const SizedBox(width: 12.0),

                        // Association Title / Subtitle
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _associationName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.3,
                                  color: AppConstants.foreground,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2.0),
                              Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: _isMockMode ? Colors.orange : AppConstants.success,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4.0),
                                  Text(
                                    _isMockMode ? 'MOCK SIMULATOR' : _isTestMode ? 'INTEGRATION TEST': 'READER CONNECTED',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.2,
                                      color: _isMockMode ? Colors.orange : AppConstants.success,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Config Cog Action Button
                        IconButton(
                          onPressed: _navigateToSettings,
                          icon: const Icon(Icons.settings_outlined, size: 18),
                          color: AppConstants.foreground,
                          tooltip: 'POS Settings',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // --- Layer 4: Sticky Bottom Stepper with Backdrop Blur ---
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  height: 120.0,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.01),
                    border: const Border(
                      top: BorderSide(color: AppConstants.border, width: 1.0),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: SafeArea(
                    top: false,
                    child: CustomStepper(currentStep: _currentCheckoutStep),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
