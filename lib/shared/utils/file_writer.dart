import 'file_writer_stub.dart' if (dart.library.io) 'file_writer_io.dart'
    as impl;

Future<void> writeStringToFile(String path, String content) =>
    impl.writeStringToFile(path, content);
