import 'package:firebase_auth/firebase_auth.dart';

/// Simple UI-less helpers for multi-factor enrollment and verification. In a
/// real app this would be coupled with forms and navigation flows.
class MfaFlow {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Starts phone/SMS second factor enrollment for the current user.
  Future<void> enrollPhone(String phoneNumber) async {
    final user = _auth.currentUser;
    if (user == null) return;
    // TODO: Use FirebaseAuth.instance.verifyPhoneNumber and enroll.
  }

  /// Verifies a received [code] for the given [verificationId].
  Future<void> verifySms(String verificationId, String code) async {
    final credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: code);
    await _auth.currentUser?.multiFactor.enroll(
      PhoneMultiFactorGenerator.getAssertion(credential),
      displayName: 'phone',
    );
  }

  /// Forces SMS MFA for admins and professionals.
  Future<bool> assertMfaEnabled() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    // Placeholder: check custom claims for role
    final role = (await user.getIdTokenResult()).claims?['role'];
    if (role == 'admin' || role == 'professional') {
      return user.multiFactor.enrolledFactors.isNotEmpty;
    }
    return true;
  }
}
