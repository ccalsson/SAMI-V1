import 'dart:io';

import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class FakePathProviderPlatform extends PathProviderPlatform {
  FakePathProviderPlatform();

  Directory? _appDir;
  Directory? _tempDir;

  @override
  Future<String?> getApplicationDocumentsPath() async {
    _appDir ??= await Directory.systemTemp.createTemp('sami_app_docs');
    return _appDir!.path;
  }

  @override
  Future<String?> getTemporaryPath() async {
    _tempDir ??= await Directory.systemTemp.createTemp('sami_app_tmp');
    return _tempDir!.path;
  }

  Future<void> dispose() async {
    if (_appDir != null && await _appDir!.exists()) {
      await _appDir!.delete(recursive: true);
    }
    if (_tempDir != null && await _tempDir!.exists()) {
      await _tempDir!.delete(recursive: true);
    }
  }
}
