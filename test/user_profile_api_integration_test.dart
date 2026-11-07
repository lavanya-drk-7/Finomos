import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:finomos/core/constants/api_constants.dart';
import 'package:finomos/features/profile/domain/profile_models.dart';

void main() {
  group('User Profile API Payloads & Model Integration Tests', () {
    test('1. GET /api/v1/user/profile maps complete user profile payload correctly', () {
      const jsonStr = '''{
        "success": true,
        "data": {
            "id": "cmuzhxi5a000asr4p9f6jcndp",
            "name": "Sireesha Podalakuru",
            "email": "sireesha@gmail.com",
            "phone": "8985839110",
            "avatarUrl": "/uploads/1793435929233-532470338-3.Money Managment Screen.png",
            "kycStatus": "VERIFIED",
            "kycBadge": "Verified",
            "isEmailVerified": true,
            "isPhoneVerified": true,
            "createdAt": "2026-10-08T12:11:52.991Z",
            "personal": {
                "fullName": "Sireesha Podalakuru",
                "dob": "1998-05-15",
                "gender": "Female",
                "occupation": "Software Professional",
                "annualIncome": 1200000,
                "panNumber": "ABCDE1234F",
                "aadhaarMasked": "•••• •••• 9110"
            },
            "address": {
                "residentialAddress": "Flat 402, Sai Residency, Indiranagar",
                "city": "Bengaluru",
                "state": "Karnataka",
                "pinCode": "560038"
            },
            "security": {
                "twoFactorEnabled": false,
                "biometricEnabled": true,
                "hasPassword": true
            },
            "notifications": {
                "email": true,
                "sms": true,
                "whatsapp": true
            },
            "stats": {
                "linkedAccountsCount": 2,
                "kycDocumentsCount": 10,
                "consentsCount": 9
            }
        }
      }''';

      final Map<String, dynamic> body = jsonDecode(jsonStr);
      expect(body['success'], isTrue);

      final profile = UserProfileData.fromJson(body['data'] as Map<String, dynamic>);

      // Root level fields
      expect(profile.id, 'cmuzhxi5a000asr4p9f6jcndp');
      expect(profile.name, 'Sireesha Podalakuru');
      expect(profile.email, 'sireesha@gmail.com');
      expect(profile.phone, '8985839110');
      expect(profile.avatarUrl, '/uploads/1793435929233-532470338-3.Money Managment Screen.png');
      expect(profile.kycStatus, 'VERIFIED');
      expect(profile.kycBadge, 'Verified');
      expect(profile.isEmailVerified, isTrue);
      expect(profile.isPhoneVerified, isTrue);
      expect(profile.createdAt, '2026-10-08T12:11:52.991Z');

      // Personal nested fields
      expect(profile.personal.fullName, 'Sireesha Podalakuru');
      expect(profile.personal.dob, '1998-05-15');
      expect(profile.personal.gender, 'Female');
      expect(profile.personal.occupation, 'Software Professional');
      expect(profile.personal.annualIncome, 1200000.0);
      expect(profile.personal.panNumber, 'ABCDE1234F');
      expect(profile.personal.aadhaarNumber, '•••• •••• 9110');

      // Address nested fields
      expect(profile.address.residentialAddress, 'Flat 402, Sai Residency, Indiranagar');
      expect(profile.address.city, 'Bengaluru');
      expect(profile.address.state, 'Karnataka');
      expect(profile.address.pinCode, '560038');

      // Security nested fields
      expect(profile.security.is2FAEnabled, isFalse);
      expect(profile.security.biometricEnabled, isTrue);
      expect(profile.security.hasPassword, isTrue);

      // Notifications nested fields
      expect(profile.notifications.emailNotifications, isTrue);
      expect(profile.notifications.smsNotifications, isTrue);
      expect(profile.notifications.whatsappNotifications, isTrue);

      // Stats nested fields
      expect(profile.stats.linkedAccountsCount, 2);
      expect(profile.stats.kycDocumentsCount, 10);
      expect(profile.stats.consentsCount, 9);
    });

    test('2. PUT /api/v1/user/profile/personal generates payload & parses response', () {
      final personal = PersonalInfo(
        fullName: 'Sireesha Bandaru',
        dob: '1998-05-15',
        gender: 'Female',
        occupation: 'Lead AI Engineer',
        annualIncome: 1500000,
      );

      final payload = personal.toPersonalPutJson();
      expect(payload['fullName'], 'Sireesha Bandaru');
      expect(payload['dob'], '1998-05-15');
      expect(payload['gender'], 'Female');
      expect(payload['occupation'], 'Lead AI Engineer');
      expect(payload['annualIncome'], 1500000.0);

      const responseJson = '''{
        "success": true,
        "message": "Personal details updated successfully",
        "data": {
            "userId": "cmuzhxi5a000asr4p9f6jcndp",
            "name": "Sireesha Bandaru",
            "dob": "1998-05-15",
            "gender": "Female",
            "occupation": "Lead AI Engineer",
            "annualIncome": 1500000
        }
      }''';

      final Map<String, dynamic> resp = jsonDecode(responseJson);
      expect(resp['success'], isTrue);
      expect(resp['message'], 'Personal details updated successfully');
      expect(resp['data']['userId'], 'cmuzhxi5a000asr4p9f6jcndp');
      expect(resp['data']['name'], 'Sireesha Bandaru');
      expect(resp['data']['occupation'], 'Lead AI Engineer');
      expect(resp['data']['annualIncome'], 1500000);
    });

    test('3. PUT /api/v1/user/profile/address generates payload & parses response', () {
      const address = AddressInfo(
        residentialAddress: 'Flat 402, Sai Residency, Indiranagar',
        city: 'Bengaluru',
        state: 'Karnataka',
        pinCode: '560038',
      );

      final payload = address.toAddressPutJson();
      expect(payload['address'], 'Flat 402, Sai Residency, Indiranagar');
      expect(payload['city'], 'Bengaluru');
      expect(payload['state'], 'Karnataka');
      expect(payload['pinCode'], '560038');

      const responseJson = '''{
        "success": true,
        "message": "Residential address updated successfully",
        "data": {
            "address": "Flat 402, Sai Residency, Indiranagar",
            "city": "Bengaluru",
            "state": "Karnataka",
            "pinCode": "560038"
        }
      }''';

      final Map<String, dynamic> resp = jsonDecode(responseJson);
      expect(resp['success'], isTrue);
      expect(resp['message'], 'Residential address updated successfully');
      expect(resp['data']['address'], 'Flat 402, Sai Residency, Indiranagar');
      expect(resp['data']['city'], 'Bengaluru');
      expect(resp['data']['state'], 'Karnataka');
      expect(resp['data']['pinCode'], '560038');
    });

    test('4. POST /api/v1/user/profile/photo parses upload response', () {
      const responseJson = '''{
        "success": true,
        "message": "Profile photo updated successfully",
        "data": {
            "avatarUrl": "/uploads/1793600525610-548773898-INV-EXP-2026-EXP1XX_1793430625500.pdf",
            "fileName": "INV-EXP-2026-EXP1XX_1793430625500.pdf",
            "fileSize": 9092
        }
      }''';

      final Map<String, dynamic> resp = jsonDecode(responseJson);
      expect(resp['success'], isTrue);
      expect(resp['message'], 'Profile photo updated successfully');
      expect(resp['data']['avatarUrl'],
          '/uploads/1793600525610-548773898-INV-EXP-2026-EXP1XX_1793430625500.pdf');
      expect(resp['data']['fileName'], 'INV-EXP-2026-EXP1XX_1793430625500.pdf');
      expect(resp['data']['fileSize'], 9092);
    });

    test('5. PUT /api/v1/user/profile/security generates payload & parses response', () {
      const security = SecuritySettings(
        is2FAEnabled: false,
        biometricEnabled: true,
      );

      final payload = security.toSecurityPutJson();
      expect(payload['twoFactorEnabled'], isFalse);
      expect(payload['biometricEnabled'], isTrue);

      const responseJson = '''{
        "success": true,
        "message": "Security credentials and authentication settings updated",
        "data": {
            "twoFactorEnabled": false,
            "biometricEnabled": true,
            "passwordChanged": false
        }
      }''';

      final Map<String, dynamic> resp = jsonDecode(responseJson);
      expect(resp['success'], isTrue);
      expect(resp['message'], 'Security credentials and authentication settings updated');
      expect(resp['data']['twoFactorEnabled'], isFalse);
      expect(resp['data']['biometricEnabled'], isTrue);
      expect(resp['data']['passwordChanged'], isFalse);
    });

    test('6. PUT /api/v1/user/profile/notifications generates payload & parses response', () {
      const notifs = CommunicationPreferences(
        emailNotifications: true,
        smsNotifications: true,
        whatsappNotifications: true,
      );

      final payload = notifs.toNotificationsPutJson();
      expect(payload['email'], isTrue);
      expect(payload['sms'], isTrue);
      expect(payload['whatsapp'], isTrue);

      const responseJson = '''{
        "success": true,
        "message": "Notification preferences updated successfully",
        "data": {
            "email": true,
            "sms": true,
            "whatsapp": true
        }
      }''';

      final Map<String, dynamic> resp = jsonDecode(responseJson);
      expect(resp['success'], isTrue);
      expect(resp['message'], 'Notification preferences updated successfully');
      expect(resp['data']['email'], isTrue);
      expect(resp['data']['sms'], isTrue);
      expect(resp['data']['whatsapp'], isTrue);
    });

    test('7. DELETE /api/v1/user/account parses deactivation response', () {
      const responseJson = '''{
        "success": true,
        "message": "Account deactivation and DPDP Act 2023 right to erasure processed successfully. User session terminated."
      }''';

      final Map<String, dynamic> resp = jsonDecode(responseJson);
      expect(resp['success'], isTrue);
      expect(resp['message'],
          'Account deactivation and DPDP Act 2023 right to erasure processed successfully. User session terminated.');
    });

    test('8. ApiConstants contains all profile endpoints & URL builders', () {
      expect(ApiConstants.userProfile, '/api/v1/user/profile');
      expect(ApiConstants.userProfilePersonal, '/api/v1/user/profile/personal');
      expect(ApiConstants.userProfileAddress, '/api/v1/user/profile/address');
      expect(ApiConstants.userProfileEmployment, '/api/v1/user/profile/employment');
      expect(ApiConstants.userProfileFamilyMembers, '/api/v1/user/profile/family-members');
      expect(ApiConstants.userProfileHousehold, '/api/v1/user/profile/household');
      expect(ApiConstants.userProfileDeviceToken, '/api/v1/user/profile/device-token');
      expect(ApiConstants.userProfilePhoto, '/api/v1/user/profile/photo');
      expect(ApiConstants.userProfileSecurity, '/api/v1/user/profile/security');
      expect(ApiConstants.userProfileNotifications, '/api/v1/user/profile/notifications');
      expect(ApiConstants.userAccount, '/api/v1/user/account');
      expect(ApiConstants.userProfileFamilyMemberById('fam_99'), '/api/v1/user/profile/family-members/fam_99');
    });

    test('9. EmploymentIncomeInfo serialization, deserialization & payload verification', () {
      const jsonMap = {
        'employmentType': 'Salaried Full-Time',
        'companyName': 'Tech Corp India Pvt Ltd',
        'designation': 'Lead Software Engineer',
        'workExperience': '6 Years',
        'workLocation': 'Bengaluru',
        'sourceOfIncome': 'Salary',
        'annualIncome': '₹ 15,00,000',
        'monthlyIncome': '₹ 1,25,000',
      };

      final emp = EmploymentIncomeInfo.fromJson(jsonMap);
      expect(emp.employmentType, 'Salaried Full-Time');
      expect(emp.companyName, 'Tech Corp India Pvt Ltd');
      expect(emp.designation, 'Lead Software Engineer');
      expect(emp.workExperience, '6 Years');
      expect(emp.workLocation, 'Bengaluru');
      expect(emp.annualIncome, '₹ 15,00,000');
      expect(emp.monthlyIncome, '₹ 1,25,000');

      final serialized = emp.toJson();
      expect(serialized['companyName'], 'Tech Corp India Pvt Ltd');
      expect(serialized['designation'], 'Lead Software Engineer');
    });

    test('10. FamilyMember and HouseholdStructure serialization & deserialization', () {
      const famJson = {
        'id': 'fam_001',
        'name': 'Arjun Podalakuru',
        'relationship': 'Spouse',
        'age': 32,
        'isDependent': false,
      };

      final member = FamilyMember.fromJson(famJson);
      expect(member.id, 'fam_001');
      expect(member.name, 'Arjun Podalakuru');
      expect(member.relation, 'Spouse');
      expect(member.age, 32);
      expect(member.isDependent, isFalse);

      final famSerialized = member.toJson();
      expect(famSerialized['name'], 'Arjun Podalakuru');
      expect(famSerialized['relationship'], 'Spouse');

      const houseJson = {
        'jointFinancesEnabled': true,
        'sharedExpensesMonthly': '₹ 50,000',
        'familyGoalsCount': 5,
      };

      final household = HouseholdStructure.fromJson(houseJson);
      expect(household.jointFinancesEnabled, isTrue);
      expect(household.sharedExpensesMonthly, '₹ 50,000');
      expect(household.familyGoalsCount, 5);

      final houseSerialized = household.toJson();
      expect(houseSerialized['jointFinancesEnabled'], isTrue);
      expect(houseSerialized['familyGoalsCount'], 5);
    });
  });
}
