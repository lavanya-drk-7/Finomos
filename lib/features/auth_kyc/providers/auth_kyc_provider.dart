import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/kyc_models.dart';

class AuthKycNotifier extends Notifier<KycStateData> {
  @override
  KycStateData build() {
    return const KycStateData();
  }

  void updateStep(int step) {
    state = state.copyWith(currentStep: step);
  }

  void updateUserData(UserRegistrationData newUserData) {
    state = state.copyWith(user: newUserData);
  }

  void setKycStatus(KycStatus status) {
    state = state.copyWith(kycStatus: status);
  }

  void setMobileVerified(bool value) {
    state = state.copyWith(isMobileVerified: value);
  }

  void setOtpVerified(bool value) {
    state = state.copyWith(isOtpVerified: value);
  }

  void setIsExistingUser(bool value) {
    state = state.copyWith(
      isExistingUser: value,
      kycStatus: value ? KycStatus.verified : state.kycStatus,
    );
  }

  void updateProfilePhoto(String path) {
    state = state.copyWith(user: state.user.copyWith(profilePicUrl: path));
  }

  void reset() {
    state = const KycStateData();
  }
}

final authKycProvider = NotifierProvider<AuthKycNotifier, KycStateData>(() {
  return AuthKycNotifier();
});
