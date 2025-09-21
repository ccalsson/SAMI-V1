import 'package:flutter_test/flutter_test.dart';
import 'package:mindcare/security/client_crypto.dart';

void main() {
  test('encrypt/decrypt roundtrip', () async {
    final crypto = ClientCrypto();
    const plain = 'secret';
    final encrypted = await crypto.encrypt(plain);
    final decrypted = await crypto.decrypt(encrypted);
    expect(decrypted, plain);
  });
}
