import 'package:flutter/material.dart';

// API Configuration
const String kBaseUrl = 'https://api.homehustleapp.com/v1';
const Duration kApiTimeout = Duration(seconds: 30);
const int kMaxRetries = 3;

// App Configuration
const String kAppName = 'Home Hustle';
const String kAppVersion = '1.0.0';
const String kAppBuildNumber = '1';

// Storage Keys
const String kAuthTokenKey = 'authToken';
const String kUserDataKey = 'userData';
const String kIsFirstTimeKey = 'isFirstTime';
const String kThemeModeKey = 'themeMode';
const String kNotificationSettingsKey = 'notificationSettings';
const String kLanguageKey = 'language';

// Account Types
const String kAccountTypeAdult = 'adult';
const String kAccountTypeChild = 'child';

// Job Status
const String kJobStatusOpen = 'open';
const String kJobStatusInProgress = 'in_progress';
const String kJobStatusCompleted = 'completed';
const String kJobStatusCancelled = 'cancelled';
const String kJobStatusPendingApproval = 'pending_approval';

// Job Types
const String kJobTypeFamily = 'family';
const String kJobTypePublic = 'public';

// Job Categories
const List<String> kJobCategories = [
  'Cleaning',
  'Yard Work',
  'Pet Care',
  'Organizing',
  'Errands',
  'Tech Help',
  'Tutoring',
  'Other',
];

// Transaction Types
const String kTransactionTypeJobPayment = 'job_payment';
const String kTransactionTypeAllowance = 'allowance';
const String kTransactionTypeBonus = 'bonus';
const String kTransactionTypePurchase = 'purchase';
const String kTransactionTypeWithdrawal = 'withdrawal';
const String kTransactionTypeDeposit = 'deposit';

// Notification Types
const String kNotificationTypeJobPosted = 'job_posted';
const String kNotificationTypeJobApplication = 'job_application';
const String kNotificationTypeJobApproved = 'job_approved';
const String kNotificationTypeJobCompleted = 'job_completed';
const String kNotificationTypePaymentReceived = 'payment_received';
const String kNotificationTypePaymentSent = 'payment_sent';
const String kNotificationTypeFamilyInvite = 'family_invite';
const String kNotificationTypeStoreItem = 'store_item';

// Validation Rules
const int kMinPasswordLength = 8;
const int kMaxPasswordLength = 128;
const int kMinNameLength = 2;
const int kMaxNameLength = 50;
const int kMinJobTitleLength = 3;
const int kMaxJobTitleLength = 100;
const int kMinJobDescriptionLength = 10;
const int kMaxJobDescriptionLength = 1000;
const double kMinWage = 0.01;
const double kMaxWage = 9999.99;
const int kMaxJobApplicationsPerChild = 10;
const int kMaxActiveJobsPerChild = 5;

// UI Constants
const double kDefaultPadding = 16.0;
const double kSmallPadding = 8.0;
const double kLargePadding = 24.0;
const double kDefaultBorderRadius = 12.0;
const double kSmallBorderRadius = 8.0;
const double kLargeBorderRadius = 16.0;
const double kDefaultElevation = 4.0;
const Duration kDefaultAnimationDuration = Duration(milliseconds: 300);
const Duration kFastAnimationDuration = Duration(milliseconds: 200);
const Duration kSlowAnimationDuration = Duration(milliseconds: 500);

// Colors (These will be overridden by theme.dart but provided as fallbacks)
const Color kPrimaryColor = Color(0xFF4A90E2);
const Color kSecondaryColor = Color(0xFF50E3C2);
const Color kErrorColor = Color(0xFFE74C3C);
const Color kWarningColor = Color(0xFFF39C12);
const Color kSuccessColor = Color(0xFF27AE60);
const Color kInfoColor = Color(0xFF3498DB);

// Asset Paths
const String kAssetsPath = 'assets';
const String kImagesPath = '$kAssetsPath/images';
const String kIconsPath = '$kAssetsPath/icons';
const String kAnimationsPath = '$kAssetsPath/animations';

// Image Assets
const String kLogoImage = '$kImagesPath/logo.png';
const String kOnboarding1Image = '$kImagesPath/onboarding_1.png';
const String kOnboarding2Image = '$kImagesPath/onboarding_2.png';
const String kOnboarding3Image = '$kImagesPath/onboarding_3.png';
const String kEmptyStateImage = '$kImagesPath/empty_state.png';
const String kSuccessImage = '$kImagesPath/success.png';
const String kErrorImage = '$kImagesPath/error.png';

// Animation Assets
const String kLoadingAnimation = '$kAnimationsPath/loading.json';
const String kSuccessAnimation = '$kAnimationsPath/success.json';
const String kErrorAnimation = '$kAnimationsPath/error.json';
const String kConfettiAnimation = '$kAnimationsPath/confetti.json';

// Default Values
const String kDefaultCurrency = 'USD';
const String kDefaultLanguage = 'en';
const String kDefaultCountryCode = 'US';
const double kDefaultAllowance = 10.0;
const int kDefaultJobDurationDays = 7;

// Feature Flags
const bool kEnableNotifications = true;
const bool kEnableInAppPurchases = false;
const bool kEnableAnalytics = true;
const bool kEnableCrashlytics = true;
const bool kEnableDebugMode = false;

// Error Messages
const String kGenericErrorMessage = 'Something went wrong. Please try again.';
const String kNetworkErrorMessage = 'Please check your internet connection.';
const String kAuthErrorMessage = 'Authentication failed. Please login again.';
const String kPermissionDeniedMessage = 'You do not have permission to perform this action.';
const String kNotFoundErrorMessage = 'The requested resource was not found.';

// Success Messages
const String kProfileUpdatedMessage = 'Profile updated successfully!';
const String kJobCreatedMessage = 'Job created successfully!';
const String kJobAppliedMessage = 'Application submitted successfully!';
const String kPaymentSentMessage = 'Payment sent successfully!';
const String kInviteSentMessage = 'Invite sent successfully!';

// Regex Patterns
const String kEmailRegexPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
const String kPhoneRegexPattern = r'^\+?1?\d{9,15}$';
const String kNameRegexPattern = r'^[a-zA-Z\s-]+$';
const String kAlphanumericRegexPattern = r'^[a-zA-Z0-9]+$';

// Firebase Collections
const String kUsersCollection = 'users';
const String kJobsCollection = 'jobs';
const String kTransactionsCollection = 'transactions';
const String kNotificationsCollection = 'notifications';
const String kFamiliesCollection = 'families';
const String kStoreItemsCollection = 'storeItems';
const String kJobApplicationsCollection = 'jobApplications';

// Pagination
const int kDefaultPageSize = 20;
const int kMaxPageSize = 100;

// Cache Duration
const Duration kShortCacheDuration = Duration(minutes: 5);
const Duration kMediumCacheDuration = Duration(minutes: 30);
const Duration kLongCacheDuration = Duration(hours: 2);
const Duration kDayCacheDuration = Duration(days: 1);

// Deep Links
const String kDeepLinkScheme = 'homehustle';
const String kDeepLinkHost = 'app';

// Social Media Links
const String kWebsiteUrl = 'https://homehustleapp.com';
const String kSupportEmail = 'support@homehustleapp.com';
const String kPrivacyPolicyUrl = 'https://homehustleapp.com/privacy';
const String kTermsOfServiceUrl = 'https://homehustleapp.com/terms';