import 'dart:convert';

import '../../core/config/app_config.dart';
import '../../core/errors/app_error.dart';
import '../../core/files/file_saver.dart';
import '../../core/logging/app_logger.dart';
import '../../domain/reports/reports_repository.dart';
import 'reports_remote_data_source.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  ReportsRepositoryImpl(
    this._remote,
    this._config,
    this._logger,
    FileSaver? saver,
  ) : _fileSaver = saver ?? createFileSaver();

  final ReportsRemoteDataSource _remote;
  final AppConfig _config;
  final AppLogger _logger;
  final FileSaver _fileSaver;

  @override
  Future<String> downloadAlertsReport({required DateTime from, required DateTime to}) {
    return _download(
      filename: 'alerts-${from.toIso8601String()}-${to.toIso8601String()}.csv',
      loader: () => _remote.downloadAlerts({
        'from': from.toIso8601String(),
        'to': to.toIso8601String(),
      }),
      demoContent: _demoAlertsCsv(from, to),
    );
  }

  @override
  Future<String> downloadFuelReport({required DateTime from, required DateTime to}) {
    return _download(
      filename: 'fuel-${from.toIso8601String()}-${to.toIso8601String()}.csv',
      loader: () => _remote.downloadFuel({
        'from': from.toIso8601String(),
        'to': to.toIso8601String(),
      }),
      demoContent: _demoFuelCsv(from, to),
    );
  }

  @override
  Future<String> downloadToolsReport({required DateTime from, required DateTime to}) {
    return _download(
      filename: 'tools-${from.toIso8601String()}-${to.toIso8601String()}.csv',
      loader: () => _remote.downloadTools({
        'from': from.toIso8601String(),
        'to': to.toIso8601String(),
      }),
      demoContent: _demoToolsCsv(from, to),
    );
  }

  Future<String> _download({
    required String filename,
    required Future<List<int>> Function() loader,
    required String demoContent,
  }) async {
    try {
      final bytes = _config.isDemoMode ? utf8.encode(demoContent) : await loader();
      final savedPath = await _fileSaver.saveBytes(filename, bytes);
      return savedPath;
    } on AppError catch (error) {
      _logger.warn('Download report failed', error);
      rethrow;
    } catch (error, stackTrace) {
      _logger.error('Unexpected report download error', error, stackTrace);
      rethrow;
    }
  }

  String _demoAlertsCsv(DateTime from, DateTime to) {
    return 'id,type,severity,createdAt\n'
        'a-1,Temperatura,high,${from.toIso8601String()}\n'
        'a-2,Movimiento,medium,${to.toIso8601String()}';
  }

  String _demoFuelCsv(DateTime from, DateTime to) {
    return 'id,vehicle,operator,liters,timestamp\n'
        'f-1,truck-1,op-1,120,${from.toIso8601String()}\n'
        'f-2,truck-2,op-2,80,${to.toIso8601String()}';
  }

  String _demoToolsCsv(DateTime from, DateTime to) {
    return 'id,tool,operator,type,timestamp\n'
        't-1,Taladro,op-1,checkout,${from.toIso8601String()}\n'
        't-2,Sierra,op-2,return,${to.toIso8601String()}';
  }
}
