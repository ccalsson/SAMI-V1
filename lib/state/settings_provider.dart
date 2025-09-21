import 'package:flutter/foundation.dart';
import 'package:sami_app/data/repositories/settings_repository.dart';

class RoundingSettings {
  const RoundingSettings({
    required this.scaleStepKg,
    required this.itemRoundStep,
    required this.ticketRoundStep,
    required this.ticketRoundMode,
    required this.cashFriendly,
    required this.finishPhrases,
    required this.cashierFinishPhrases,
    required this.confirmPhrases,
    required this.denyPhrases,
  });

  final double scaleStepKg;
  final double itemRoundStep;
  final double ticketRoundStep;
  final String ticketRoundMode;
  final bool cashFriendly;
  final List<String> finishPhrases;
  final List<String> cashierFinishPhrases;
  final List<String> confirmPhrases;
  final List<String> denyPhrases;

  RoundingSettings copyWith({
    double? scaleStepKg,
    double? itemRoundStep,
    double? ticketRoundStep,
    String? ticketRoundMode,
    bool? cashFriendly,
    List<String>? finishPhrases,
    List<String>? cashierFinishPhrases,
    List<String>? confirmPhrases,
    List<String>? denyPhrases,
  }) {
    return RoundingSettings(
      scaleStepKg: scaleStepKg ?? this.scaleStepKg,
      itemRoundStep: itemRoundStep ?? this.itemRoundStep,
      ticketRoundStep: ticketRoundStep ?? this.ticketRoundStep,
      ticketRoundMode: ticketRoundMode ?? this.ticketRoundMode,
      cashFriendly: cashFriendly ?? this.cashFriendly,
      finishPhrases: finishPhrases ?? this.finishPhrases,
      cashierFinishPhrases: cashierFinishPhrases ?? this.cashierFinishPhrases,
      confirmPhrases: confirmPhrases ?? this.confirmPhrases,
      denyPhrases: denyPhrases ?? this.denyPhrases,
    );
  }

  Map<String, dynamic> toMap() => {
        'scaleStepKg': scaleStepKg,
        'itemRoundStep': itemRoundStep,
        'ticketRoundStep': ticketRoundStep,
        'ticketRoundMode': ticketRoundMode,
        'cashFriendly': cashFriendly,
        'finishPhrases': finishPhrases,
        'cashierFinishPhrases': cashierFinishPhrases,
        'confirmPhrases': confirmPhrases,
        'denyPhrases': denyPhrases,
      };

  static RoundingSettings fromMap(Map<String, dynamic> map) {
    return RoundingSettings(
      scaleStepKg: (map['scaleStepKg'] as num? ?? 0.01).toDouble(),
      itemRoundStep: (map['itemRoundStep'] as num? ?? 0.01).toDouble(),
      ticketRoundStep: (map['ticketRoundStep'] as num? ?? 1.0).toDouble(),
      ticketRoundMode: map['ticketRoundMode'] as String? ?? 'nearest',
      cashFriendly: map['cashFriendly'] as bool? ?? false,
      finishPhrases:
          List<String>.from(map['finishPhrases'] as List? ?? const []),
      cashierFinishPhrases:
          List<String>.from(map['cashierFinishPhrases'] as List? ?? const []),
      confirmPhrases:
          List<String>.from(map['confirmPhrases'] as List? ?? const []),
      denyPhrases: List<String>.from(map['denyPhrases'] as List? ?? const []),
    );
  }
}

class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._repository)
      : _settings = RoundingSettings.fromMap(_repository.load());

  final GrocerySettingsRepository _repository;
  RoundingSettings _settings;

  RoundingSettings get settings => _settings;

  Future<void> update(RoundingSettings newSettings) async {
    _settings = newSettings;
    await _repository.save(newSettings.toMap());
    notifyListeners();
  }
}
