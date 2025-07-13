import '../constants.dart';

/// Utility class containing all form validation functions used throughout the app
class Validators {
  // Private constructor to prevent instantiation
  Validators._();
  
  /// Email validation regex pattern
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  
  /// Phone number validation regex (US format)
  static final RegExp _phoneRegExp = RegExp(
    r'^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$',
  );
  
  /// Name validation regex (letters, spaces, hyphens, apostrophes)
  static final RegExp _nameRegExp = RegExp(
    r"^[a-zA-Z\s\-']+$",
  );
  
  /// Validates email address
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final trimmedValue = value.trim();
    if (!_emailRegExp.hasMatch(trimmedValue)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }
  
  /// Validates password with specific requirements
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < kMinPasswordLength) {
      return 'Password must be at least $kMinPasswordLength characters';
    }
    
    if (value.length > kMaxPasswordLength) {
      return 'Password must be less than $kMaxPasswordLength characters';
    }
    
    // Check for at least one uppercase letter
    if (!value.contains(RegExp('[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    
    // Check for at least one lowercase letter
    if (!value.contains(RegExp('[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    
    // Check for at least one number
    if (!value.contains(RegExp('[0-9]'))) {
      return 'Password must contain at least one number';
    }
    
    // Check for at least one special character
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    
    return null;
  }
  
  /// Validates password confirmation matches
  static String? validatePasswordConfirmation(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }
  
  /// Validates first or last name
  static String? validateName(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    final trimmedValue = value.trim();
    if (trimmedValue.length < 2) {
      return '$fieldName must be at least 2 characters';
    }
    
    if (trimmedValue.length > 50) {
      return '$fieldName must be less than 50 characters';
    }
    
    if (!_nameRegExp.hasMatch(trimmedValue)) {
      return '$fieldName can only contain letters, spaces, hyphens, and apostrophes';
    }
    
    return null;
  }
  
  /// Validates phone number (optional field)
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone number is optional
    }
    
    final cleanedValue = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanedValue.length != 10) {
      return 'Please enter a valid 10-digit phone number';
    }
    
    if (!_phoneRegExp.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }
  
  /// Validates currency/wage amount
  static String? validateCurrency(String? value, {
    double? minAmount,
    double? maxAmount,
    bool required = true,
  }) {
    if (value == null || value.isEmpty) {
      return required ? 'Amount is required' : null;
    }
    
    // Remove currency symbols and commas
    final cleanedValue = value.replaceAll(RegExp(r'[$,]'), '').trim();
    
    final amount = double.tryParse(cleanedValue);
    if (amount == null) {
      return 'Please enter a valid amount';
    }
    
    if (amount < 0) {
      return 'Amount cannot be negative';
    }
    
    if (minAmount != null && amount < minAmount) {
      return 'Amount must be at least \$${minAmount.toStringAsFixed(2)}';
    }
    
    if (maxAmount != null && amount > maxAmount) {
      return 'Amount cannot exceed \$${maxAmount.toStringAsFixed(2)}';
    }
    
    // Check for reasonable decimal places
    final parts = cleanedValue.split('.');
    if (parts.length > 1 && parts[1].length > 2) {
      return 'Amount can only have up to 2 decimal places';
    }
    
    return null;
  }
  
  /// Validates age for child accounts
  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Age is required';
    }
    
    final age = int.tryParse(value);
    if (age == null) {
      return 'Please enter a valid age';
    }
    
    if (age < 4) {
      return 'Child must be at least 4 years old';
    }
    
    if (age >= 18) {
      return 'Child must be under 18 years old';
    }
    
    return null;
  }
  
  /// Validates birth date for child accounts
  static String? validateBirthDate(DateTime? birthDate) {
    if (birthDate == null) {
      return 'Birth date is required';
    }
    
    final now = DateTime.now();
    final age = now.year - birthDate.year;
    final adjustedAge = now.isBefore(
      DateTime(now.year, birthDate.month, birthDate.day),
    ) ? age - 1 : age;
    
    if (adjustedAge < 4) {
      return 'Child must be at least 4 years old';
    }
    
    if (adjustedAge >= 18) {
      return 'Child must be under 18 years old';
    }
    
    if (birthDate.isAfter(now)) {
      return 'Birth date cannot be in the future';
    }
    
    return null;
  }
  
  /// Validates job title
  static String? validateJobTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Job title is required';
    }
    
    final trimmedValue = value.trim();
    if (trimmedValue.length < 3) {
      return 'Job title must be at least 3 characters';
    }
    
    if (trimmedValue.length > 100) {
      return 'Job title must be less than 100 characters';
    }
    
    return null;
  }
  
  /// Validates job description
  static String? validateJobDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Job description is required';
    }
    
    final trimmedValue = value.trim();
    if (trimmedValue.length < 10) {
      return 'Job description must be at least 10 characters';
    }
    
    if (trimmedValue.length > 1000) {
      return 'Job description must be less than 1000 characters';
    }
    
    return null;
  }
  
  /// Validates parent invite code
  static String? validateInviteCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Invite code is required';
    }
    
    final trimmedValue = value.trim().toUpperCase();
    if (trimmedValue.length != 6) {
      return 'Invite code must be 6 characters';
    }
    
    // Check if it's alphanumeric
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(trimmedValue)) {
      return 'Invite code can only contain letters and numbers';
    }
    
    return null;
  }
  
  /// Validates general text field with custom requirements
  static String? validateTextField(
    String? value, {
    required String fieldName,
    bool required = true,
    int? minLength,
    int? maxLength,
    RegExp? pattern,
    String? patternMessage,
  }) {
    if (value == null || value.isEmpty) {
      return required ? '$fieldName is required' : null;
    }
    
    final trimmedValue = value.trim();
    
    if (minLength != null && trimmedValue.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    
    if (maxLength != null && trimmedValue.length > maxLength) {
      return '$fieldName must be less than $maxLength characters';
    }
    
    if (pattern != null && !pattern.hasMatch(trimmedValue)) {
      return patternMessage ?? 'Invalid $fieldName format';
    }
    
    return null;
  }
  
  /// Validates a URL
  static String? validateUrl(String? value, {bool required = false}) {
    if (value == null || value.isEmpty) {
      return required ? 'URL is required' : null;
    }
    
    final trimmedValue = value.trim();
    
    // Basic URL validation
    try {
      final uri = Uri.parse(trimmedValue);
      if (!uri.isAbsolute) {
        return 'Please enter a valid URL';
      }
      if (!['http', 'https'].contains(uri.scheme)) {
        return 'URL must start with http:// or https://';
      }
    } on FormatException {
      return 'Please enter a valid URL';
    }
    
    return null;
  }
  
  /// Validates selection from a list of options
  static String? validateSelection<T>(T? value, {
    required String fieldName,
    required List<T> validOptions,
  }) {
    if (value == null) {
      return '$fieldName is required';
    }
    
    if (!validOptions.contains(value)) {
      return 'Please select a valid $fieldName';
    }
    
    return null;
  }
  
  /// Validates a numeric value within a range
  static String? validateNumber(
    String? value, {
    required String fieldName,
    bool required = true,
    num? min,
    num? max,
    bool allowDecimals = true,
  }) {
    if (value == null || value.isEmpty) {
      return required ? '$fieldName is required' : null;
    }
    
    final number = allowDecimals ? double.tryParse(value) : int.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }
    
    if (min != null && number < min) {
      return '$fieldName must be at least $min';
    }
    
    if (max != null && number > max) {
      return '$fieldName cannot exceed $max';
    }
    
    return null;
  }
}