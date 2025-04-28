import 'package:flutter/material.dart';
import 'package:taskdo/config/themes.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final EdgeInsets? contentPadding;
  final bool autofocus;
  final bool enabled;

  const CustomTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.contentPadding,
    this.autofocus = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              label!,
              style: AppTheme.smallText.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          autofocus: autofocus,
          enabled: enabled,
          style: AppTheme.bodyText,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            suffixIcon: suffixIcon,
            contentPadding: contentPadding,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.primaryColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.errorColor),
            ),
          ),
        ),
      ],
    );
  }
} 