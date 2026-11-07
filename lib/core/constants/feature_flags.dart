/// Central configuration for module visibility.
/// Allows hiding modules in UI while preserving 100% of the underlying
/// implementations, code, business logic, providers, and models.
class AppFeatureFlags {
  // Hidden modules per requirement (Protect, Borrow, Grow, Plan, Comply, Advisors, Help & Support)
  static const bool showProtectModule = false;
  static const bool showBorrowModule = false;
  static const bool showGrowModule = false;
  static const bool showPlanModule = false;
  static const bool showComplyModule = false;
  static const bool showAdvisorsModule = false;
  static const bool showHelpSupportModule = false;

  // Active Modules (Earn/Income, Spend/Expense, Budget, Bank Feeds, Vault, AI CFO, Profile)
  static const bool showIncomeModule = true;
  static const bool showExpenseModule = true;
  static const bool showBudgetModule = true;
  static const bool showBankFeedsModule = true;
  static const bool showDocumentVaultModule = true;
  static const bool showCfoAiModule = true;
}

