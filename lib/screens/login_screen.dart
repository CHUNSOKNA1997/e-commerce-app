import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../constants/colors.dart';
import '../state/auth_state.dart';
import '../utils/snackbar_helper.dart';
import 'forgot_password_screen.dart';
import 'main_shell.dart';
import 'onboarding_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  bool get _isFormFilled =>
      _emailController.text.trim().isNotEmpty &&
      _passwordController.text.isNotEmpty;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await context.read<AuthState>().login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;
      showAppSnackBar(context, error.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(),
                const SizedBox(height: 26),
                Text(
                  'Welcome Back',
                  style: GoogleFonts.nunito(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Log in to continue shopping your favorite styles.',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    height: 1.55,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 26),
                _buildFormCard(),
                const SizedBox(height: 10),
                _buildForgotPasswordAction(),
                const SizedBox(height: 26),
                _buildLoginButton(),
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

  Widget _buildFormCard() {
    return Column(
      children: [
        _buildEmailField(),
        const SizedBox(height: 14),
        _buildPasswordField(),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      onChanged: (_) => setState(() {}),
      style: GoogleFonts.nunito(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
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
        hint: 'Email Address',
        prefix: Icons.email_outlined,
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      onChanged: (_) => setState(() {}),
      style: GoogleFonts.nunito(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
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

  Widget _buildForgotPasswordAction() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
          );
        },
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minimumSize: Size.zero,
        ),
        child: Text(
          'Forget Password?',
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
      ),
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

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading || !_isFormFilled ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.55),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Log In',
                style: GoogleFonts.nunito(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}
