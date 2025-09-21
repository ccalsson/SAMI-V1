import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sami_app/services/voice_service.dart';
import 'package:sami_app/state/cart_provider.dart';

class VoiceChip extends StatefulWidget {
  const VoiceChip({super.key});

  @override
  State<VoiceChip> createState() => _VoiceChipState();
}

class _VoiceChipState extends State<VoiceChip> {
  bool _listening = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InputChip(
      avatar: Icon(_listening ? Icons.mic : Icons.mic_none,
          color: theme.colorScheme.onPrimaryContainer),
      backgroundColor: theme.colorScheme.primaryContainer,
      label: Text(
        _listening ? 'Escuchando...' : 'Hablar (voz)',
        style: theme.textTheme.bodyMedium,
      ),
      onPressed: _listening
          ? null
          : () async {
              setState(() => _listening = true);
              final voiceService = context.read<VoiceService>();
              final command = await voiceService.listenForCommand();
              if (!mounted) return;
              setState(() => _listening = false);
              if (command == null || command.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No se entendió la orden.')));
                return;
              }
              final action = await context
                  .read<CartProvider>()
                  .handleVoiceCommand(command);
              if (!mounted) return;
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(action)));
            },
    );
  }
}
