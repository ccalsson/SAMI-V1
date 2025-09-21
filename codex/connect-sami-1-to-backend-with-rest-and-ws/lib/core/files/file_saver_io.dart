import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'file_saver.dart';

FileSaver createFileSaverImpl() => _IoFileSaver();

class _IoFileSaver implements FileSaver {
  @override
  Future<String> saveBytes(String filename, List<int> bytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }
}
