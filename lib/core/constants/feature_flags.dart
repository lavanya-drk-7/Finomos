/// Central configuration for module visibility.
/// Allows hiding modules in UI while preserving 100% of the underlying
/// implementations, code, business logic, providers, and models.
class AppFeatureFlags {
  // SMS Permissions & Direct Inbox Scanning (Hidden for Google Play Console Policy Compliance)
  // Google Play strictly restricts READ_SMS & RECEIVE_SMS to certified Default SMS Handlers.
  // Setting this to false hides all SMS permission prompts, routes, and native permission requests
  // while preserving 100% of underlying implementations, parsers, and transaction detection engines.
  static const bool enableSmsPermissions = false;
  static const bool showSmsTrackingPrompt = false;

  // Mobile OTP Login (Hidden for Google Play Policy Compliance)
  // Google Play policies scrutinize SMS/OTP verification for financial transactions.
  // Setting this to false defaults login to Email ID & Password and hides Mobile Number/OTP UI
  // while preserving 100% of underlying models and authentication services.
  static const bool showMobileLogin = false;

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

