import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../constants/colors.dart';
import '../services/auth_service.dart';
import '../utils/snackbar_helper.dart';
import 'onboarding_screen.dart';
import 'verify_email_screen.dart';

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
  bool _isSubmitting = false;

  bool get _isFormFilled =>
      _firstNameController.text.trim().isNotEmpty &&
      _lastNameController.text.trim().isNotEmpty &&
      _emailController.text.trim().isNotEmpty &&
      _passwordController.text.isNotEmpty &&
      _confirmPasswordController.text.isNotEmpty;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final result = await context.read<AuthService>().register(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      );

      if (!mounted) return;

      showAppSnackBar(context, result.message);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => VerifyEmailScreen(
            email: result.user.email,
            expiresInMinutes: result.expiresInMinutes,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      showAppSnackBar(context, error.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
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
            onTap: () {
              final navigator = Navigator.of(context);
              if (navigator.canPop()) {
                navigator.pop();
              } else {
                navigator.pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const OnboardingScreen(),
                  ),
                );
              }
            },
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
      onChanged: (_) => setState(() {}),
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
      onChanged: (_) => setState(() {}),
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
      onChanged: (_) => setState(() {}),
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
      onChanged: (_) => setState(() {}),
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
      onChanged: (_) => setState(() {}),
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
    const fieldRadius = Radius.circular(999);

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
        borderRadius: const BorderRadius.all(fieldRadius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(fieldRadius),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(fieldRadius),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(fieldRadius),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: !_isFormFilled || _isSubmitting
            ? null
            : _register,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.55),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
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
