import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/meditation_models.dart';
import '../viewmodels/meditation_viewmodel.dart';
import '../widgets/meditation_session_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/meditation_player_dialog.dart';

class MeditationScreen extends StatelessWidget {
  final Function onNavigateBack;

  const MeditationScreen({Key? key, required this.onNavigateBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MeditationViewModel>(context);
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // App Bar
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => onNavigateBack(),
                  ),
                  const Text(
                    'Meditación',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              
              // Categorías
              SizedBox(
                height: 60,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    CategoryChip(
                      category: null,
                      isSelected: viewModel.selectedCategory == null,
                      onTap: () => viewModel.selectCategory(null),
                    ),
                    ...MeditationCategory.values.map((category) => 
                      CategoryChip(
                        category: category,
                        isSelected: viewModel.selectedCategory == category,
                        onTap: () => viewModel.selectCategory(category),
                      )
                    ).toList(),
                  ],
                ),
              ),
              
              // Lista de sesiones
              Expanded(
                child: ListView.builder(
                  itemCount: viewModel.sessions.length,
                  itemBuilder: (context, index) {
                    final session = viewModel.sessions[index];
                    return MeditationSessionCard(
                      session: session,
                      onTap: () => viewModel.playSession(session.id),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 