import 'file_saver.dart';

FileSaver createFileSaverImpl() => _UnsupportedFileSaver();

class _UnsupportedFileSaver implements FileSaver {
  @override
  Future<String> saveBytes(String filename, List<int> bytes) async {
    return filename;
  }
}
