import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/fpms_models.dart';

class FpmsState {
  final List<PlatformKpiMetric> kpis;
  final List<FpmsDomain> domains;

  FpmsState({
    required this.kpis,
    required this.domains,
  });
}

class FpmsNotifier extends Notifier<FpmsState> {
  @override
  FpmsState build() {
    return FpmsState(
      kpis: [
        PlatformKpiMetric(label: 'Total Platform Users', value: '1.24 Million', changeText: '+18.4% YoY', isPositive: true),
        PlatformKpiMetric(label: 'Assets Tracked (AUM)', value: '₹14,250 Cr', changeText: '+24.1% MoM', isPositive: true),
        PlatformKpiMetric(label: 'Payments Processed', value: '₹840 Cr/mo', changeText: '+12.5%', isPositive: true),
        PlatformKpiMetric(label: 'Tax Savings Generated', value: '₹142 Cr', changeText: '+32.0%', isPositive: true),
      ],
      domains: [
        FpmsDomain(id: 'd1', title: '1. Platform Governance', code: 'PGM', description: 'Global setup, country, currency, tax rules & feature flags', iconName: 'gavel', status: 'Active'),
        FpmsDomain(id: 'd2', title: '2. User & Household Management', code: 'UHM', description: 'KYC status, family groups, account lifecycle', iconName: 'people', status: 'Active'),
        FpmsDomain(id: 'd3', title: '3. Financial Institution Directory', code: 'FID', description: 'AA Mapping, Bank APIs, UPI PSP configuration', iconName: 'account_balance', status: 'Active'),
        FpmsDomain(id: 'd4', title: '4. Financial Data Engine', code: 'FDE', description: 'SMS parser, Email OCR & categorization rules', iconName: 'dataset', status: 'Active'),
        FpmsDomain(id: 'd5', title: '5. Master Data Management', code: 'MDM', description: 'Categories, Merchants, Subscriptions master', iconName: 'folder_special', status: 'Active'),
        FpmsDomain(id: 'd6', title: '6. Payment Operations', code: 'POP', description: 'BBPS Utility billers, Settlement & Failed transaction recovery', iconName: 'payments', status: 'Active'),
        FpmsDomain(id: 'd7', title: '7. AI & Automation Rules', code: 'AIR', description: 'Rule engine thresholds, Prompts, Confidence scoring', iconName: 'smart_toy', status: 'Active'),
        FpmsDomain(id: 'd8', title: '8. Tax & Compliance Admin', code: 'TCA', description: 'Tax slabs, AIS/TIS parsers, Regulatory updates', iconName: 'receipt', status: 'Active'),
        FpmsDomain(id: 'd9', title: '9. Advisor Ecosystem Management', code: 'AEM', description: 'CA verification, Client assignment, Ratings', iconName: 'medical_services', status: 'Active'),
        FpmsDomain(id: 'd10', title: '10. Marketplace Operations', code: 'MKT', description: 'Insurance, MF Distribution, Loans, Commission rules', iconName: 'storefront', status: 'Active'),
        FpmsDomain(id: 'd11', title: '11. Risk, Fraud & Security', code: 'RFS', description: 'AML monitoring, Device tracking, Session audit logs', iconName: 'security', status: 'Active'),
        FpmsDomain(id: 'd12', title: '12. Analytics & Executive BI', code: 'ABI', description: 'CXO KPI dashboard, Platform financial health', iconName: 'analytics', status: 'Active'),
      ],
    );
  }
}

final fpmsProvider = NotifierProvider<FpmsNotifier, FpmsState>(() {
  return FpmsNotifier();
});
