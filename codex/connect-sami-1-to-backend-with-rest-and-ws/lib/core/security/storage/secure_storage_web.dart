import 'dart:convert';
import 'dart:html' as html;
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import 'package:encrypt/encrypt.dart' as encrypt;

import 'secure_storage.dart';

class SecureStorageWeb implements SecureStorage {
  SecureStorageWeb()
      : _encrypter = encrypt.Encrypter(
          encrypt.Salsa20(_deriveKey()),
        );

  static final Random _random = Random.secure();
  static const int _nonceLength = 8;
  static final String _seed = 'sami-web-storage-seed';

  final encrypt.Encrypter _encrypter;

  @override
  Future<void> clear() async => html.window.localStorage.clear();

  @override
  Future<void> delete(String key) async => html.window.localStorage.remove(key);

  @override
  Future<String?> read(String key) async {
    final encoded = html.window.localStorage[key];
    if (encoded == null) {
      return null;
    }
    try {
      final raw = base64Decode(encoded);
      if (raw.length <= _nonceLength) {
        return null;
      }
      final nonce = raw.sublist(0, _nonceLength);
      final cipherBytes = raw.sublist(_nonceLength);
      final decrypted = _encrypter.decrypt(
        encrypt.Encrypted(cipherBytes),
        iv: encrypt.IV(Uint8List.fromList(nonce)),
      );
      return decrypted;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> write(String key, String value) async {
    final nonce = List<int>.generate(_nonceLength, (_) => _random.nextInt(255));
    final encrypted = _encrypter.encrypt(
      value,
      iv: encrypt.IV(Uint8List.fromList(nonce)),
    );
    final payload = Uint8List(nonce.length + encrypted.bytes.length)
      ..setRange(0, nonce.length, nonce)
      ..setRange(nonce.length, nonce.length + encrypted.bytes.length,
          encrypted.bytes);
    html.window.localStorage[key] = base64Encode(payload);
  }

  static encrypt.Key _deriveKey() {
    final hash = crypto.sha256.convert(utf8.encode(_seed));
    return encrypt.Key(Uint8List.fromList(hash.bytes));
  }
}

SecureStorage createSecureStorageImpl() => SecureStorageWeb();
