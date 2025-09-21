import 'package:firebase_auth/firebase_auth.dart';
import './firebase_service.dart';
import '../models/meditation_models.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MeditationRepository {
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String baseUrl;
  
  MeditationRepository({required this.baseUrl});
  
  Future<List<MeditationSession>> getAllSessions() async {
    return await _firebaseService.getAllSessions();
  }
  
  Future<List<MeditationSession>> getSessionsByCategory(MeditationCategory category) async {
    return await _firebaseService.getSessionsByCategory(category);
  }
  
  Future<void> saveMeditationProgress(String sessionId, int duration) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firebaseService.saveMeditationHistory(
        userId: user.uid,
        sessionId: sessionId,
        duration: duration,
        completedAt: DateTime.now(),
      );
    }
  }
  
  MeditationSession _parseSession(Map<String, dynamic> json) {
    return MeditationSession(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      duration: json['duration'],
      category: MeditationCategory.values.firstWhere(
        (c) => c.toString().split('.').last == json['category']
      ),
      audioUrl: json['audioUrl'],
      imageUrl: json['imageUrl'],
      isPremium: json['isPremium'] ?? false,
    );
  }
  
  // Datos de ejemplo para desarrollo
  List<MeditationSession> _getMockSessions() {
    return [
      MeditationSession(
        id: '1',
        title: 'Meditación para dormir',
        description: 'Una meditación guiada para ayudarte a conciliar el sueño profundo',
        duration: 600, // 10 minutos
        category: MeditationCategory.sleep,
        audioUrl: 'https://example.com/sleep-meditation.mp3',
        imageUrl: 'https://images.unsplash.com/photo-1508672019048-805c876b67e2',
        isPremium: false,
      ),
      MeditationSession(
        id: '2',
        title: 'Reducción de ansiedad',
        description: 'Técnicas de respiración y visualización para reducir la ansiedad',
        duration: 480, // 8 minutos
        category: MeditationCategory.anxiety,
        audioUrl: 'https://example.com/anxiety-meditation.mp3',
        imageUrl: 'https://images.unsplash.com/photo-1506126613408-eca07ce68773',
        isPremium: false,
      ),
      MeditationSession(
        id: '3',
        title: 'Meditación de atención plena',
        description: 'Aprende a estar presente y consciente en el momento actual',
        duration: 720, // 12 minutos
        category: MeditationCategory.mindfulness,
        audioUrl: 'https://example.com/mindfulness-meditation.mp3',
        imageUrl: 'https://images.unsplash.com/photo-1518241353330-0f7941c2d9b5',
        isPremium: true,
      ),
      MeditationSession(
        id: '4',
        title: 'Concentración profunda',
        description: 'Mejora tu capacidad de concentración y enfoque',
        duration: 540, // 9 minutos
        category: MeditationCategory.focus,
        audioUrl: 'https://example.com/focus-meditation.mp3',
        imageUrl: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61',
        isPremium: true,
      ),
      MeditationSession(
        id: '5',
        title: 'Alivio del estrés',
        description: 'Libera tensiones y reduce el estrés acumulado',
        duration: 660, // 11 minutos
        category: MeditationCategory.stress,
        audioUrl: 'https://example.com/stress-meditation.mp3',
        imageUrl: 'https://images.unsplash.com/photo-1528715471579-d1bcf0ba5e83',
        isPremium: false,
      ),
      MeditationSession(
        id: '6',
        title: 'Meditación para principiantes',
        description: 'Introducción a la meditación para quienes comienzan',
        duration: 300, // 5 minutos
        category: MeditationCategory.beginner,
        audioUrl: 'https://example.com/beginner-meditation.mp3',
        imageUrl: 'https://images.unsplash.com/photo-1470116945706-e6bf5d5a53ca',
        isPremium: false,
      ),
    ];
  }
} 