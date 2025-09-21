import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../logging/app_logger.dart';
import 'entities.dart';
import '../offline/outbox_task.dart';

class IsarDatabase {
  IsarDatabase._();

  static Isar? _isar;

  static Future<Isar> instance() async {
    if (_isar != null) {
      return _isar!;
    }
    final schemas = [CachedEntitySchema, OutboxTaskSchema];
    try {
      if (kIsWeb) {
        _isar = await Isar.open(
          schemas,
          inspector: kDebugMode,
          name: 'sami',
        );
      } else {
        final dir = await getApplicationSupportDirectory();
        _isar = await Isar.open(
          schemas,
          inspector: kDebugMode,
          directory: dir.path,
          name: 'sami',
        );
      }
    } catch (error, stackTrace) {
      AppLogger.instance.error('Failed to open Isar', error, stackTrace);
      rethrow;
    }
    return _isar!;
  }
}
