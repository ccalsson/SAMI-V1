import 'dart:convert';
import 'package:http/http.dart' as http;

enum AiProfile {
  bienestar,
  tdaTdh,
  estudiantil,
  desarrolloProfesional,
  preConsulta,
  postConsulta,
}

class AiContext {
  final AiProfile profile;
  final String userMessage;
  final Map<String, dynamic> userData;
  final String? previousContext;
  final List<String> availableModules;

  AiContext({
    required this.profile,
    required this.userMessage,
    this.userData = const {},
    this.previousContext,
    this.availableModules = const [],
  });
}

class AiMessage {
  final String content;
  final List<String> suggestions;
  final List<String> resources;
  final bool requiresProfessional;
  final String? riskLevel;

  AiMessage({
    required this.content,
    this.suggestions = const [],
    this.resources = const [],
    this.requiresProfessional = false,
    this.riskLevel,
  });
}

class AiCoachService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  static const String _model = 'gpt-4';

  final String _apiKey;
  late final Map<AiProfile, String> _prompts;

  AiCoachService({required String apiKey}) : _apiKey = apiKey {
    _prompts = _initializePrompts();
  }

  Map<AiProfile, String> _initializePrompts() {
    return {
      AiProfile.bienestar: '''
        Eres un coach de bienestar mental empático y compasivo. Tu objetivo es:
        - Escuchar activamente y validar emociones
        - Sugerir técnicas de respiración y mindfulness
        - Recomendar música relajante y sonidos
        - Guiar en alimentación saludable
        - SIEMPRE recordar que no reemplazas a un profesional
        
        Responde en español, de manera cálida pero profesional.
        Si detectas señales de riesgo, sugiere consultar con un profesional.
      ''',
      AiProfile.tdaTdh: '''
        Eres un especialista en TDA/TDAH que apoya a personas y familias. Tu enfoque:
        - Ejercicios cortos de 2-5 minutos para mejorar el foco
        - Técnicas de organización y rutinas
        - Estrategias para padres y docentes
        - Refuerzos positivos y celebración de logros
        - SIEMPRE recordar que no reemplazas diagnóstico médico
        
        Responde en español, con ejercicios prácticos y motivación.
        Si hay síntomas severos, sugiere evaluación profesional.
      ''',
      AiProfile.estudiantil: '''
        Eres un coach académico que ayuda a estudiantes a manejar el estrés y mejorar el rendimiento:
        - Técnicas de estudio y organización
        - Método Pomodoro y gestión del tiempo
        - Manejo del estrés académico
        - Explicaciones claras de conceptos complejos
        - SIEMPRE recordar que no reemplazas apoyo académico profesional
        
        Responde en español, con técnicas prácticas y planificación.
        Si hay ansiedad severa, sugiere apoyo psicológico.
      ''',
      AiProfile.desarrolloProfesional: '''
        Eres un coach de desarrollo profesional especializado en soft-skills:
        - Evaluación de liderazgo y comunicación
        - Planes de desarrollo de 4 semanas
        - Feedback 360° y autoevaluación
        - Micro-lecciones y ejercicios prácticos
        - SIEMPRE recordar que no reemplazas coaching ejecutivo profesional
        
        Responde en español, con evaluaciones estructuradas y planes accionables.
        Si hay conflictos laborales severos, sugiere mediación profesional.
      ''',
      AiProfile.preConsulta: '''
        Eres un asistente que prepara a las personas para su consulta con un profesional:
        - Ayudar a organizar pensamientos y síntomas
        - Sugerir preguntas importantes para hacer
        - Preparar información relevante para compartir
        - Calmar ansiedades sobre la consulta
        - SIEMPRE recordar que no reemplazas la evaluación profesional
        
        Responde en español, de manera tranquilizadora y organizadora.
        No hagas diagnósticos, solo ayuda a preparar la consulta.
      ''',
      AiProfile.postConsulta: '''
        Eres un asistente que apoya después de una consulta profesional:
        - Ayudar a procesar la información recibida
        - Recordar recomendaciones importantes
        - Sugerir seguimiento y próximos pasos
        - Apoyar en la implementación de cambios
        - SIEMPRE recordar que no reemplazas las indicaciones del profesional
        
        Responde en español, de manera de apoyo y recordatorio.
        No contradigas las indicaciones del profesional.
      ''',
    };
  }

  Future<AiMessage> respond(AiContext context) async {
    try {
      final prompt = _buildPrompt(context);

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content': prompt,
            },
            {
              'role': 'user',
              'content': context.userMessage,
            },
          ],
          'max_tokens': 500,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];

        return _parseAiResponse(content, context);
      } else {
        throw Exception('Error en la API de OpenAI: ${response.statusCode}');
      }
    } catch (e) {
      return AiMessage(
        content:
            'Lo siento, estoy teniendo dificultades técnicas. Por favor, intenta de nuevo en unos momentos.',
        requiresProfessional: false,
      );
    }
  }

  String _buildPrompt(AiContext context) {
    final basePrompt =
        _prompts[context.profile] ?? _prompts[AiProfile.bienestar]!;

    String fullPrompt = basePrompt;

    // Agregar contexto del usuario
    if (context.userData.isNotEmpty) {
      fullPrompt += '\n\nContexto del usuario: ${jsonEncode(context.userData)}';
    }

    // Agregar contexto previo
    if (context.previousContext != null) {
      fullPrompt += '\n\nConversación previa: ${context.previousContext}';
    }

    // Agregar módulos disponibles
    if (context.availableModules.isNotEmpty) {
      fullPrompt +=
          '\n\nMódulos disponibles: ${context.availableModules.join(', ')}';
    }

    return fullPrompt;
  }

  AiMessage _parseAiResponse(String content, AiContext context) {
    // Análisis básico del contenido para detectar señales de riesgo
    final lowerContent = content.toLowerCase();
    bool requiresProfessional = false;
    String? riskLevel;

    // Detectar palabras clave de riesgo
    final riskKeywords = [
      'suicidio',
      'suicida',
      'morir',
      'matar',
      'herir',
      'violencia',
      'abuso',
      'trauma',
      'crisis',
      'emergencia'
    ];

    if (riskKeywords.any((keyword) => lowerContent.contains(keyword))) {
      requiresProfessional = true;
      riskLevel = 'alto';
    } else if (lowerContent.contains('profesional') ||
        lowerContent.contains('terapeuta')) {
      requiresProfessional = true;
      riskLevel = 'moderado';
    }

    // Extraer sugerencias y recursos (implementación básica)
    final suggestions = _extractSuggestions(content);
    final resources = _extractResources(content);

    return AiMessage(
      content: content,
      suggestions: suggestions,
      resources: resources,
      requiresProfessional: requiresProfessional,
      riskLevel: riskLevel,
    );
  }

  List<String> _extractSuggestions(String content) {
    // Implementación básica para extraer sugerencias
    final lines = content.split('\n');
    return lines
        .where((line) =>
            line.trim().startsWith('-') || line.trim().startsWith('•'))
        .map((line) => line.trim().substring(1).trim())
        .where((suggestion) => suggestion.isNotEmpty)
        .take(3)
        .toList();
  }

  List<String> _extractResources(String content) {
    // Implementación básica para extraer recursos
    final lines = content.split('\n');
    return lines
        .where((line) =>
            line.toLowerCase().contains('recurso') ||
            line.toLowerCase().contains('ejercicio') ||
            line.toLowerCase().contains('técnica'))
        .map((line) => line.trim())
        .where((resource) => resource.isNotEmpty)
        .take(2)
        .toList();
  }

  // Método para guardar resumen de la conversación (opt-in)
  Future<void> saveConversationSummary({
    required String userId,
    required String module,
    required AiContext context,
    required AiMessage response,
  }) async {
    // Implementar guardado en Firestore con consentimiento del usuario
    // Este método se implementará cuando se configure la base de datos
  }
}
