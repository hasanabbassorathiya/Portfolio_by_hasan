import 'package:firebase_auth/firebase_auth.dart';
/// Admin login screen
/// Provides authentication for admin panel access
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/services/supabase_service.dart';
import 'package:portfolio/shared/constants/colors.dart';
import 'package:portfolio/shared/constants/textstyles.dart';
import 'package:portfolio/shared/constants/utils.dart';
import 'package:portfolio/shared/routes/app_routes.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isResettingPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (!SupabaseService.isInitialized) {
        throw Exception('Supabase not initialized. Please configure SUPABASE_URL and SUPABASE_ANON_KEY.');
      }
      
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        context.go(AppRoutes.adminDashboard);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: Colors.red,
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

  /// Get the redirect URL for password reset
  /// For web, constructs the URL from current location including port
  String? _getRedirectUrl() {
    if (kIsWeb) {
      try {
        // For web, use the full URL including port for localhost
        // This must match exactly what's configured in Supabase
        final uri = Uri.base;
        final port = uri.hasPort ? ':${uri.port}' : '';
        final redirectUrl = '${uri.scheme}://${uri.host}$port${AppRoutes.adminResetPassword}';
        
        developer.log(
          'Generated redirect URL: $redirectUrl',
          name: 'AdminLogin',
        );
        
        return redirectUrl;
      } catch (e) {
        developer.log('Failed to get redirect URL: $e');
        return null;
      }
    }
    return null;
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    
    if (email.isEmpty || !email.contains('@')) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid email address'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() {
      _isResettingPassword = true;
    });

    try {
      if (!SupabaseService.isInitialized) {
        throw Exception(
          'Supabase not initialized. Please configure SUPABASE_URL and SUPABASE_ANON_KEY.',
        );
      }

      developer.log(
        'Attempting to send password reset email',
        name: 'AdminLogin',
      );

      final redirectUrl = _getRedirectUrl();
      developer.log(
        'Redirect URL: ${redirectUrl ?? "using default"}',
        name: 'AdminLogin',
      );

      await SupabaseService.auth!.resetPasswordForEmail(
        email,
        redirectTo: redirectUrl,
      );

      developer.log(
        'Password reset email sent successfully',
        name: 'AdminLogin',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Password reset email sent to $email. Please check your inbox and spam folder.',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 6),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e, stackTrace) {
      developer.log(
        'Failed to send password reset email',
        name: 'AdminLogin',
        error: e,
        stackTrace: stackTrace,
      );

      String errorMessage = 'Failed to send reset email. ';
      
      // Provide more helpful error messages
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('email') && errorString.contains('not found')) {
        errorMessage += 'This email is not registered.';
      } else if (errorString.contains('rate limit')) {
        errorMessage += 'Too many requests. Please try again later.';
      } else if (errorString.contains('redirect')) {
        errorMessage +=
            'Redirect URL not configured. Please check Supabase settings.';
      } else {
        errorMessage += 'Error: ${e.toString()}';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResettingPassword = false;
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
                      'Admin Panel',
                      style: AppStyles.heading(
                        fontSize: isSmall ? 32 : 48,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    AppUtils().vSpace(size: 8),
                    Text(
                      'Sign in to manage your portfolio',
                      style: AppStyles.body(),
                      textAlign: TextAlign.center,
                    ),
                    AppUtils().vSpace(size: 40),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    AppUtils().vSpace(size: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
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
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    AppUtils().vSpace(size: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _isResettingPassword || _isLoading
                            ? null
                            : _resetPassword,
                        child: _isResettingPassword
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Forgot Password?',
                                style: AppStyles.body(
                                  color: AppColors.primaryColor,
                                ),
                              ),
                      ),
                    ),
                    AppUtils().vSpace(size: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: AppColors.primaryColor,
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : Text(
                                'Sign In',
                                style: AppStyles.heading(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
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
