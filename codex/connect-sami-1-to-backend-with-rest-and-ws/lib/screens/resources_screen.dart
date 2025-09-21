import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/audio_resource.dart';
import '../services/resource_service.dart';

class ResourcesScreen extends StatelessWidget {
  final ResourceService _resourceService = ResourceService();

  ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recursos de Audio'),
      ),
      body: FutureBuilder<List<AudioResource>>(
        future: _resourceService.getAvailableResources(
          FirebaseAuth.instance.currentUser!.uid
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final resources = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: resources.length,
            itemBuilder: (context, index) {
              final resource = resources[index];
              return _ResourceCard(resource: resource);
            },
          );
        },
      ),
    );
  }
}

class _ResourceCard extends StatelessWidget {
  final AudioResource resource;

  const _ResourceCard({
    super.key,
    required this.resource,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Image.network(
              resource.thumbnailUrl ?? 'assets/images/default_audio.png',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resource.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${resource.duration ~/ 60} min',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                // Implementar reproducción
              },
              child: const Text('Reproducir'),
            ),
          ),
        ],
      ),
    );
  }
} 