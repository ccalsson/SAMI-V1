// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

import 'file_saver.dart';

FileSaver createFileSaverImpl() => _WebFileSaver();

class _WebFileSaver implements FileSaver {
  @override
  Future<String> saveBytes(String filename, List<int> bytes) async {
    final blob = html.Blob([Uint8List.fromList(bytes)]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
    return filename;
  }
}
