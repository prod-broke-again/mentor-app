import 'package:local_auth/local_auth.dart';

/// Optional biometric gate before using a stored session token.
final class BiometricAuth {
  BiometricAuth({LocalAuthentication? auth}) : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  /// True if the device can show a system biometric / device credential prompt.
  Future<bool> get isAvailable async {
    try {
      final can = await _auth.canCheckBiometrics;
      final supported = await _auth.isDeviceSupported();
      return can || supported;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticate({required String localizedReason}) async {
    try {
      return await _auth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
