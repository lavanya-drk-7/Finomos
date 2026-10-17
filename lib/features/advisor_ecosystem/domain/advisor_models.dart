class Advisor {
  final String id;
  final String name;
  final String title;
  final String category; // CA, Wealth Manager, Insurance Specialist
  final String role; // CA Management, Financial Planner Management, Insurance Advisor Management, Investment Advisor Management
  final String experience;
  final double rating;
  final double consultationFee;
  final String isVerified;
  final String registrationNumber;
  final String verificationAgency;
  final String verificationStatus;
  final String bio;
  final List<String> specializations;
  final int reviewsCount;
  final String languages;
  final List<String> permissionsOffered;
  final List<String> assignmentOptions;
  final Map<String, double> ratingBreakdown;
  final List<Map<String, String>> reviews;

  Advisor({
    required this.id,
    required this.name,
    required this.title,
    required this.category,
    this.role = 'CA Management',
    required this.experience,
    required this.rating,
    required this.consultationFee,
    required this.isVerified,
    this.registrationNumber = 'ICAI-MRN-492810',
    this.verificationAgency = 'SEBI & ICAI Verified',
    this.verificationStatus = 'Active & Authenticated',
    this.bio = 'Verified financial practitioner with extensive advisory experience.',
    this.specializations = const ['Tax Planning', 'Wealth Advisory', 'Portfolio Review'],
    this.reviewsCount = 142,
    this.languages = 'English, Hindi',
    this.permissionsOffered = const [
      'AIS & Form 26AS Tax Records',
      'Bank Aggregation Accounts',
      'AI CFO Balance Sheet & Net Worth',
      'Monthly Expense & Cashflow Trends',
      'Document Vault Financial Statements',
    ],
    this.assignmentOptions = const [
      'Direct 1-on-1 Assigned Advisor',
      'AI CFO Smart Match (Instant)',
      'Quarterly Advisory Board Retainer',
    ],
    this.ratingBreakdown = const {
      'Domain Mastery': 4.9,
      'Responsiveness': 4.8,
      'Tax & ROI Impact': 5.0,
      'Clarity & Empathy': 4.9,
    },
    this.reviews = const [
      {
        'client': 'Rajeev Menon',
        'rating': '5.0',
        'comment': 'Saved over ₹2.4 Lakhs in capital gains tax via Section 54EC bonds and indexation planning.',
        'time': '3 days ago',
      },
      {
        'client': 'Neha Sharma',
        'rating': '4.9',
        'comment': 'Extremely knowledgeable! Handled complex foreign RSUs and ESOP taxation with ease.',
        'time': '1 week ago',
      },
    ],
  });
}

class ConsultationBooking {
  final String bookingId;
  final String advisorId;
  final String advisorName;
  final String advisorTitle;
  final String selectedRole;
  final String date;
  final String timeSlot;
  final String consultationMode; // Video Call, Phone Call, Chat
  final String agenda;
  final String clientName;
  final String clientPhone;
  final String clientEmail;
  final String notes;
  final bool shareAiCfoReport;
  final List<String> grantedPermissions;
  final String assignmentType;
  final double amountPaid;
  final String status; // Confirmed, Completed, Cancelled
  final String meetLink;
  final DateTime createdAt;

  ConsultationBooking({
    required this.bookingId,
    required this.advisorId,
    required this.advisorName,
    required this.advisorTitle,
    this.selectedRole = 'CA Management',
    required this.date,
    required this.timeSlot,
    required this.consultationMode,
    required this.agenda,
    required this.clientName,
    required this.clientPhone,
    required this.clientEmail,
    required this.notes,
    this.shareAiCfoReport = true,
    this.grantedPermissions = const [
      'AIS & Form 26AS Tax Records',
      'AI CFO Balance Sheet & Net Worth',
    ],
    this.assignmentType = 'Direct 1-on-1 Assigned Advisor',
    required this.amountPaid,
    this.status = 'Confirmed',
    required this.meetLink,
    required this.createdAt,
  });

  String get dateFormatted => date;
}
