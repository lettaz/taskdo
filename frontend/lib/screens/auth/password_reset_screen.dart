import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taskdo/blocs/auth/auth.dart';
import 'package:taskdo/config/routes.dart';
import 'package:taskdo/config/themes.dart';
import 'package:taskdo/utils/validators.dart';
import 'package:taskdo/widgets/common/custom_text_field.dart';
import 'package:taskdo/widgets/common/primary_button.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _codeSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    });
  }

  void _requestResetCode() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthPasswordResetRequested(
              email: _emailController.text.trim(),
            ),
          );
    }
  }

  void _resetPassword() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthPasswordResetConfirmationRequested(
              email: _emailController.text.trim(),
              code: _codeController.text.trim(),
              newPassword: _newPasswordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthPasswordResetSent) {
            setState(() {
              _codeSent = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password reset code sent to your email'),
                backgroundColor: AppTheme.successColor,
              ),
            );
          } else if (state is AuthPasswordResetSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password reset successful'),
                backgroundColor: AppTheme.successColor,
              ),
            );
            context.go(AppRouter.login);
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    const Text(
                      'Reset Password',
                      style: AppTheme.heading1,
                    ),
                    const SizedBox(height: 8),
                    
                    // Subtitle
                    Text(
                      _codeSent
                          ? 'Enter the code sent to your email'
                          : 'Enter your email to receive a password reset code',
                      style: AppTheme.bodyText.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Email field
                    CustomTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: Validators.validateEmail,
                      enabled: !_codeSent, // Disable after code is sent
                    ),
                    
                    if (_codeSent) ...[
                      const SizedBox(height: 20),
                      
                      // Code field
                      CustomTextField(
                        controller: _codeController,
                        label: 'Reset Code',
                        hint: 'Enter the code from your email',
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.lock_clock_outlined,
                        validator: (value) => Validators.validateRequired(
                          value,
                          'Reset code',
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // New password field
                      CustomTextField(
                        controller: _newPasswordController,
                        label: 'New Password',
                        hint: 'Create a new password',
                        obscureText: !_isPasswordVisible,
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.grey,
                          ),
                          onPressed: _togglePasswordVisibility,
                        ),
                        validator: Validators.validatePassword,
                      ),
                      const SizedBox(height: 20),
                      
                      // Confirm password field
                      CustomTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password',
                        hint: 'Confirm your new password',
                        obscureText: !_isConfirmPasswordVisible,
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmPasswordVisible
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.grey,
                          ),
                          onPressed: _toggleConfirmPasswordVisibility,
                        ),
                        validator: (value) => Validators.validatePasswordConfirmation(
                          value,
                          _newPasswordController.text,
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    
                    // Action button
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return PrimaryButton(
                          text: _codeSent ? 'Reset Password' : 'Send Reset Code',
                          onPressed: _codeSent ? _resetPassword : _requestResetCode,
                          isLoading: state is AuthLoading,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Back to login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Remember your password?',
                          style: AppTheme.smallText.copyWith(
                            color: Colors.grey.shade700,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.go(AppRouter.login);
                          },
                          child: Text(
                            'Login',
                            style: AppTheme.smallText.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
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