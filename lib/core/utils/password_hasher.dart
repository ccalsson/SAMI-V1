import 'dart:convert';

import 'package:cryptography/cryptography.dart';

class PasswordHasher {
  PasswordHasher()
      : _algorithm = Argon2id(
          parallelism: 2,
          memory: 65536,
          iterations: 3,
          hashLength: 32,
        );

  final Argon2id _algorithm;

  Future<String> hashPassword(String password) async {
    final salt = SecretKeyData.random(length: 16).bytes;
    final secretKey = await _algorithm.deriveKey(
      secretKey: SecretKey(password.codeUnits),
      nonce: salt,
    );
    final hashBytes = await secretKey.extractBytes();
    return jsonEncode(
      <String, String>{
        'salt': base64Encode(salt),
        'hash': base64Encode(hashBytes),
      },
    );
  }

  Future<bool> verifyPassword(String password, String storedHash) async {
    if (storedHash.isEmpty) {
      return false;
    }
    final dynamic decoded = jsonDecode(storedHash);
    if (decoded is! Map<String, dynamic>) {
      return false;
    }
    final salt = base64Decode(decoded['salt'] as String);
    final expectedHash = base64Decode(decoded['hash'] as String);
    final secretKey = await _algorithm.deriveKey(
      secretKey: SecretKey(password.codeUnits),
      nonce: salt,
    );
    final currentHash = await secretKey.extractBytes();
    if (currentHash.length != expectedHash.length) {
      return false;
    }
    var matches = true;
    for (var i = 0; i < currentHash.length; i++) {
      matches &= currentHash[i] == expectedHash[i];
    }
    return matches;
  }
}
