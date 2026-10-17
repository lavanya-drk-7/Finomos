import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/profile_models.dart';

class ProfileNotifier extends Notifier<ProfileStateData> {
  @override
  ProfileStateData build() {
    return const ProfileStateData();
  }

  void updatePersonalInfo(PersonalInfo info) {
    state = state.copyWith(personalInfo: info);
  }

  void updateProfilePhoto(String path) {
    state = state.copyWith(
      personalInfo: state.personalInfo.copyWith(profilePicUrl: path),
    );
  }

  void updateAddressInfo(AddressInfo info) {
    state = state.copyWith(addressInfo: info);
  }

  void updateEmploymentInfo(EmploymentIncomeInfo info) {
    state = state.copyWith(employmentInfo: info);
  }

  void addFamilyMember(FamilyMember member) {
    state = state.copyWith(
      familyMembers: [...state.familyMembers, member],
    );
  }

  void removeFamilyMember(String id) {
    state = state.copyWith(
      familyMembers: state.familyMembers.where((m) => m.id != id).toList(),
    );
  }

  void updateHouseholdStructure(HouseholdStructure household) {
    state = state.copyWith(householdStructure: household);
  }

  void toggle2FA(bool value) {
    state = state.copyWith(
      securitySettings: state.securitySettings.copyWith(is2FAEnabled: value),
    );
  }

  void updateCommunicationPrefs(CommunicationPreferences prefs) {
    state = state.copyWith(communicationPrefs: prefs);
  }
}

final profileProvider = NotifierProvider<ProfileNotifier, ProfileStateData>(() {
  return ProfileNotifier();
});
