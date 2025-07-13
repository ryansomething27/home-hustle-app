// frontend/data/models/user.dart

import 'dart:convert';

class UserModel {

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.accountType,
    required this.createdAt, required this.updatedAt, this.profileImageUrl,
    this.isEmailVerified = false,
    this.isActive = true,
    this.phoneNumber,
    this.familyId,
    this.childrenIds,
    this.totalSpent,
    this.parentId,
    this.birthDate,
    this.balance,
    this.totalEarned,
    this.completedJobIds,
    this.skillTags,
    this.resumeUrl,
    this.notificationSettings,
    this.preferredLanguage,
    this.timezone,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      accountType: map['accountType'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
      isEmailVerified: map['isEmailVerified'] ?? false,
      isActive: map['isActive'] ?? true,
      phoneNumber: map['phoneNumber'],
      familyId: map['familyId'],
      childrenIds: map['childrenIds'] != null
          ? List<String>.from(map['childrenIds'])
          : null,
      totalSpent: map['totalSpent'] != null 
          ? (map['totalSpent'] as num).toDouble() 
          : null,
      parentId: map['parentId'],
      birthDate: map['birthDate'] != null
          ? DateTime.parse(map['birthDate'])
          : null,
      balance: map['balance'] != null 
          ? (map['balance'] as num).toDouble() 
          : null,
      totalEarned: map['totalEarned'] != null 
          ? (map['totalEarned'] as num).toDouble() 
          : null,
      completedJobIds: map['completedJobIds'] != null
          ? List<String>.from(map['completedJobIds'])
          : null,
      skillTags: map['skillTags'] != null
          ? List<String>.from(map['skillTags'])
          : null,
      resumeUrl: map['resumeUrl'],
      notificationSettings: map['notificationSettings'] != null
          ? Map<String, dynamic>.from(map['notificationSettings'])
          : null,
      preferredLanguage: map['preferredLanguage'],
      timezone: map['timezone'],
    );
  }

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String accountType;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEmailVerified;
  final bool isActive;
  final String? phoneNumber;
  final String? familyId;
  final List<String>? childrenIds;
  final double? totalSpent;
  final String? parentId;
  final DateTime? birthDate;
  final double? balance;
  final double? totalEarned;
  final List<String>? completedJobIds;
  final List<String>? skillTags;
  final String? resumeUrl;
  final Map<String, dynamic>? notificationSettings;
  final String? preferredLanguage;
  final String? timezone;

  // Computed properties
  String get fullName => '$firstName $lastName';

  bool get isAdult => accountType == 'adult';

  bool get isChild => accountType == 'child';

  int? get age {
    if (birthDate == null) {
      return null;
    }
    final now = DateTime.now();
    var age = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? accountType,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEmailVerified,
    bool? isActive,
    String? phoneNumber,
    String? familyId,
    List<String>? childrenIds,
    double? totalSpent,
    String? parentId,
    DateTime? birthDate,
    double? balance,
    double? totalEarned,
    List<String>? completedJobIds,
    List<String>? skillTags,
    String? resumeUrl,
    Map<String, dynamic>? notificationSettings,
    String? preferredLanguage,
    String? timezone,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      accountType: accountType ?? this.accountType,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isActive: isActive ?? this.isActive,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      familyId: familyId ?? this.familyId,
      childrenIds: childrenIds ?? this.childrenIds,
      totalSpent: totalSpent ?? this.totalSpent,
      parentId: parentId ?? this.parentId,
      birthDate: birthDate ?? this.birthDate,
      balance: balance ?? this.balance,
      totalEarned: totalEarned ?? this.totalEarned,
      completedJobIds: completedJobIds ?? this.completedJobIds,
      skillTags: skillTags ?? this.skillTags,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      timezone: timezone ?? this.timezone,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'accountType': accountType,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isEmailVerified': isEmailVerified,
      'isActive': isActive,
      'phoneNumber': phoneNumber,
      'familyId': familyId,
      'childrenIds': childrenIds,
      'totalSpent': totalSpent,
      'parentId': parentId,
      'birthDate': birthDate?.toIso8601String(),
      'balance': balance,
      'totalEarned': totalEarned,
      'completedJobIds': completedJobIds,
      'skillTags': skillTags,
      'resumeUrl': resumeUrl,
      'notificationSettings': notificationSettings,
      'preferredLanguage': preferredLanguage,
      'timezone': timezone,
    };
  }

  String toJson() => json.encode(toMap());
}