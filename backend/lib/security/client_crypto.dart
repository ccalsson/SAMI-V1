import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Helper for client-side encryption of sensitive documents.
class ClientCrypto {
  final _storage = const FlutterSecureStorage();

  Future<Encrypter> _encrypter() async {
    var keyData = await _storage.read(key: 'user_key');
    if (keyData == null) {
      final key = Key.fromSecureRandom(32);
      keyData = base64UrlEncode(key.bytes);
      await _storage.write(key: 'user_key', value: keyData);
    }
    final key = Key(base64Url.decode(keyData));
    // TODO: implement periodic key rotation and re-encryption of data.
    return Encrypter(AES(key, mode: AESMode.gcm));
  }

  Future<String> encrypt(String plain) async {
    final enc = await _encrypter();
    final iv = IV.fromSecureRandom(12);
    final encrypted = enc.encrypt(plain, iv: iv);
    return jsonEncode({'iv': base64UrlEncode(iv.bytes), 'data': encrypted.base64});
  }

  Future<String> decrypt(String payload) async {
    final enc = await _encrypter();
    final map = jsonDecode(payload) as Map<String, dynamic>;
    final iv = IV(base64Url.decode(map['iv'] as String));
    return enc.decrypt64(map['data'] as String, iv: iv);
  }
}
