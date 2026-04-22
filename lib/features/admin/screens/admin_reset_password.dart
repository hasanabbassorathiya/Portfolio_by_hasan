import 'package:firebase_auth/firebase_auth.dart';
/// Admin password reset screen
/// Handles password reset after user clicks the recovery link from email
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:portfolio/core/services/supabase_service.dart';
import 'package:portfolio/shared/constants/colors.dart';
import 'package:portfolio/shared/constants/textstyles.dart';
import 'package:portfolio/shared/constants/utils.dart';
import 'package:portfolio/shared/routes/app_routes.dart';

class AdminResetPasswordScreen extends StatefulWidget {
  const AdminResetPasswordScreen({super.key});

  @override
  State<AdminResetPasswordScreen> createState() =>
      _AdminResetPasswordScreenState();
}

class _AdminResetPasswordScreenState extends State<AdminResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _handleRecoveryToken();
    _listenToAuthChanges();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    SupabaseService.auth?.onAuthStateChange.listen((data) {}).cancel();
    super.dispose();
  }

  /// Listen to auth state changes to detect recovery session
  void _listenToAuthChanges() {
    SupabaseService.auth?.onAuthStateChange.listen((data) {
      developer.log(
        'Auth state changed: ${data.event}, session: ${data.session != null}',
        name: 'AdminResetPassword',
      );
      
      if (data.event == AuthChangeEvent.passwordRecovery || 
          data.event == AuthChangeEvent.signedIn) {
        developer.log(
          'Recovery session detected',
          name: 'AdminResetPassword',
        );
        if (mounted) {
          setState(() {
            _errorMessage = null;
          });
        }
      } else if (data.event == AuthChangeEvent.signedOut) {
        developer.log(
          'User signed out - recovery session lost',
          name: 'AdminResetPassword',
        );
        if (mounted) {
          setState(() {
            _errorMessage = 'Session expired. Please request a new password reset.';
          });
        }
      }
    });
  }

  /// Handle recovery token from URL
  Future<void> _handleRecoveryToken() async {
    if (!SupabaseService.isInitialized) {
      setState(() {
        _errorMessage =
            'Supabase not initialized. Please configure SUPABASE_URL and SUPABASE_ANON_KEY.';
      });
      return;
    }

    try {
      // Check URL for recovery token (both query params and hash fragments)
      final uri = Uri.base;
      
      developer.log(
        'Full URL: ${uri.toString()}',
        name: 'AdminResetPassword',
      );
      developer.log(
        'Query params: ${uri.queryParameters}',
        name: 'AdminResetPassword',
      );
      developer.log(
        'Fragment: ${uri.fragment}',
        name: 'AdminResetPassword',
      );
      
      // Try query parameters first
      String? tokenHash = uri.queryParameters['token_hash'];
      String? token = uri.queryParameters['token']; // Token from email link
      String? type = uri.queryParameters['type'];
      String? accessToken;
      
      // Check hash fragment for access_token (Supabase puts it here after redirect)
      if (uri.fragment.isNotEmpty) {
        final fragmentParams = uri.fragment.split('&');
        for (final param in fragmentParams) {
          if (param.startsWith('access_token=')) {
            accessToken = param.replaceFirst('access_token=', '').split('&').first;
          } else if (param.startsWith('token_hash=')) {
            tokenHash = param.replaceFirst('token_hash=', '').split('&').first;
          } else if (param.startsWith('token=')) {
            token = param.replaceFirst('token=', '').split('&').first;
          } else if (param.startsWith('type=')) {
            type = param.replaceFirst('type=', '').split('&').first;
          }
        }
      }
      
      // Use token if token_hash is not available
      if (tokenHash == null && token != null) {
        tokenHash = token;
      }
      
      final hasToken = (tokenHash != null && tokenHash.isNotEmpty) ||
                       (accessToken != null && accessToken.isNotEmpty);
      final isRecoveryType = type == 'recovery';
      
      developer.log(
        'Token check - token_hash: ${tokenHash != null}, access_token: ${accessToken != null}, type: $type, isRecovery: $isRecoveryType',
        name: 'AdminResetPassword',
      );

      // If we have a token_hash, try to verify it manually
      if (tokenHash != null && isRecoveryType) {
        developer.log(
          'Found token_hash, attempting to verify OTP...',
          name: 'AdminResetPassword',
        );
        
        try {
          // Try to verify the OTP token
          final response = await SupabaseService.auth!.verifyOTP(
            type: OtpType.recovery,
            token: tokenHash,
          );
          
          developer.log(
            'OTP verified successfully: ${response.user?.email}',
            name: 'AdminResetPassword',
          );
          
          // Wait a moment for session to be established
          await Future.delayed(const Duration(milliseconds: 500));
        } catch (e) {
          developer.log(
            'Failed to verify OTP: $e',
            name: 'AdminResetPassword',
            error: e,
          );
          // Continue to check session anyway
        }
      }
      
      // If we have an access token in the fragment, Supabase should have processed it
      // Wait a bit longer for Supabase to establish the session
      if (accessToken != null || tokenHash != null) {
        developer.log(
          'Token found, waiting for Supabase to process...',
          name: 'AdminResetPassword',
        );
        
        // Wait longer for Supabase to process the token
        // Supabase Flutter SDK should automatically handle hash fragments
        for (int i = 0; i < 10; i++) {
          await Future.delayed(const Duration(milliseconds: 500));
          final session = SupabaseService.auth!.currentSession;
          if (session != null) {
            developer.log(
              'Session established after ${(i + 1) * 500}ms',
              name: 'AdminResetPassword',
            );
            break;
          }
          
          // Log progress
          if (i % 2 == 0) {
            developer.log(
              'Still waiting for session... (${(i + 1) * 500}ms)',
              name: 'AdminResetPassword',
            );
          }
        }
      } else {
        // No token in URL, wait a bit anyway in case it's being processed
        await Future.delayed(const Duration(milliseconds: 1500));
      }
      
      // Check if we now have a session
      final session = SupabaseService.auth!.currentSession;
      
      if (session == null) {
        // Check if we have token in URL but no session (token might be expired/invalid)
        if (hasToken && isRecoveryType) {
          developer.log(
            'Token found in URL but no session established after waiting.',
            name: 'AdminResetPassword',
          );
          developer.log(
            'This usually means: 1) Token expired, 2) Token already used, 3) Redirect URL mismatch in Supabase settings',
            name: 'AdminResetPassword',
          );
          
          // Provide helpful error message
          setState(() {
            _errorMessage =
                'Unable to process reset link. This may happen if:\n'
                '• The link has expired (links expire after 1 hour)\n'
                '• The link was already used\n'
                '• The redirect URL doesn\'t match Supabase settings\n\n'
                'Please request a new password reset from the login page.';
          });
        } else {
          developer.log(
            'No recovery token in URL and no session. User needs to click the email link.',
            name: 'AdminResetPassword',
          );
          setState(() {
            _errorMessage =
                'Please click the password reset link from your email to continue. If you don\'t have the email, request a new one from the login page.';
          });
        }
      } else {
        developer.log(
          'Recovery session established successfully for user: ${session.user.email}',
          name: 'AdminResetPassword',
        );
        setState(() {
          _errorMessage = null;
        });
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error handling recovery token: $e',
        name: 'AdminResetPassword',
        error: e,
        stackTrace: stackTrace,
      );
      setState(() {
        _errorMessage =
            'Error processing reset link: ${e.toString()}. Please try requesting a new password reset.';
      });
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (!SupabaseService.isInitialized) {
        throw Exception(
          'Supabase not initialized. Please configure SUPABASE_URL and SUPABASE_ANON_KEY.',
        );
      }

      developer.log(
        'Attempting to update password',
        name: 'AdminResetPassword',
      );

      // Check if we have a valid session first
      final session = SupabaseService.auth!.currentSession;
      if (session == null) {
        throw Exception(
          'No active session. Please click the password reset link from your email first.',
        );
      }

      developer.log(
        'Session found, updating password...',
        name: 'AdminResetPassword',
      );

      // Update the password using Supabase
      final response = await SupabaseService.auth!.updateUser(
        UserAttributes(password: password),
      );

      if (response.user == null) {
        throw Exception('Failed to update password. Please try again.');
      }

      developer.log(
        'Password updated successfully for user: ${response.user?.email}',
        name: 'AdminResetPassword',
      );

      developer.log(
        'Password updated successfully',
        name: 'AdminResetPassword',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Password reset successfully! You can now login with your new password.',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );

        // Navigate to login after a short delay
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          context.go(AppRoutes.adminLogin);
        }
      }
    } catch (e, stackTrace) {
      developer.log(
        'Failed to reset password',
        name: 'AdminResetPassword',
        error: e,
        stackTrace: stackTrace,
      );

      String errorMessage = 'Failed to reset password. ';

      final errorString = e.toString().toLowerCase();
      if (errorString.contains('session') || errorString.contains('token')) {
        errorMessage +=
            'Your reset link may have expired. Please request a new password reset.';
      } else if (errorString.contains('weak')) {
        errorMessage += 'Password is too weak. Please choose a stronger password.';
      } else {
        errorMessage += 'Error: ${e.toString()}';
      }

      setState(() {
        _errorMessage = errorMessage;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppUtils().appGradient),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isSmall ? 24 : 48),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              padding: EdgeInsets.all(isSmall ? 32 : 48),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Reset Password',
                      style: AppStyles.heading(
                        fontSize: isSmall ? 32 : 48,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    AppUtils().vSpace(size: 8),
                    Text(
                      'Enter your new password',
                      style: AppStyles.body(),
                      textAlign: TextAlign.center,
                    ),
                    if (_errorMessage != null) ...[
                      AppUtils().vSpace(size: 24),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: AppStyles.body(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    AppUtils().vSpace(size: 40),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    AppUtils().vSpace(size: 20),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    AppUtils().vSpace(size: 32),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _resetPassword,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: AppColors.primaryColor,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Reset Password',
                              style: AppStyles.heading(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                    ),
                    AppUtils().vSpace(size: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () => context.go(AppRoutes.adminLogin),
                          child: Text(
                            'Back to Login',
                            style: AppStyles.body(
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                        if (_errorMessage != null &&
                            _errorMessage!.contains('expired')) ...[
                          const SizedBox(width: 16),
                          TextButton(
                            onPressed: () {
                              context.go(AppRoutes.adminLogin);
                              // Show a message to request new reset
                              Future.delayed(const Duration(milliseconds: 500), () {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please click "Forgot Password?" on the login page to request a new reset email.',
                                      ),
                                      duration: Duration(seconds: 5),
                                    ),
                                  );
                                }
                              });
                            },
                            child: Text(
                              'Request New Reset',
                              style: AppStyles.body(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

