import 'package:flutter/material.dart';

class Routes {
  // Prevent instantiation
  Routes._();

  // Auth Routes
  static const String login = '/login';
  static const String register = '/register';
  static const String verification = '/verification';
  static const String splash = '/splash';

  // Parent Dashboard Routes
  static const String parentHome = '/parent/home';
  static const String parentJobs = '/parent/jobs';
  static const String parentCreateJob = '/parent/jobs/create';
  static const String parentManageJobs = '/parent/jobs/manage';
  static const String parentBank = '/parent/bank';
  static const String parentStore = '/parent/store';
  static const String parentStoreAddItem = '/parent/store/add-item';
  static const String parentStoreEditItem = '/parent/store/edit-item';
  static const String parentNotifications = '/parent/notifications';
  static const String parentSettings = '/parent/settings';
  static const String parentProfile = '/parent/profile';
  static const String parentChildDetails = '/parent/child-details';
  static const String parentJobApplications = '/parent/job-applications';
  static const String parentWithdrawalRequests = '/parent/withdrawal-requests';

  // Child Dashboard Routes
  static const String childHome = '/child/home';
  static const String childJobs = '/child/jobs';
  static const String childJobDetails = '/child/jobs/details';
  static const String childJobBoard = '/child/jobs/board';
  static const String childPublicJobs = '/child/jobs/public';
  static const String childBank = '/child/bank';
  static const String childBankTransfer = '/child/bank/transfer';
  static const String childBankWithdraw = '/child/bank/withdraw';
  static const String childStore = '/child/store';
  static const String childStoreItemDetails = '/child/store/item';
  static const String childResume = '/child/resume';
  static const String childAchievements = '/child/achievements';
  static const String childNotifications = '/child/notifications';
  static const String childSettings = '/child/settings';
  static const String childProfile = '/child/profile';

  // Employer Dashboard Routes
  static const String employerHome = '/employer/home';
  static const String employerPostJob = '/employer/post-job';
  static const String employerEditJob = '/employer/edit-job';
  static const String employerManageJobs = '/employer/manage-jobs';
  static const String employerJobDetails = '/employer/job-details';
  static const String employerApplicants = '/employer/applicants';
  static const String employerNotifications = '/employer/notifications';
  static const String employerSettings = '/employer/settings';
  static const String employerProfile = '/employer/profile';

  // Common/Shared Routes
  static const String settings = '/settings';
  static const String accountSettings = '/settings/account';
  static const String privacySettings = '/settings/privacy';
  static const String notificationSettings = '/settings/notifications';
  static const String themeSettings = '/settings/theme';
  static const String helpSupport = '/help-support';
  static const String about = '/about';
  static const String terms = '/terms';
  static const String privacy = '/privacy';

  // Error Routes
  static const String error404 = '/404';
  static const String errorGeneral = '/error';

  // Deep Link Routes
  static const String jobDeepLink = '/job/:id';
  static const String inviteDeepLink = '/invite/:code';

  // Route Groups for Navigation Guards
  static const List<String> publicRoutes = [
    login,
    register,
    verification,
    splash,
    terms,
    privacy,
    about,
  ];

  static const List<String> parentOnlyRoutes = [
    parentHome,
    parentJobs,
    parentCreateJob,
    parentManageJobs,
    parentBank,
    parentStore,
    parentStoreAddItem,
    parentStoreEditItem,
    parentNotifications,
    parentSettings,
    parentProfile,
    parentChildDetails,
    parentJobApplications,
    parentWithdrawalRequests,
  ];

  static const List<String> childOnlyRoutes = [
    childHome,
    childJobs,
    childJobDetails,
    childJobBoard,
    childPublicJobs,
    childBank,
    childBankTransfer,
    childBankWithdraw,
    childStore,
    childStoreItemDetails,
    childResume,
    childAchievements,
    childNotifications,
    childSettings,
    childProfile,
  ];

  static const List<String> employerOnlyRoutes = [
    employerHome,
    employerPostJob,
    employerEditJob,
    employerManageJobs,
    employerJobDetails,
    employerApplicants,
    employerNotifications,
    employerSettings,
    employerProfile,
  ];

  // Helper methods for route validation
  static bool isPublicRoute(String route) {
    return publicRoutes.contains(route);
  }

  static bool isParentRoute(String route) {
    return parentOnlyRoutes.contains(route);
  }

  static bool isChildRoute(String route) {
    return childOnlyRoutes.contains(route);
  }

  static bool isEmployerRoute(String route) {
    return employerOnlyRoutes.contains(route);
  }

  static bool isAuthRoute(String route) {
    return route == login || route == register || route == verification;
  }

  // Get home route based on user role
  static String getHomeRouteForRole(String role) {
    switch (role.toUpperCase()) {
      case 'PARENT':
        return parentHome;
      case 'CHILD':
        return childHome;
      case 'EMPLOYER':
        return employerHome;
      default:
        return login;
    }
  }

  // Get default route after login based on role
  static String getDefaultRouteForRole(String role) {
    return getHomeRouteForRole(role);
  }

  // Route parameter keys
  static const String paramJobId = 'jobId';
  static const String paramChildId = 'childId';
  static const String paramItemId = 'itemId';
  static const String paramApplicationId = 'applicationId';
  static const String paramNotificationId = 'notificationId';
  static const String paramTransactionId = 'transactionId';
  static const String paramAccountType = 'accountType';
  static const String paramInviteCode = 'inviteCode';
  static const String paramReturnRoute = 'returnRoute';
  static const String paramDeepLinkData = 'deepLinkData';

  // Query parameter keys
  static const String queryTab = 'tab';
  static const String queryFilter = 'filter';
  static const String querySort = 'sort';
  static const String queryPage = 'page';
  static const String querySearch = 'search';
  static const String queryStatus = 'status';
  static const String queryDateFrom = 'from';
  static const String queryDateTo = 'to';
}