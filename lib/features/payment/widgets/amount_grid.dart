/// amount_grid.dart
///
/// A highly responsive grid of payment amount selectors designed for quick checkouts.
/// Includes preset amounts (5, 10, 20, 30, 50) and a "Custom" option. When "Custom" is active,
/// it smoothly expands an elegant inline numeric pad for precise entries.
import 'package:flutter/material.dart';
import '../../../core/constants.dart';

class AmountGrid extends StatefulWidget {
  final Function(double amount) onAmountSelected;
  final double buttonSize;

  const AmountGrid({
    Key? key,
    required this.buttonSize,
    required this.onAmountSelected,
  }) : super(key: key);

  @override
  State<AmountGrid> createState() => _AmountGridState();
}

class _AmountGridState extends State<AmountGrid> {
  bool _isCustomActive = false;
  String _customAmountString = '';

  void _handlePresetTap(double amount) {
    setState(() {
      _isCustomActive = false;
      _customAmountString = '';
    });
    widget.onAmountSelected(amount);
  }

  void _handleCustomActivate() {
    setState(() {
      _isCustomActive = true;
      _customAmountString = '';
    });
  }

  void _handleKeypadTap(String key) {
    setState(() {
      if (key == 'C') {
        _customAmountString = '';
      } else if (key == '⌫') {
        if (_customAmountString.isNotEmpty) {
          _customAmountString = _customAmountString.substring(0, _customAmountString.length - 1);
        }
      } else if (key == '.') {
        if (!_customAmountString.contains('.')) {
          _customAmountString += '.';
        }
      } else {
        // Prevent typing more than two decimal points
        if (_customAmountString.contains('.')) {
          final parts = _customAmountString.split('.');
          if (parts[1].length >= 2) return;
        }
        _customAmountString += key;
      }
    });
  }

  void _submitCustomAmount() {
    final double? amount = double.tryParse(_customAmountString);
    if (amount != null && amount > 0) {
      widget.onAmountSelected(amount);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width * 0.9 / 2;
    return Stack(
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Grid Layout for Preset Amounts ---
        if (!_isCustomActive) ...[
          GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 30.0,
            crossAxisSpacing: 30.0,
            childAspectRatio: 1.6,

          ),
          itemCount: AppConstants.quickAmounts.length + 1,
          itemBuilder: (context, index) {
            // Last element is always the Custom option
            if (index == AppConstants.quickAmounts.length) {
              return _buildAmountCard(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.credit_card_outlined,
                      color: _isCustomActive ? Colors.white : AppConstants.mutedForeground,
                      size: MediaQuery.of(context).size.width * 0.1, // 8% of screen width,
                    ),
                    const SizedBox(height: 4.0),
                    // const Text(
                    //   'SAISIE',
                    //   style: TextStyle(
                    //     fontSize: 10,
                    //     fontWeight: FontWeight.bold,
                    //     letterSpacing: 1.0,
                    //     color: AppConstants.mutedForeground,
                    //   ),
                    // ),
                    const SizedBox(height: 2.0),
                    Text(
                      'Autre Montant',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.04, // 8% of screen width,
                        fontWeight: FontWeight.bold,
                        color: _isCustomActive ? Colors.white : AppConstants.foreground,
                      ),
                    ),
                  ],
                ),
                isSelected: _isCustomActive,
                onTap: _handleCustomActivate,
              );
            }

            final double amount = AppConstants.quickAmounts[index];
            return _buildAmountCard(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // const Text(
                  //   'MONTANT',
                  //   style: TextStyle(
                  //     fontSize: 10,
                  //     fontWeight: FontWeight.bold,
                  //     letterSpacing: 1.0,
                  //     color: AppConstants.mutedForeground,
                  //   ),
                  // ),
                  const SizedBox(height: 10.0),
                  Text(
                    '${amount.toStringAsFixed(0)} €',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.1, // 8% of screen width
                      fontWeight: FontWeight.normal,
                      letterSpacing: -0.5,
                      color: AppConstants.foreground,
                    ),
                  )
                ],
              ),
              isSelected: false,
              onTap: () => _handlePresetTap(amount),
            );
          },
        ),
        ],
        // --- Animated Custom Keypad Drawer ---
        if (_isCustomActive) ...[
          const SizedBox(height: 30.0),
          Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: AppConstants.border, width: 1.0),
            ),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Display Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Autre montant',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.03, // 8% of screen width,
                        color: AppConstants.mutedForeground,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: MediaQuery.of(context).size.width * 0.06, color: AppConstants.mutedForeground),
                      onPressed: () {
                        setState(() {
                          _isCustomActive = false;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 50.0),
                
                // Ledger Display
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  decoration: BoxDecoration(
                    color: AppConstants.secondary,
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  alignment: Alignment.centerRight,
                  child: Text(
                    _customAmountString.isEmpty ? '0.00 €' : '$_customAmountString €',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: MediaQuery.of(context).size.width * 0.06, // 8% of screen width,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: AppConstants.foreground,
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),

                // Grid Numeric Layout
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Keys Grid
                    Expanded(
                      flex: 3,
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 8.0,
                          crossAxisSpacing: 8.0,
                          childAspectRatio: 1.4,
                        ),
                        itemCount: 12,
                        itemBuilder: (context, idx) {
                          final List<String> keys = [
                            '1', '2', '3',
                            '4', '5', '6',
                            '7', '8', '9',
                            '.', '0', '⌫'
                          ];
                          final String keyVal = keys[idx];
                          return _buildKeypadButton(keyVal);
                        },
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    // Action Buttons Column
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          _buildActionButton(
                            label: 'Annuler',
                            color: Colors.red.shade50,
                            textColor: Colors.red.shade700,
                            onTap: () => _handleKeypadTap('C'),
                            height: MediaQuery.of(context).size.width * 0.2, // 8% of screen width,
                          ),
                         SizedBox(height: 10.0),
                          _buildActionButton(
                            label: 'Valider',
                            color: AppConstants.primary,
                            textColor: AppConstants.primaryForeground,
                            onTap: _submitCustomAmount,
                            height: MediaQuery.of(context).size.width * 0.2, // 8% of screen width,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAmountCard({
    required Widget child,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppConstants.primary : Colors.white,
          border: Border.all(
            color: isSelected ? AppConstants.primary : AppConstants.border,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  Widget _buildKeypadButton(String label) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleKeypadTap(label),
        borderRadius: BorderRadius.circular(6.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6.0),
            border: Border.all(color: AppConstants.border, width: 1.0),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.06, // 8% of screen width,
              fontWeight: FontWeight.w600,
              color: AppConstants.foreground,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
    required double height,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(6.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6.0),
        child: Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.0),
            border: Border.all(
              color: color == AppConstants.primary ? Colors.transparent : AppConstants.border,
              width: 1.0,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.02, // 8% of screen width,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
