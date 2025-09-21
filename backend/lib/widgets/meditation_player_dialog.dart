import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/meditation_models.dart';
import '../viewmodels/meditation_viewmodel.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class MeditationPlayerDialog extends StatelessWidget {
  final MeditationSession session;
  final VoidCallback onDismiss;

  const MeditationPlayerDialog({
    Key? key,
    required this.session,
    required this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MeditationViewModel>(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Título y botón de cerrar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  session.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onDismiss,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Imagen
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                session.imageUrl,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Mensaje específico para web
            if (kIsWeb && !viewModel.isPlaying && !viewModel.audioInitialized)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Haz clic en reproducir para iniciar la meditación',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            
            // Barra de progreso
            LinearProgressIndicator(
              value: viewModel.currentProgress,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Tiempo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration((session.duration * viewModel.currentProgress).toInt()),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  _formatDuration(session.duration),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Botón de reproducción/pausa
            IconButton(
              iconSize: 48,
              icon: Icon(
                viewModel.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
              onPressed: () {
                if (viewModel.isPlaying) {
                  viewModel.pauseSession();
                } else {
                  viewModel.resumeSession();
                }
              },
            ),
            
            // Mensaje de advertencia para web
            if (kIsWeb)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  'Nota: Mantén esta pestaña abierta para continuar la reproducción',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int durationInSeconds) {
    final minutes = durationInSeconds ~/ 60;
    final seconds = durationInSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
} 