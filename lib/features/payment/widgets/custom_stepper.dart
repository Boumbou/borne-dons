/// custom_stepper.dart
///
/// A clean, Shadcn-style custom vertical stepper widget. It displays the current checkout phase
/// (Select Amount -> Processing -> Confirmed) with minimalist typography and clear circular nodes.
import 'package:flutter/material.dart';
import '../../../core/constants.dart';


class CustomStepper extends StatelessWidget {
  final int currentStep; // 1, 2, or 3
  final Color _color;

  const CustomStepper({
    Key? key,
    required this.currentStep,
    required this._color
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepItem(
          stepNumber: 1,
          label: 'Sélection',
          isActive: currentStep >= 1,
          isCompleted: currentStep > 1,
        ),
        _buildLine(isCompleted: currentStep > 1),
        _buildStepItem(
          stepNumber: 2,
          label: 'Paiement',
          isActive: currentStep >= 2,
          isCompleted: currentStep > 2,
        ),
        _buildLine(isCompleted: currentStep > 2),
        _buildStepItem(
          stepNumber: 3,
          label: 'Confirmation',
          isActive: currentStep >= 3,
          isCompleted: currentStep > 3,
        ),
      ],
    );
  }

  Widget _buildStepItem({
    required int stepNumber,
    required String label,
    required bool isActive,
    required bool isCompleted,
  }) {
    // Determine colors based on active/completed status
    final Color circleBgColor = isCompleted
        ? AppConstants.success
        : (isActive ? Color.lerp(_color,Colors.black,0.2)! : Colors.white);
    
    final Color circleBorderColor = isCompleted
        ? AppConstants.success
        : (isActive ? AppConstants.primary : AppConstants.border);

    final Color numberColor = isCompleted || isActive
        ? Colors.white
        : AppConstants.mutedForeground;

    final Color labelColor = isActive ? AppConstants.foreground : AppConstants.mutedForeground;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: circleBgColor,
            border: Border.all(color: circleBgColor, width: 1.5),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: isCompleted
              ? const Icon(Icons.check, size: 24, color: Colors.white)
              : Text(
                  '$stepNumber',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: numberColor,
                  ),
                ),
        ),
        const SizedBox(width: 8.0),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: labelColor,
          ),
        ),
      ],
    );
  }

  Widget _buildLine({required bool isCompleted}) {
    return Container(
      width: 40,
      height: 1.5,
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
      color: isCompleted ? AppConstants.success : AppConstants.border,
    );
  }
}
