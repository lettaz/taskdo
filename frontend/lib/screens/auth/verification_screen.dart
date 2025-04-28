import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taskdo/blocs/auth/auth.dart';
import 'package:taskdo/config/routes.dart';
import 'package:taskdo/config/themes.dart';
import 'package:taskdo/widgets/common/primary_button.dart';

class VerificationScreen extends StatefulWidget {
  final String email;

  const VerificationScreen({
    super.key,
    required this.email,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (_) => FocusNode(),
  );

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _submitCode() {
    final code = _controllers.map((controller) => controller.text.trim()).join();
    print('Verification: Submitting code for ${widget.email}: $code');
    if (code.length == 6) {
      // Hide keyboard
      FocusManager.instance.primaryFocus?.unfocus();
      
      print('Verification: Dispatching verification event');
      context.read<AuthBloc>().add(
            AuthVerificationRequested(
              email: widget.email,
              code: code,
            ),
          );
    } else {
      print('Verification: Code incomplete (length: ${code.length})');
    }
  }

  void _requestNewCode() {
    // Clear existing code fields
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
    
    // Here you would typically call the backend to request a new code
    // For now, we'll just show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('A new verification code has been sent to your email'),
        backgroundColor: AppTheme.successColor,
      ),
    );
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
          if (state is AuthAuthenticated) {
            // Navigate to dashboard
            context.go(AppRouter.dashboard);
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const Text(
                    'Verify Your Email',
                    style: AppTheme.heading1,
                  ),
                  const SizedBox(height: 8),
                  
                  // Subtitle with email
                  RichText(
                    text: TextSpan(
                      style: AppTheme.bodyText.copyWith(
                        color: Colors.grey.shade600,
                      ),
                      children: [
                        const TextSpan(
                          text: 'We\'ve sent a verification code to ',
                        ),
                        TextSpan(
                          text: widget.email,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Verification code input
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      6,
                      (index) => SizedBox(
                        width: 45,
                        height: 55,
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AppTheme.dividerColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AppTheme.primaryColor),
                            ),
                            counterText: "",
                          ),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          autofocus: index == 0,
                          onChanged: (value) {
                            // Allow only one character
                            if (value.length > 1) {
                              _controllers[index].text = value[0];
                            }
                            
                            // Auto focus to next field
                            if (value.isNotEmpty && index < 5) {
                              _focusNodes[index + 1].requestFocus();
                            } else if (value.isEmpty && index > 0) {
                              // If deleting, go back to previous field
                              _focusNodes[index - 1].requestFocus();
                            }
                            
                            // Check if all fields are filled
                            if (_controllers.every((controller) => controller.text.isNotEmpty)) {
                              _submitCode();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Verify button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return PrimaryButton(
                        text: 'Verify Email',
                        onPressed: _submitCode,
                        isLoading: state is AuthLoading,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Resend code
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Didn\'t receive a code?',
                        style: AppTheme.smallText.copyWith(
                          color: Colors.grey.shade700,
                        ),
                      ),
                      TextButton(
                        onPressed: _requestNewCode,
                        child: Text(
                          'Resend',
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
    );
  }
} 