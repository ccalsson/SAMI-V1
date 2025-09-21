import 'dart:io';

Future<void> writeStringToFile(String path, String content) async {
  final file = File(path);
  await file.writeAsString(content);
}
