import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';
import '../models/meditation_models.dart';
import '../services/meditation_repository.dart';
import '../services/monitoring_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MeditationViewModel extends ChangeNotifier {
  final MeditationRepository _repository;
  final MonitoringService _monitoringService;
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<MeditationSession> _sessions = [];
  List<MeditationSession> get sessions => List.unmodifiable(_sessions);
  MeditationSession? _currentSession;
  bool _isPlaying = false;
  double _currentProgress = 0.0;
  MeditationCategory? _selectedCategory;
  bool _audioInitialized = false;
  bool _isPremiumUser = false;

  MeditationSession? get currentSession => _currentSession;
  bool get isPlaying => _isPlaying;
  double get currentProgress => _currentProgress;
  MeditationCategory? get selectedCategory => _selectedCategory;
  bool get audioInitialized => _audioInitialized;
  bool get isWeb => kIsWeb;
  bool get isPremiumUser => _isPremiumUser;

  MeditationViewModel(this._repository, this._monitoringService) {
    _loadSessions();
    _setupAudioListener();
  }

  Future<void> _loadSessions() async {
    try {
      _sessions = await _repository.getAllSessions();
      
      // Optimización para web: precarga metadatos pero no audio
      if (kIsWeb) {
        for (var session in _sessions) {
          _preloadImageForWeb(session.imageUrl);
        }
      }
      
      notifyListeners();
    } catch (e) {
      log('Error cargando sesiones: $e');
    }
  }

  // Precarga imágenes para mejorar la experiencia en web
  void _preloadImageForWeb(String imageUrl) {
    if (kIsWeb) {
      final image = NetworkImage(imageUrl);
      precacheImage(image, null);
    }
  }

  void selectCategory(MeditationCategory? category) async {
    _selectedCategory = category;
    
    if (category != null) {
      try {
        _sessions = await _repository.getSessionsByCategory(category);
      } catch (e) {
        log('Error filtrando por categoría: $e');
      }
    } else {
      await _loadSessions();
    }
    
    notifyListeners();
  }

  Future<void> playSession(String sessionId) async {
    final session = _sessions.firstWhere((s) => s.id == sessionId);
    _currentSession = session;
    
    try {
      // Manejo especial para web
      if (kIsWeb) {
        // Inicializar audio solo cuando el usuario interactúa explícitamente
        await _audioPlayer.setUrl(session.audioUrl);
        _audioInitialized = true;
        
        // En web, esperamos a que el usuario presione play explícitamente
        // para cumplir con las políticas de autoplay
        _isPlaying = false;
      } else {
        await _audioPlayer.setUrl(session.audioUrl);
        await _audioPlayer.play();
        _isPlaying = true;
      }
      
      _monitoringService.logEvent('meditation_session_started', {
        'session_id': sessionId,
        'session_title': session.title,
        'session_category': session.category.toString(),
        'platform': kIsWeb ? 'web' : 'mobile',
      });
      
      notifyListeners();
    } catch (e) {
      log('Error reproduciendo sesión: $e');
    }
  }

  Future<void> resumeSession() async {
    try {
      await _audioPlayer.play();
      _isPlaying = true;
      notifyListeners();
    } catch (e) {
      log('Error al reanudar sesión: $e');
      // Manejo específico para errores web
      if (kIsWeb) {
        _showWebAudioError();
      }
    }
  }

  void pauseSession() {
    _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> stopSession() async {
    if (_currentSession != null) {
      _monitoringService.logEvent('meditation_session_completed', {
        'session_id': _currentSession!.id,
        'session_title': _currentSession!.title,
        'session_duration': _currentProgress * _currentSession!.duration,
        'platform': kIsWeb ? 'web' : 'mobile',
      });
    }
    
    await _audioPlayer.stop();
    _currentSession = null;
    _isPlaying = false;
    _currentProgress = 0.0;
    _audioInitialized = false;
    notifyListeners();
  }

  void _setupAudioListener() {
    _audioPlayer.positionStream.listen((position) {
      if (_currentSession != null) {
        _currentProgress = position.inSeconds / _currentSession!.duration;
        
        if (_currentProgress >= 0.99) {
          stopSession();
        }
        
        notifyListeners();
      }
    });

    // Manejo de errores específico para web
    if (kIsWeb) {
      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          stopSession();
        }
      });
    }
  }

  void _showWebAudioError() {
    // Esta función sería implementada en la UI para mostrar un mensaje
    // informando al usuario sobre problemas de reproducción en web
    log('Error de reproducción en navegador web');
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> checkSubscriptionStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final subscriptions = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('subscriptions')
          .where('isActive', isEqualTo: true)
          .where('endDate', isGreaterThan: DateTime.now().toIso8601String())
          .get();

      _isPremiumUser = subscriptions.docs.isNotEmpty;
      notifyListeners();
    }
  }

  Future<List<MeditationSession>> getAllSessions() async {
    final sessions = await _repository.getAllSessions();
    if (!_isPremiumUser) {
      return sessions.where((session) => !session.isPremium).toList();
    }
    return sessions;
  }
}
 