import '../../core/constants.dart';

class User {
  final String userId;
  final String name;
  final String email;
  final UserRole role;
  final String? familyId;
  final String? parentId;
  final String? phoneNumber;
  final bool emailVerified;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final Map<String, dynamic>? settings;

  User({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    this.familyId,
    this.parentId,
    this.phoneNumber,
    required this.emailVerified,
    this.profileImageUrl,
    required this.createdAt,
    this.lastLoginAt,
    this.settings,
  });

  // Factory constructor to create User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: _parseUserRole(json['role'] as String),
      familyId: json['familyId'] as String?,
      parentId: json['parentId'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      emailVerified: json['emailVerified'] as bool? ?? false,
      profileImageUrl: json['profileImageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] != null 
          ? DateTime.parse(json['lastLoginAt'] as String) 
          : null,
      settings: json['settings'] as Map<String, dynamic>?,
    );
  }

  // Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'role': role.toString().split('.').last,
      'familyId': familyId,
      'parentId': parentId,
      'phoneNumber': phoneNumber,
      'emailVerified': emailVerified,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'settings': settings,
    };
  }

  // Parse string to UserRole enum
  static UserRole _parseUserRole(String role) {
    switch (role.toLowerCase()) {
      case 'parent':
        return UserRole.parent;
      case 'child':
        return UserRole.child;
      case 'employer':
        return UserRole.employer;
      default:
        throw ArgumentError('Invalid user role: $role');
    }
  }

  // Create a copy with updated fields
  User copyWith({
    String? userId,
    String? name,
    String? email,
    UserRole? role,
    String? familyId,
    String? parentId,
    String? phoneNumber,
    bool? emailVerified,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    Map<String, dynamic>? settings,
  }) {
    return User(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      familyId: familyId ?? this.familyId,
      parentId: parentId ?? this.parentId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emailVerified: emailVerified ?? this.emailVerified,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      settings: settings ?? this.settings,
    );
  }

  // Getters for role checking
  bool get isParent => role == UserRole.parent;
  bool get isChild => role == UserRole.child;
  bool get isEmployer => role == UserRole.employer;

  // Get settings with defaults
  bool get notificationsEnabled => settings?['notificationsEnabled'] ?? true;
  CurrencyDisplay get currencyDisplay {
    final display = settings?['currencyDisplay'] ?? 'dollar';
    return display == 'star' ? CurrencyDisplay.star : CurrencyDisplay.dollar;
  }
  int get publicJobRadius => settings?['publicJobRadius'] ?? UIConstants.defaultDistanceRadius;

  // Child-specific settings
  bool get publicJobsEnabled => settings?['publicJobsEnabled'] ?? false;
  bool get investmentAccountEnabled => settings?['investmentAccountEnabled'] ?? false;
  bool get loansEnabled => settings?['loansEnabled'] ?? false;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.userId == userId &&
        other.name == name &&
        other.email == email &&
        other.role == role &&
        other.familyId == familyId &&
        other.parentId == parentId &&
        other.phoneNumber == phoneNumber &&
        other.emailVerified == emailVerified &&
        other.profileImageUrl == profileImageUrl &&
        other.createdAt == createdAt &&
        other.lastLoginAt == lastLoginAt;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        name.hashCode ^
        email.hashCode ^
        role.hashCode ^
        familyId.hashCode ^
        parentId.hashCode ^
        phoneNumber.hashCode ^
        emailVerified.hashCode ^
        profileImageUrl.hashCode ^
        createdAt.hashCode ^
        lastLoginAt.hashCode;
  }

  @override
  String toString() {
    return 'User(userId: $userId, name: $name, email: $email, role: $role)';
  }
}

// Extended Child User Model
class ChildUser extends User {
  final int age;
  final DateTime? birthDate;
  final Map<String, double> accountBalances;
  final int completedJobs;
  final double totalEarnings;
  final List<String> achievements;

  ChildUser({
    required super.userId,
    required super.name,
    required super.email,
    super.familyId,
    super.parentId,
    super.phoneNumber,
    required super.emailVerified,
    super.profileImageUrl,
    required super.createdAt,
    super.lastLoginAt,
    super.settings,
    required this.age,
    this.birthDate,
    required this.accountBalances,
    required this.completedJobs,
    required this.totalEarnings,
    required this.achievements,
  }) : super(role: UserRole.child);

  factory ChildUser.fromJson(Map<String, dynamic> json) {
    final user = User.fromJson(json);
    return ChildUser(
      userId: user.userId,
      name: user.name,
      email: user.email,
      familyId: user.familyId,
      parentId: user.parentId,
      phoneNumber: user.phoneNumber,
      emailVerified: user.emailVerified,
      profileImageUrl: user.profileImageUrl,
      createdAt: user.createdAt,
      lastLoginAt: user.lastLoginAt,
      settings: user.settings,
      age: json['age'] as int? ?? 0,
      birthDate: json['birthDate'] != null 
          ? DateTime.parse(json['birthDate'] as String) 
          : null,
      accountBalances: Map<String, double>.from(
        json['accountBalances'] ?? {'checking': 0.0, 'savings': 0.0}
      ),
      completedJobs: json['completedJobs'] as int? ?? 0,
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      achievements: List<String>.from(json['achievements'] ?? []),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'age': age,
      'birthDate': birthDate?.toIso8601String(),
      'accountBalances': accountBalances,
      'completedJobs': completedJobs,
      'totalEarnings': totalEarnings,
      'achievements': achievements,
    });
    return json;
  }
}

// Family Settings Model
class FamilySettings {
  final String familyId;
  final CurrencyDisplay currencyDisplay;
  final Map<String, bool> childPermissions;
  final double withdrawalLimit;
  final double transferLimit;
  final bool publicJobsEnabled;
  final int publicJobRadius;
  final Map<String, dynamic> storeSettings;
  final Map<String, dynamic> notificationSettings;

  FamilySettings({
    required this.familyId,
    required this.currencyDisplay,
    required this.childPermissions,
    required this.withdrawalLimit,
    required this.transferLimit,
    required this.publicJobsEnabled,
    required this.publicJobRadius,
    required this.storeSettings,
    required this.notificationSettings,
  });

  factory FamilySettings.fromJson(Map<String, dynamic> json) {
    return FamilySettings(
      familyId: json['familyId'] as String,
      currencyDisplay: json['currencyDisplay'] == 'star' 
          ? CurrencyDisplay.star 
          : CurrencyDisplay.dollar,
      childPermissions: Map<String, bool>.from(json['childPermissions'] ?? {}),
      withdrawalLimit: (json['withdrawalLimit'] as num?)?.toDouble() ?? 100.0,
      transferLimit: (json['transferLimit'] as num?)?.toDouble() ?? 50.0,
      publicJobsEnabled: json['publicJobsEnabled'] as bool? ?? false,
      publicJobRadius: json['publicJobRadius'] as int? ?? UIConstants.defaultDistanceRadius,
      storeSettings: Map<String, dynamic>.from(json['storeSettings'] ?? {}),
      notificationSettings: Map<String, dynamic>.from(json['notificationSettings'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'familyId': familyId,
      'currencyDisplay': currencyDisplay == CurrencyDisplay.star ? 'star' : 'dollar',
      'childPermissions': childPermissions,
      'withdrawalLimit': withdrawalLimit,
      'transferLimit': transferLimit,
      'publicJobsEnabled': publicJobsEnabled,
      'publicJobRadius': publicJobRadius,
      'storeSettings': storeSettings,
      'notificationSettings': notificationSettings,
    };
  }
}