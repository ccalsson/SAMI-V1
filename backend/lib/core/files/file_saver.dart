import 'file_saver_stub.dart'
    if (dart.library.io) 'file_saver_io.dart'
    if (dart.library.html) 'file_saver_web.dart';

abstract class FileSaver {
  Future<String> saveBytes(String filename, List<int> bytes);
}

FileSaver createFileSaver() => createFileSaverImpl();
