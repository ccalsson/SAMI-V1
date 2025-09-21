import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sami_app/domain/entities/tool.dart';
import 'package:sami_app/features/tools/presentation/providers/tools_provider.dart';

class ToolsView extends StatelessWidget {
  const ToolsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ToolsProvider>(
      builder: (context, provider, _) {
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                labelText: 'Buscar herramienta',
              ),
              onChanged: provider.updateSearch,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              children: [
                FilterChip(
                  label: const Text('Disponibles'),
                  selected: provider.statusFilter == ToolStatus.available,
                  onSelected: (value) =>
                      provider.setStatus(value ? ToolStatus.available : null),
                ),
                FilterChip(
                  label: const Text('En uso'),
                  selected: provider.statusFilter == ToolStatus.inUse,
                  onSelected: (value) =>
                      provider.setStatus(value ? ToolStatus.inUse : null),
                ),
                FilterChip(
                  label: const Text('Faltantes'),
                  selected: provider.statusFilter == ToolStatus.missing,
                  onSelected: (value) =>
                      provider.setStatus(value ? ToolStatus.missing : null),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (provider.tools.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                    child: Text('No hay herramientas con esos filtros.')),
              )
            else
              ...provider.tools.map((tool) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.build),
                    title: Text(tool.name),
                    subtitle: Text(tool.category),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_statusLabel(tool.status)),
                        if (tool.currentHolder != null)
                          Text('Asignada a ${tool.currentHolder}'),
                      ],
                    ),
                  ),
                );
              }),
          ],
        );
      },
    );
  }

  String _statusLabel(ToolStatus status) {
    switch (status) {
      case ToolStatus.available:
        return 'Disponible';
      case ToolStatus.inUse:
        return 'En uso';
      case ToolStatus.missing:
        return 'Faltante';
    }
  }
}
