import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/income_models.dart';

class IncomeNotifier extends Notifier<IncomeState> {
  @override
  IncomeState build() {
    return const IncomeState(
      entries: [
        IncomeEntry(
          id: 'inc_1',
          source: 'Tech Corp India Pvt Ltd',
          category: 'Salary',
          type: 'Active',
          amount: 85000.0,
          date: '25 Aug 2025',
          frequency: 'Monthly',
          notes: 'Base Salary & PF credited',
          isVerified: true,
          bankAccount: 'HDFC Bank ••••4587',
          documentName: 'salary_slip_aug_2025.pdf',
          documentPath: '/docs/salary_slip_aug_2025.pdf',
        ),
        IncomeEntry(
          id: 'inc_2',
          source: 'UI/UX Design Consulting',
          category: 'Freelance',
          type: 'Active',
          amount: 22000.0,
          date: '18 Aug 2025',
          frequency: 'Monthly',
          notes: 'Client Retainer Contract',
          isVerified: true,
          bankAccount: 'ICICI Bank ••••9021',
        ),
        IncomeEntry(
          id: 'inc_3',
          source: 'Urban 2BHK Apartment',
          category: 'Rental',
          type: 'Passive',
          amount: 18500.0,
          date: '05 Aug 2025',
          frequency: 'Monthly',
          notes: 'Rental Inflow Koramangala',
          isVerified: true,
          bankAccount: 'SBI ••••1123',
        ),
        IncomeEntry(
          id: 'inc_4',
          source: 'Nifty 50 Index Dividends',
          category: 'Dividend',
          type: 'Passive',
          amount: 4200.0,
          date: '12 Aug 2025',
          frequency: 'Monthly',
          notes: 'Quarterly Dividend Avg',
          isVerified: true,
          bankAccount: 'HDFC Bank ••••4587',
        ),
        IncomeEntry(
          id: 'inc_5',
          source: 'Fixed Deposit Interest',
          category: 'Interest',
          type: 'Passive',
          amount: 2800.0,
          date: '01 Aug 2025',
          frequency: 'Monthly',
          notes: 'Auto sweep FD interest',
          isVerified: true,
          bankAccount: 'Axis Bank ••••3301',
        ),
        IncomeEntry(
          id: 'inc_6',
          source: 'Annual Performance Bonus',
          category: 'Bonus',
          type: 'Windfall',
          amount: 65000.0,
          date: '15 Jul 2025',
          frequency: 'One-time',
          notes: 'Q4 Appraisal Bonus',
          isVerified: true,
          bankAccount: 'HDFC Bank ••••4587',
        ),
      ],
    );
  }

  void addIncome(IncomeEntry entry) {
    state = state.copyWith(
      entries: [entry, ...state.entries],
      selectedCategoryFilter: 'All',
      selectedTypeFilter: 'All',
      selectedBankAccountFilter: 'All',
      selectedDateFilter: 'All',
      searchQuery: '',
    );
  }

  void updateIncome(IncomeEntry entry) {
    final updated = state.entries.map((e) => e.id == entry.id ? entry : e).toList();
    state = state.copyWith(
      entries: updated,
      selectedCategoryFilter: 'All',
      selectedTypeFilter: 'All',
      selectedBankAccountFilter: 'All',
      selectedDateFilter: 'All',
      searchQuery: '',
    );
  }

  void deleteIncome(String id) {
    state = state.copyWith(entries: state.entries.where((e) => e.id != id).toList());
  }

  void resetFilters() {
    state = state.copyWith(
      selectedCategoryFilter: 'All',
      selectedTypeFilter: 'All',
      selectedBankAccountFilter: 'All',
      selectedDateFilter: 'All',
      searchQuery: '',
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setCategoryFilter(String category) {
    state = state.copyWith(selectedCategoryFilter: category);
  }

  void setTypeFilter(String type) {
    state = state.copyWith(selectedTypeFilter: type);
  }

  void setBankAccountFilter(String bank) {
    state = state.copyWith(selectedBankAccountFilter: bank);
  }

  void setDateFilter(String dateStr) {
    state = state.copyWith(selectedDateFilter: dateStr);
  }

  void setForecastHorizon(String horizon) {
    state = state.copyWith(forecastHorizon: horizon);
  }

  void toggleAutoTracking() {
    state = state.copyWith(autoTrackingEnabled: !state.autoTrackingEnabled);
  }
}

final incomeProvider = NotifierProvider<IncomeNotifier, IncomeState>(() {
  return IncomeNotifier();
});
