import 'package:sami_app/domain/entities/app_settings.dart';
import 'package:sami_app/domain/repositories/settings_repository.dart';

class GetAppSettingsUseCase {
  const GetAppSettingsUseCase(this._repository);

  final SettingsRepository _repository;

  Future<AppSettings> call() => _repository.loadSettings();
}
