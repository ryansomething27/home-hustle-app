import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../data/providers/auth_provider.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_indicator.dart';
import '../../navigation/routes.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  final String email;

  const VerificationScreen({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  bool _isResending = false;
  bool _isChecking = false;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;
  Timer? _verificationCheckTimer;

  @override
  void initState() {
    super.initState();
    _startVerificationCheck();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _verificationCheckTimer?.cancel();
    super.dispose();
  }

  void _startVerificationCheck() {
    // Check verification status every 3 seconds
    _verificationCheckTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _checkVerificationStatus(),
    );
  }

  Future<void> _checkVerificationStatus() async {
    if (_isChecking) return;

    setState(() => _isChecking = true);

    try {
      final authNotifier = ref.read(authProvider.notifier);
      final isVerified = await authNotifier.checkEmailVerification();

      if (isVerified && mounted) {
        _verificationCheckTimer?.cancel();
        
        // Get user and navigate to appropriate dashboard
        final user = ref.read(authProvider).value;
        if (user != null) {
          String route;
          switch (user.role) {
            case UserRole.parent:
              route = Routes.parentHome;
              break;
            case UserRole.child:
              route = Routes.childHome;
              break;
            case UserRole.employer:
              route = Routes.employerHome;
              break;
          }
          Navigator.of(context).pushReplacementNamed(route);
        }
      }
    } catch (e) {
      // Silently handle errors during automatic checks
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    if (_resendCooldown > 0) return;

    setState(() => _isResending = true);

    try {
      final authNotifier = ref.read(authProvider.notifier);
      final result = await authNotifier.resendVerificationEmail();

      if (result.success && mounted) {
        _startResendCooldown();
        _showSuccessSnackBar('Verification email sent!');
      } else if (mounted) {
        _showErrorSnackBar(result.error ?? 'Failed to send email');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('An unexpected error occurred');
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  void _startResendCooldown() {
    setState(() => _resendCooldown = 60);

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown > 0) {
        setState(() => _resendCooldown--);
      } else {
        timer.cancel();
      }
    });
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Email Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.cream.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.email_outlined,
                    size: 60,
                    color: AppColors.cream,
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  'Verify Your Email',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.cream,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  'We\'ve sent a verification email to:',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.cream.withOpacity(0.7),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Email
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cream.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.email,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.cream,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(height: 32),

                // Instructions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cream.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.cream.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.cream.withOpacity(0.7),
                        size: 24,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Please check your email and click the verification link to activate your account.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.cream.withOpacity(0.7),
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This page will automatically redirect once your email is verified.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.cream.withOpacity(0.5),
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Checking Status Indicator
                if (_isChecking)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cream.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const LoadingIndicator(size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Checking verification status...',
                          style: TextStyle(
                            color: AppColors.cream.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 32),

                // Resend Button
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    onPressed: (_isResending || _resendCooldown > 0)
                        ? null
                        : _resendVerificationEmail,
                    variant: ButtonVariant.secondary,
                    child: _isResending
                        ? const LoadingIndicator(size: 20)
                        : Text(
                            _resendCooldown > 0
                                ? 'Resend in ${_resendCooldown}s'
                                : 'Resend Verification Email',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Manual Check Button
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    onPressed: _isChecking ? null : _checkVerificationStatus,
                    child: _isChecking
                        ? const LoadingIndicator(size: 20)
                        : const Text(
                            'I\'ve Verified My Email',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: AppColors.cream.withOpacity(0.2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Having trouble?',
                        style: TextStyle(
                          color: AppColors.cream.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: AppColors.cream.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Help Text
                Text(
                  'Can\'t find the email? Check your spam folder.',
                  style: TextStyle(
                    color: AppColors.cream.withOpacity(0.7),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Back to Login
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed(Routes.login);
                  },
                  child: Text(
                    'Back to Login',
                    style: TextStyle(
                      color: AppColors.cream,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}