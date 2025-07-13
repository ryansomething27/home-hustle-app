import 'dart:convert';

class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String accountType; // 'adult' or 'child'
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEmailVerified;
  final bool isActive;
  
  // Adult-specific fields
  final String? phoneNumber;
  final String? familyId;
  final List<String>? childrenIds;
  final double? totalSpent;
  
  // Child-specific fields
  final String? parentId;
  final DateTime? birthDate;
  final double? balance;
  final double? totalEarned;
  final List<String>? completedJobIds;
  final List<String>? skillTags;
  final String? resumeUrl;
  
  // Settings
  final Map<String, dynamic>? notificationSettings;
  final String? preferredLanguage;
  final String? timezone;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.accountType,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
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

  // Computed properties
  String get fullName => '$firstName $lastName';
  
  bool get isAdult => accountType == 'adult';
  
  bool get isChild => accountType == 'child';
  
  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  // JSON serialization
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
      totalSpent: map['totalSpent']?.toDouble(),
      parentId: map['parentId'],
      birthDate: map['birthDate'] != null 
          ? DateTime.parse(map['birthDate']) 
          : null,
      balance: map['balance']?.toDouble(),
      totalEarned: map['totalEarned']?.toDouble(),
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

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) => 
      UserModel.fromMap(json.decode(source));

  // CopyWith method for immutability
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is UserModel &&
      other.id == id &&
      other.email == email &&
      other.firstName == firstName &&
      other.lastName == lastName &&
      other.accountType == accountType;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      email.hashCode ^
      firstName.hashCode ^
      lastName.hashCode ^
      accountType.hashCode;
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, fullName: $fullName, accountType: $accountType)';
  }
}