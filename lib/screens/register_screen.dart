import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(),
                const SizedBox(height: 26),
                Text(
                  'Create Account',
                  style: GoogleFonts.nunito(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your details to register a new account.',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    height: 1.55,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 26),
                _buildFirstNameField(),
                const SizedBox(height: 14),
                _buildLastNameField(),
                const SizedBox(height: 14),
                _buildEmailField(),
                const SizedBox(height: 14),
                _buildPasswordField(),
                const SizedBox(height: 14),
                _buildConfirmPasswordField(),
                const SizedBox(height: 26),
                _buildRegisterButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        Transform.translate(
          offset: const Offset(-6, 0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE8E8E8)),
              ),
              child: const Icon(
                Icons.chevron_left,
                color: AppColors.textPrimary,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFirstNameField() {
    return TextFormField(
      controller: _firstNameController,
      style: _fieldTextStyle(),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your first name';
        }
        return null;
      },
      decoration: _inputDecoration(
        hint: 'First Name',
        prefix: Icons.person_outline,
      ),
    );
  }

  Widget _buildLastNameField() {
    return TextFormField(
      controller: _lastNameController,
      style: _fieldTextStyle(),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your last name';
        }
        return null;
      },
      decoration: _inputDecoration(
        hint: 'Last Name',
        prefix: Icons.badge_outlined,
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: _fieldTextStyle(),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your email';
        }
        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
        if (!emailRegex.hasMatch(value.trim())) {
          return 'Please enter a valid email';
        }
        return null;
      },
      decoration: _inputDecoration(
        hint: 'Email',
        prefix: Icons.email_outlined,
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: _fieldTextStyle(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
      decoration: _inputDecoration(
        hint: 'Password',
        prefix: Icons.lock_outline,
        suffix: IconButton(
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      style: _fieldTextStyle(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please confirm your password';
        }
        if (value != _passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
      decoration: _inputDecoration(
        hint: 'Confirm Password',
        prefix: Icons.lock_outline,
        suffix: IconButton(
          onPressed: () => setState(
            () => _obscureConfirmPassword = !_obscureConfirmPassword,
          ),
          icon: Icon(
            _obscureConfirmPassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  TextStyle _fieldTextStyle() {
    return GoogleFonts.nunito(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefix,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
      prefixIcon: Icon(prefix, color: AppColors.textSecondary),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF7F7F7),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          _formKey.currentState!.validate();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Text(
          'Register',
          style: GoogleFonts.nunito(
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
