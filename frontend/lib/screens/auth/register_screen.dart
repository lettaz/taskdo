import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taskdo/blocs/auth/auth.dart';
import 'package:taskdo/config/routes.dart';
import 'package:taskdo/config/themes.dart';
import 'package:taskdo/utils/validators.dart';
import 'package:taskdo/widgets/common/custom_text_field.dart';
import 'package:taskdo/widgets/common/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthRegisterRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
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
          if (state is AuthVerificationRequired) {
            // Navigate to verification screen with email
            context.push(
              AppRouter.verification,
              extra: {'email': state.email},
            );
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
                      'Create Account',
                      style: AppTheme.heading1,
                    ),
                    const SizedBox(height: 8),
                    
                    // Subtitle
                    Text(
                      'Sign up to start using TaskDo',
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
                    ),
                    const SizedBox(height: 20),
                    
                    // Password field
                    CustomTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: 'Create a password',
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
                    
                    // Confirm Password field
                    CustomTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      hint: 'Confirm your password',
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
                        _passwordController.text,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Register button
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return PrimaryButton(
                          text: 'Sign Up',
                          onPressed: _submitForm,
                          isLoading: state is AuthLoading,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: AppTheme.smallText.copyWith(
                            color: Colors.grey.shade700,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.go(AppRouter.login);
                          },
                          child: Text(
                            'Sign In',
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