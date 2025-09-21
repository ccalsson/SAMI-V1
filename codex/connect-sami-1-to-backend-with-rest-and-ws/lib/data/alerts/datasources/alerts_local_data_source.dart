import 'dart:convert';

import 'package:isar/isar.dart';

import '../../../core/database/entities.dart';
import '../models/alert_dto.dart';

class AlertsLocalDataSource {
  AlertsLocalDataSource(this._isar);

  final Isar _isar;

  Future<List<AlertDto>> loadAlerts() async {
    final query = _isar.cachedEntitys.buildQuery<CachedEntity>();
    final all = await query.findAll();
    final alerts = all
        .where((entity) => entity.type == 'alert')
        .map((entity) => AlertDto.fromJson(
              jsonDecode(entity.data) as Map<String, dynamic>,
            ))
        .toList();
    return alerts;
  }

  Future<void> cacheAlerts(List<AlertDto> alerts) async {
    await _isar.writeTxn(() async {
      final existing = await _isar.cachedEntitys.buildQuery<CachedEntity>().findAll();
      for (final entity in existing.where((element) => element.type == 'alert')) {
        await _isar.cachedEntitys.delete(entity.id);
      }
      for (final alert in alerts) {
        final entity = CachedEntity.create(
          type: 'alert',
          entityId: alert.id,
          data: jsonEncode(alert.toJson()),
        );
        await _isar.cachedEntitys.put(entity);
      }
    });
  }

  Future<void> upsertAlert(AlertDto alert) async {
    await _isar.writeTxn(() async {
      final entity = CachedEntity.create(
        type: 'alert',
        entityId: alert.id,
        data: jsonEncode(alert.toJson()),
      );
      await _isar.cachedEntitys.put(entity);
    });
  }
}
