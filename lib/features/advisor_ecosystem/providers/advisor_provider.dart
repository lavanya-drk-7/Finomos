import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/advisor_models.dart';

class AdvisorState {
  final List<Advisor> advisors;
  final List<ConsultationBooking> bookings;

  AdvisorState({
    required this.advisors,
    this.bookings = const [],
  });

  AdvisorState copyWith({
    List<Advisor>? advisors,
    List<ConsultationBooking>? bookings,
  }) {
    return AdvisorState(
      advisors: advisors ?? this.advisors,
      bookings: bookings ?? this.bookings,
    );
  }
}

class AdvisorNotifier extends Notifier<AdvisorState> {
  @override
  AdvisorState build() {
    return AdvisorState(
      advisors: [
        Advisor(
          id: 'a1',
          name: 'CA Rajesh Sharma',
          title: 'Senior Tax & Capital Gains Consultant',
          category: 'Chartered Accountant',
          role: 'CA Management',
          experience: '14+ Years Exp',
          rating: 4.9,
          consultationFee: 1499,
          isVerified: 'SEBI & ICAI Verified',
          registrationNumber: 'ICAI-MRN-492810',
          verificationAgency: 'ICAI & CBDT Registered',
          verificationStatus: 'Active & Verified',
          bio: 'Former Big-4 Tax Director specializing in Capital Gains, Section 54/54F property exemptions, ESOP taxation, and High-Net-Worth ITR filing.',
          specializations: ['Capital Gains', 'Real Estate Tax', 'ITR & Notice Help', 'Crypto / F&O'],
          reviewsCount: 184,
          languages: 'English, Hindi',
          permissionsOffered: [
            'AIS & Form 26AS Tax Records',
            'Bank Aggregation Accounts',
            'AI CFO Balance Sheet & Net Worth',
            'Document Vault Financial Statements',
          ],
          assignmentOptions: [
            'Direct 1-on-1 Assigned Advisor',
            'AI CFO Smart Match (Instant)',
            'Quarterly Advisory Board Retainer',
          ],
          ratingBreakdown: {
            'Domain Mastery': 4.9,
            'Responsiveness': 4.8,
            'Tax & ROI Impact': 5.0,
            'Clarity & Empathy': 4.9,
          },
          reviews: [
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
        ),
        Advisor(
          id: 'a2',
          name: 'Priya Sundaram, CFP',
          title: 'Certified Financial Planner & FIRE Specialist',
          category: 'Wealth Advisor',
          role: 'Financial Planner Management',
          experience: '10+ Years Exp',
          rating: 4.8,
          consultationFee: 1999,
          isVerified: 'CFB Board Verified',
          registrationNumber: 'FPSB-CFP-810294',
          verificationAgency: 'Financial Planning Standards Board',
          verificationStatus: 'Active & Verified',
          bio: 'SEBI Registered Investment Advisor (RIA) helping salaried professionals and entrepreneurs achieve financial independence through asset allocation and goals.',
          specializations: ['FIRE Planning', 'Mutual Fund Portfolio', 'Asset Allocation', 'Child Education'],
          reviewsCount: 136,
          languages: 'English, Tamil, Hindi',
          permissionsOffered: [
            'AI CFO Balance Sheet & Net Worth',
            'Monthly Expense & Cashflow Trends',
            'Mutual Funds & Equity Portfolios',
            'Retirement & Goal Trackers',
          ],
          assignmentOptions: [
            'Direct 1-on-1 Assigned Advisor',
            'AI CFO Smart Match (Instant)',
            'Annual Comprehensive Financial Roadmap',
          ],
          ratingBreakdown: {
            'Asset Allocation Strategy': 5.0,
            'Retirement Modeling': 4.9,
            'Punctuality': 4.8,
            'Practical Actionability': 4.9,
          },
          reviews: [
            {
              'client': 'Karthik V.',
              'rating': '5.0',
              'comment': 'Built a crystal-clear 10-year FIRE blueprint. Balanced high equity risk with liquid safety nets.',
              'time': 'Yesterday',
            },
          ],
        ),
        Advisor(
          id: 'a3',
          name: 'Anil Kulkarni',
          title: 'Insurance Coverage & Health Portfolio Strategist',
          category: 'Insurance Advisor',
          role: 'Insurance Advisor Management',
          experience: '12+ Years Exp',
          rating: 4.9,
          consultationFee: 999,
          isVerified: 'IRDAI Registered',
          registrationNumber: 'IRDAI-AG-2918402',
          verificationAgency: 'Insurance Regulatory & Development Authority',
          verificationStatus: 'Active & Licensed',
          bio: 'Independent insurance expert focusing on unbundled term life insurance sizing, 1 Crore+ critical illness policies, and claim dispute advocacy.',
          specializations: ['Term Life Sizing', 'Super Top-up Health', 'Portability', 'Claim Assistance'],
          reviewsCount: 92,
          languages: 'English, Marathi, Hindi',
          permissionsOffered: [
            'Family Household Health Records',
            'Existing Insurance Policy Vault',
            'Liability & Outstanding Loans Audit',
          ],
          assignmentOptions: [
            'Direct 1-on-1 Assigned Advisor',
            'Instant Claim Support Hotline',
            'Family Risk Assessment Review',
          ],
          ratingBreakdown: {
            'Policy Unbundling': 5.0,
            'Zero Commission Bias': 5.0,
            'Speed of Response': 4.9,
            'Claim Readiness': 4.8,
          },
          reviews: [
            {
              'client': 'Suresh K.',
              'rating': '5.0',
              'comment': 'Identified a major sub-limit loophole in my existing health policy and guided me to port without loss.',
              'time': '5 days ago',
            },
          ],
        ),
        Advisor(
          id: 'a4',
          name: 'Dr. Vikram Sengupta, RIA',
          title: 'Senior Equity & Multi-Asset Portfolio Architect',
          category: 'Investment Advisor',
          role: 'Investment Advisor Management',
          experience: '16+ Years Exp',
          rating: 4.9,
          consultationFee: 2499,
          isVerified: 'SEBI Registered RIA',
          registrationNumber: 'SEBI-RIA-INA00001829',
          verificationAgency: 'Securities and Exchange Board of India',
          verificationStatus: 'Active & Verified',
          bio: 'Fee-only SEBI Registered Investment Advisor specializing in factor investing, direct indexing, global asset diversification, and private wealth structuring.',
          specializations: ['Direct Equity & Factor Tilts', 'Multi-Asset Hedging', 'PMS / AIF Review', 'Rebalancing'],
          reviewsCount: 215,
          languages: 'English, Bengali, Hindi',
          permissionsOffered: [
            'Demat & Direct Stock Portfolios',
            'Mutual Fund NAV Feeds',
            'Risk Tolerance & Drawdown Limits',
            'AI CFO Net Worth Balance Sheet',
          ],
          assignmentOptions: [
            'Direct 1-on-1 Assigned Advisor',
            'Private Wealth Retainer',
            'Annual Portfolio Audit',
          ],
          ratingBreakdown: {
            'Alpha Generation': 4.9,
            'Risk Management': 5.0,
            'Communication': 4.9,
            'Fee Transparency': 5.0,
          },
          reviews: [
            {
              'client': 'Ananya Roy',
              'rating': '5.0',
              'comment': 'Completely restructured my bloated 38-fund mutual fund mess into a clean, 5-fund powerhouse.',
              'time': '4 days ago',
            },
          ],
        ),
      ],
    );
  }

  void bookConsultation(ConsultationBooking booking) {
    state = state.copyWith(bookings: [booking, ...state.bookings]);
  }

  void cancelBooking(String bookingId) {
    state = state.copyWith(
      bookings: state.bookings.where((b) => b.bookingId != bookingId).toList(),
    );
  }
}

final advisorProvider = NotifierProvider<AdvisorNotifier, AdvisorState>(() {
  return AdvisorNotifier();
});
