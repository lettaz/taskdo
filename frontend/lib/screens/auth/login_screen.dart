import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taskdo/blocs/auth/auth.dart';
import 'package:taskdo/config/routes.dart';
import 'package:taskdo/config/themes.dart';
import 'package:taskdo/utils/validators.dart';
import 'package:taskdo/widgets/common/custom_text_field.dart';
import 'package:taskdo/widgets/common/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthLoginRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              rememberMe: _rememberMe,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go(AppRouter.dashboard);
          } else if (state is AuthVerificationRequired) {
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
                    // App logo or icon
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: AppTheme.secondaryColor,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Title
                    const Text(
                      'Welcome Back',
                      style: AppTheme.heading1,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    
                    // Subtitle
                    Text(
                      'Sign in to continue using TaskDo',
                      style: AppTheme.bodyText.copyWith(
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    
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
                      hint: 'Enter your password',
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
                    const SizedBox(height: 16),
                    
                    // Remember me and forgot password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Remember me checkbox
                        Row(
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: _rememberMe,
                                onChanged: (value) {
                                  setState(() {
                                    _rememberMe = value ?? false;
                                  });
                                },
                                activeColor: AppTheme.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Remember me',
                              style: AppTheme.smallText.copyWith(
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                        
                        // Forgot password link
                        GestureDetector(
                          onTap: () {
                            context.push(AppRouter.passwordReset);
                          },
                          child: Text(
                            'Forgot Password?',
                            style: AppTheme.smallText.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Login button
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return PrimaryButton(
                          text: 'Sign In',
                          onPressed: _submitForm,
                          isLoading: state is AuthLoading,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Register link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account?',
                          style: AppTheme.smallText.copyWith(
                            color: Colors.grey.shade700,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.push(AppRouter.register);
                          },
                          child: Text(
                            'Sign Up',
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