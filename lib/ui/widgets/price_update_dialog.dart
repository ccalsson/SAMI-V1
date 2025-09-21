import 'package:flutter/material.dart';

class PriceUpdateDialog extends StatefulWidget {
  const PriceUpdateDialog({required this.initialPrice, super.key});

  final double initialPrice;

  @override
  State<PriceUpdateDialog> createState() => _PriceUpdateDialogState();
}

class _PriceUpdateDialogState extends State<PriceUpdateDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: widget.initialPrice.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Actualizar precio'),
      content: TextField(
        controller: _controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(labelText: 'Precio por kg'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final value =
                double.tryParse(_controller.text.replaceAll(',', '.'));
            if (value == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Precio inválido')));
              return;
            }
            Navigator.pop(context, value);
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
