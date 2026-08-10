import 'package:flutter/material.dart';

Future<String?> showEditTextDialog(
  BuildContext context, {
  required String title,
  required String label,
  String initialValue = '',
  int maxLines = 1,
}) {
  final controller = TextEditingController(text: initialValue);
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(ctx, controller.text.trim());
          },
          style:
              FilledButton.styleFrom(backgroundColor: const Color(0xFF2C3E50)),
          child: const Text('Guardar'),
        ),
      ],
    ),
  );
}
