import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sami_app/multi_tenant/services/auth_service.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockUser extends Mock implements User {}

class _MockIdTokenResult extends Mock implements IdTokenResult {}

class _MockMultiFactor extends Mock implements MultiFactor {}

class _MockMultiFactorInfo extends Mock implements MultiFactorInfo {}

void main() {
  group('AuthService.loadClaims', () {
    late FirebaseAuth firebaseAuth;
    late AuthService service;
    late User user;
    late IdTokenResult tokenResult;

    setUp(() {
      firebaseAuth = _MockFirebaseAuth();
      service = AuthService(firebaseAuth);
      user = _MockUser();
      tokenResult = _MockIdTokenResult();
      when(() => firebaseAuth.currentUser).thenReturn(user);
      when(() => user.getIdTokenResult(true)).thenAnswer((_) async => tokenResult);
    });

    test('returns claims when tenantId is present', () async {
      when(() => tokenResult.claims).thenReturn({
        'tenantId': 'tenant-1',
        'role': 'super_admin',
      });

      final claims = await service.loadClaims();

      expect(claims, isNotNull);
      expect(claims!.tenantId, 'tenant-1');
      expect(claims.role, 'super_admin');
    });

    test('throws when tenantId claim is missing', () async {
      when(() => tokenResult.claims).thenReturn({'role': 'user'});

      expect(
        () => service.loadClaims(),
        throwsStateError,
      );
    });
  });

  group('AuthService.disableTwoFactor', () {
    late FirebaseAuth firebaseAuth;
    late AuthService service;
    late User user;
    late MultiFactor multiFactor;
    late MultiFactorInfo info;

    setUp(() {
      firebaseAuth = _MockFirebaseAuth();
      service = AuthService(firebaseAuth);
      user = _MockUser();
      multiFactor = _MockMultiFactor();
      info = _MockMultiFactorInfo();

      when(() => firebaseAuth.currentUser).thenReturn(user);
      when(() => user.multiFactor).thenReturn(multiFactor);
    });

    test('unenrolls provided factor uid', () async {
      when(() => multiFactor.getEnrolledFactors())
          .thenAnswer((_) async => [info]);
      when(() => multiFactor.unenroll(factorUid: 'factor-1', multiFactorInfo: null))
          .thenAnswer((_) async {});

      await service.disableTwoFactor(factorUid: 'factor-1');

      verify(() => multiFactor.unenroll(factorUid: 'factor-1', multiFactorInfo: null))
          .called(1);
    });

    test('unenrolls first factor when uid not provided', () async {
      when(() => info.uid).thenReturn('factor-xyz');
      when(() => multiFactor.getEnrolledFactors())
          .thenAnswer((_) async => [info]);
      when(() => multiFactor.unenroll(factorUid: 'factor-xyz', multiFactorInfo: null))
          .thenAnswer((_) async {});

      await service.disableTwoFactor();

      verify(() => multiFactor.unenroll(factorUid: 'factor-xyz', multiFactorInfo: null))
          .called(1);
    });
  });
}
