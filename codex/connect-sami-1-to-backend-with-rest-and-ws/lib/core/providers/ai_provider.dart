import 'package:flutter/foundation.dart';

enum AiProfile {
  bienestar,
  tdaTdh,
  estudiantil,
  desarrolloProfesional,
  preConsulta,
  postConsulta,
}

class AiProvider extends ChangeNotifier {
  AiProfile _currentProfile = AiProfile.bienestar;
  List<String> _conversationHistory = [];
  bool _isLoading = false;
  String? _lastError;

  AiProfile get currentProfile => _currentProfile;
  List<String> get conversationHistory => _conversationHistory;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  void setProfile(AiProfile profile) {
    _currentProfile = profile;
    notifyListeners();
  }

  void addToConversation(String message) {
    _conversationHistory.add(message);
    if (_conversationHistory.length > 10) {
      _conversationHistory.removeAt(0);
    }
    notifyListeners();
  }

  void clearConversation() {
    _conversationHistory.clear();
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _lastError = error;
    notifyListeners();
  }

  // Obtener contexto de conversación para IA
  String getConversationContext() {
    if (_conversationHistory.isEmpty) return '';
    final lastMessages = _conversationHistory.length > 5
        ? _conversationHistory.sublist(_conversationHistory.length - 5)
        : _conversationHistory;
    return lastMessages.join('\n');
  }

  // Verificar si el usuario puede usar IA según su plan
  bool canUseAI(String userPlan) {
    switch (userPlan) {
      case 'basic':
        return _currentProfile == AiProfile.bienestar;
      case 'full':
      case 'premium':
        return true;
      default:
        return false;
    }
  }

  // Obtener límite de mensajes según plan
  int getMessageLimit(String userPlan) {
    switch (userPlan) {
      case 'basic':
        return 5; // 5 mensajes por día
      case 'full':
        return 50; // 50 mensajes por día
      case 'premium':
        return -1; // Ilimitado
      default:
        return 5;
    }
  }
}
