import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

class AuthClaims {
  const AuthClaims(
      {required this.role, required this.tenantId, required this.claims});

  final String role;
  final String tenantId;
  final Map<String, dynamic> claims;
}

class TwoFactorRequiredException implements Exception {
  TwoFactorRequiredException(this.resolver);

  final MultiFactorResolver resolver;

  @override
  String toString() => 'TwoFactorRequiredException';
}

class AuthService {
  AuthService(this._auth);

  final FirebaseAuth _auth;

  Future<UserCredential> acceptInvite({
    required String email,
    required String password,
    required String oobCode,
  }) async {
    await _auth.confirmPasswordReset(code: oobCode, newPassword: password);
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<AuthClaims?> loadClaims() async {
    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }
    final result = await user.getIdTokenResult(true);
    final claims = result.claims ?? const <String, dynamic>{};
    final tenantId = claims['tenantId']?.toString();
    if (tenantId == null || tenantId.isEmpty) {
      throw StateError('Missing tenantId claim');
    }
    final role = claims['role']?.toString() ?? 'user';
    return AuthClaims(role: role, tenantId: tenantId, claims: claims);
  }

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
    String? smsCode,
    String? verificationId,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthMultiFactorException catch (exception) {
      if (smsCode == null || verificationId == null) {
        throw TwoFactorRequiredException(exception.resolver);
      }
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final assertion = PhoneMultiFactorGenerator.getAssertion(credential);
      return exception.resolver.resolveSignIn(assertion);
    }
  }

  Future<MultiFactorSession> startTwoFactorEnrollment() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('User not signed in');
    }
    return user.multiFactor.getSession();
  }

  Future<void> requestTwoFactorCode({
    required MultiFactorSession session,
    required String phoneNumber,
    Duration timeout = const Duration(seconds: 60),
    void Function(FirebaseAuthException error)? onError,
    void Function(String verificationId)? onCodeSent,
  }) {
    final completer = Completer<void>();
    unawaited(_auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: timeout,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException error) {
        onError?.call(error);
        if (!completer.isCompleted) {
          completer.completeError(error);
        }
      },
      codeSent: (String verificationId, int? _) {
        onCodeSent?.call(verificationId);
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      codeAutoRetrievalTimeout: (String _) {
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      multiFactorSession: session,
    ));
    return completer.future;
  }

  Future<void> finalizeTwoFactorEnrollment({
    required String verificationId,
    required String smsCode,
    String? displayName,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('User not signed in');
    }
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final assertion = PhoneMultiFactorGenerator.getAssertion(credential);
    await user.multiFactor.enroll(assertion, displayName: displayName);
  }

  Future<void> disableTwoFactor({String? factorUid}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('User not signed in');
    }
    final factors = await user.multiFactor.getEnrolledFactors();
    if (factors.isEmpty) {
      return;
    }
    if (factorUid != null) {
      await user.multiFactor.unenroll(factorUid: factorUid);
      return;
    }
    await user.multiFactor.unenroll(factorUid: factors.first.uid);
  }
}
