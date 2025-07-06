// API Configuration
class ApiConstants {
  static const String baseUrl = 'https://us-central1-home-hustle-app.cloudfunctions.net';
  
  // Auth Endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String sendVerification = '/auth/send-verification';
  static const String invite = '/auth/invite';
  
  // Account Endpoints
  static const String createAccount = '/accounts/create';
  static const String transferFunds = '/accounts/transfer';
  static const String withdrawRequest = '/accounts/withdraw';
  static const String loan = '/accounts/loan';
  
  // Job Endpoints
  static const String createJob = '/jobs/create';
  static const String applyToJob = '/jobs/apply';
  static const String approveOffer = '/jobs/approve-offer';
  static const String completeJob = '/jobs/complete';
  static const String resignJob = '/jobs/resign';
  
  // Marketplace Endpoints
  static const String nearbyJobs = '/marketplace/nearby-jobs';
  static const String markJobPaid = '/marketplace/mark-paid';
  
  // Notification Endpoints
  static const String sendNotification = '/notifications/send';
  
  // Store Endpoints
  static const String addItem = '/store/add-item';
  static const String purchaseItem = '/store/purchase';
}

// User Roles
enum UserRole {
  parent,
  child,
  employer,
}

// Currency Display Types
enum CurrencyDisplay {
  dollar,
  star,
}

// Account Types
enum AccountType {
  checking,
  savings,
  investment,
}

// Job Types
enum JobType {
  home,
  public,
}

// Job Status
enum JobStatus {
  open,
  pending,
  assigned,
  completed,
  resigned,
  cancelled,
}

// Application Status
enum ApplicationStatus {
  pending,
  accepted,
  rejected,
  approved,
  withdrawn,
}

// Notification Types
enum NotificationType {
  jobOffer,
  jobApplication,
  jobCompletion,
  withdrawalRequest,
  withdrawalApproval,
  parentApproval,
  paymentReceived,
  reminder,
  achievement,
  systemAlert,
}

// Transaction Types
enum TransactionType {
  deposit,
  withdrawal,
  transfer,
  jobPayment,
  storePurchase,
  interest,
  loan,
  loanRepayment,
  fine,
}

// Navigation Routes
class AppRoutes {
  // Auth Routes
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyEmail = '/verify-email';
  
  // Parent Dashboard Routes
  static const String parentHome = '/parent/home';
  static const String manageJobs = '/parent/jobs';
  static const String familyBank = '/parent/bank';
  static const String familyStore = '/parent/store';
  static const String parentNotifications = '/parent/notifications';
  
  // Child Dashboard Routes
  static const String childHome = '/child/home';
  static const String jobBoard = '/child/jobs';
  static const String myBank = '/child/bank';
  static const String resume = '/child/resume';
  static const String store = '/child/store';
  static const String achievements = '/child/achievements';
  
  // Employer Dashboard Routes
  static const String employerHome = '/employer/home';
  static const String postJob = '/employer/post-job';
  static const String myJobs = '/employer/my-jobs';
  
  // Settings Routes
  static const String profile = '/settings/profile';
  static const String accountSettings = '/settings/account';
  static const String appPreferences = '/settings/preferences';
  
  // Common Routes
  static const String notifications = '/notifications';
  static const String settings = '/settings';
}

// Financial Constants
class FinancialConstants {
  static const double savingsInterestRate = 0.05; // 5% monthly
  static const double investmentInterestRate = 0.10; // 10% monthly
  static const double loanInterestRate = 0.30; // 30% APR
  static const double overdraftLimit = 100.0;
  static const double minimumTransfer = 0.01;
  static const double maximumTransfer = 10000.0;
}

// UI Constants
class UIConstants {
  static const int maxDistanceRadius = 10; // miles
  static const int minDistanceRadius = 1; // miles
  static const int defaultDistanceRadius = 5; // miles
  
  static const int maxJobsPerPage = 20;
  static const int maxNotificationsPerPage = 50;
  
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration sessionTimeout = Duration(hours: 24);
}

// Job Categories
class JobCategories {
  static const List<String> categories = [
    'Kitchen',
    'Bedroom',
    'Bathroom',
    'Living Areas',
    'Outdoor',
    'Pet Care',
    'Organizing',
    'Laundry',
    'Tech Help',
    'Other',
  ];
  
  static const Map<String, String> categoryIcons = {
    'Kitchen': '🍽️',
    'Bedroom': '🛏️',
    'Bathroom': '🚿',
    'Living Areas': '🛋️',
    'Outdoor': '🌳',
    'Pet Care': '🐾',
    'Organizing': '📦',
    'Laundry': '👕',
    'Tech Help': '💻',
    'Other': '✨',
  };
}

// Achievement Types
class AchievementTypes {
  static const String firstJob = 'first_job';
  static const String tenJobs = 'ten_jobs';
  static const String hundredJobs = 'hundred_jobs';
  static const String firstSaving = 'first_saving';
  static const String savingsGoal = 'savings_goal';
  static const String investmentPro = 'investment_pro';
  static const String punctualWorker = 'punctual_worker';
  static const String topEarner = 'top_earner';
  static const String helpfulNeighbor = 'helpful_neighbor';
  static const String financialLiteracy = 'financial_literacy';
}

// Error Messages
class ErrorMessages {
  static const String networkError = 'Please check your internet connection and try again.';
  static const String serverError = 'Something went wrong. Please try again later.';
  static const String invalidCredentials = 'Invalid email or password.';
  static const String emailAlreadyExists = 'An account with this email already exists.';
  static const String weakPassword = 'Password must be at least 6 characters long.';
  static const String insufficientFunds = 'Insufficient funds for this transaction.';
  static const String unauthorized = 'You are not authorized to perform this action.';
  static const String sessionExpired = 'Your session has expired. Please login again.';
}

// Success Messages
class SuccessMessages {
  static const String accountCreated = 'Account created successfully!';
  static const String loginSuccess = 'Welcome back!';
  static const String jobCreated = 'Job posted successfully!';
  static const String jobCompleted = 'Great job! Task completed.';
  static const String transferSuccess = 'Transfer completed successfully!';
  static const String purchaseSuccess = 'Purchase completed!';
  static const String profileUpdated = 'Profile updated successfully!';
}

// Validation Constants
class ValidationConstants {
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 128;
  static const int maxNameLength = 50;
  static const int maxJobTitleLength = 100;
  static const int maxJobDescriptionLength = 500;
  static const double minWage = 0.01;
  static const double maxWage = 1000.0;
}

// Storage Keys
class StorageKeys {
  static const String authToken = 'auth_token';
  static const String userId = 'user_id';
  static const String userRole = 'user_role';
  static const String themeMode = 'theme_mode';
  static const String currencyDisplay = 'currency_display';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String onboardingCompleted = 'onboarding_completed';
}

// Firebase Collections
class FirebaseCollections {
  static const String users = 'users';
  static const String jobs = 'jobs';
  static const String families = 'families';
  static const String notifications = 'notifications';
  static const String invites = 'invites';
  static const String withdrawals = 'withdrawals';
  static const String achievements = 'achievements';
}

// Regular Expressions
class RegexPatterns {
  static final RegExp email = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final RegExp phone = RegExp(
    r'^\+?1?\d{10,14}$',
  );
  static final RegExp currency = RegExp(
    r'^\d+\.?\d{0,2}$',
  );
}