/// payment_dialog.dart
///
/// A highly polished checkout dialog that communicates directly with the reader.
/// It uses a stream of logs/messages to show the user and merchant the reader handshake status.
/// It includes visual indicators (using elegant CustomPainters for loading pulses and green approvals)
/// with a structural option to swap in Lottie JSON assets for production.
import 'package:flutter/material.dart';
import '../../../core/constants.dart';

class PaymentDialog extends StatefulWidget {
  final double amount;
  final Future<Map<String, dynamic>> paymentFuture;
  final Stream<String> statusStream;

  const PaymentDialog({
    Key? key,
    required this.amount,
    required this.paymentFuture,
    required this.statusStream,
  }) : super(key: key);

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _checkController;
  
  String _latestStatus = 'Initialisation du terminal...';
  bool _isSuccess = false;
  bool _isError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    
    // Pulse animation controller for the loading state
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Scale/Draw animation controller for the success checkmark
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Subscribe to status updates from the Stripe API
    widget.statusStream.listen((status) {
      if (mounted) {
        setState(() {
          _latestStatus = status;
        });
      }
    });

    // Handle transaction completion
    widget.paymentFuture.then((result) {
      if (!mounted) return;
      if (result['success'] == true) {
        setState(() {
          _isSuccess = true;
        });
        _pulseController.stop();
        _checkController.forward();
        // Delay and auto-dismiss on success
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pop(true); // Return success
          }
        });
      } else {
        setState(() {
          _isError = true;
          _errorMessage = result['error'] ?? 'Une erreur s\'est produite.';
        });
        _pulseController.stop();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- Visual Status Indicator ---
              SizedBox(
                height: 120,
                width: 120,
                child: Center(
                  child: _buildVisualState(),
                ),
              ),
              const SizedBox(height: 24.0),

              // --- Charge Details ---
              Text(
                _isSuccess ? 'Paiement approuvé' : (_isError ? 'Paiement refusé' : 'Terminal Charge'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: AppConstants.foreground,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                '${widget.amount.toStringAsFixed(2)} EUR',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppConstants.foreground,
                ),
              ),
              const SizedBox(height: 20.0),

              // --- Logs Console / Status Messages ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: AppConstants.secondary,
                  borderRadius: BorderRadius.circular(6.0),
                  border: Border.all(color: AppConstants.border, width: 1.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TERMINAL LOG',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: AppConstants.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      _isError ? _errorMessage : _latestStatus,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: _isError ? AppConstants.error : AppConstants.foreground,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
              
              if (_isError) ...[
                const SizedBox(height: 24.0),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppConstants.border),
                    ),
                    child: const Text('Annulation & Clôture'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the visual representation for the current transaction status.
  Widget _buildVisualState() {
    if (_isSuccess) {
      // Scale-in Checkmark circle
      return ScaleTransition(
        scale: CurvedAnimation(parent: _checkController, curve: Curves.elasticOut),
        child: Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: AppConstants.success,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check,
            color: Colors.white,
            size: 44,
          ),
        ),
      );
    }

    if (_isError) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppConstants.error.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.error_outline,
          color: AppConstants.error,
          size: 44,
        ),
      );
    }

    // Processing Pulsing Circle (Minimalist loading indicator)
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 60 + (30 * _pulseController.value),
              height: 60 + (30 * _pulseController.value),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppConstants.primary.withOpacity(0.15 * (1.0 - _pulseController.value)),
              ),
            ),
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: AppConstants.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.contactless_outlined,
                color: Colors.white,
                size: 28,
              ),
            ),
          ],
        );
      },
    );
  }
}
