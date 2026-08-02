import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

/// Shows a color picker dialog and returns the selected Color.
/// Returns null if the user cancels or dismisses the dialog.
Future<Color?> showColorPickerDialog({
  required BuildContext context,
  required Color initialColor,
}) {
  Color pickerColor = initialColor;

  return showDialog<Color>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Sélectionnez une couleur'),
        content: SingleChildScrollView(
          // StatefulBuilder is required here so the dialog can update 
          // its own state as you slide the color picker.
          child: StatefulBuilder(
            builder: (context, setState) {
              return ColorPicker(
                pickerColor: pickerColor,
                onColorChanged: (Color color) {
                  setState(() => pickerColor = color);
                },
                pickerAreaHeightPercent: 0.8,
              );
            },
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Annuler'),
            onPressed: () {
              // Pop with null to indicate cancellation
              Navigator.of(context).pop(null);
            },
          ),
          TextButton(
            child: const Text('Enregistrer'),
            onPressed: () {
              // Pop with the new color
              Navigator.of(context).pop(pickerColor);
            },
          ),
        ],
      );
    },
  );
}