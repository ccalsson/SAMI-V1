import 'secure_storage_stub.dart'
    if (dart.library.io) 'secure_storage_mobile.dart'
    if (dart.library.html) 'secure_storage_web.dart';

/// Abstraction over secure persistence for secrets such as tokens.
abstract class SecureStorage {
  Future<void> write(String key, String value);

  Future<String?> read(String key);

  Future<void> delete(String key);

  Future<void> clear();
}

SecureStorage createSecureStorage() => createSecureStorageImpl();
