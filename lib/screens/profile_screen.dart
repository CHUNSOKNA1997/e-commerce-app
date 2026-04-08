import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../constants/colors.dart';
import '../models/auth_user.dart';
import '../models/profile_dashboard.dart';
import '../state/auth_state.dart';
import '../state/cart_state.dart';
import '../state/profile_state.dart';
import '../utils/snackbar_helper.dart';
import 'login_screen.dart';
import 'order_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  final bool showBottomNav;
  final ValueChanged<int>? onTabSelected;
  final bool isActive;

  const ProfileScreen({
    super.key,
    this.showBottomNav = true,
    this.onTabSelected,
    this.isActive = true,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<_ProfileMenuItem> get _accountItems => [
    _ProfileMenuItem(
      icon: Icons.person_outline,
      title: 'Personal Details',
      subtitle: 'Name, email, phone number',
      onTap: (_) =>
          _openEditProfile(context.read<ProfileState>().dashboard?.user),
    ),
    const _ProfileMenuItem(
      icon: Icons.history,
      title: 'Order History',
      subtitle: 'Past and current orders',
      onTap: _openOrderHistory,
    ),
  ];

  static void _openOrderHistory(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const OrderHistoryScreen()));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshDashboard();
    });
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isActive && widget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _refreshDashboard();
        }
      });
    }
  }

  void _refreshDashboard() {
    if (context.read<AuthState>().isAuthenticated) {
      context.read<ProfileState>().loadDashboard();
    }
  }

  void _onBottomNavTap(int index) {
    if (widget.onTabSelected != null) {
      widget.onTabSelected!(index);
      return;
    }
    if (index == 0) {
      Navigator.of(context).pop();
      return;
    }
  }

  Future<void> _openEditProfile(AuthUser? user) async {
    if (user == null) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditProfileSheet(user: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthState>();
    final profileState = context.watch<ProfileState>();
    final cartState = context.watch<CartState>();
    final dashboard = profileState.dashboard;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBar(),
                    const SizedBox(height: 14),
                    _buildProfileCard(dashboard?.user),
                    const SizedBox(height: 16),
                    _buildQuickStats(
                      dashboard,
                      cartCount: cartState.itemCount,
                    ),
                    const SizedBox(height: 20),
                    _buildSectionTitle('Account'),
                    const SizedBox(height: 8),
                    _buildMenuCard(_accountItems),
                    const SizedBox(height: 16),
                    if (profileState.errorMessage != null) ...[
                      _buildErrorMessage(profileState.errorMessage!),
                      const SizedBox(height: 16),
                    ],
                    _buildLogoutButton(authState),
                  ],
                ),
              ),
            ),
            if (widget.showBottomNav) _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Text(
      'Profile',
      style: GoogleFonts.nunito(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildProfileCard(AuthUser? user) {
    final fullName = user?.fullName.trim().isNotEmpty == true
        ? user!.fullName.trim()
        : 'Customer';
    final email = user?.email ?? 'No email available';
    final avatarUrl = user?.avatarUrl;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6D14), Color(0xFFFF4E00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: ClipOval(
              child: DecoratedBox(
                decoration: const BoxDecoration(color: Color(0xFFFF8B45)),
                child: avatarUrl == null
                    ? const Icon(Icons.person, color: Colors.white, size: 34)
                    : Image.network(
                        avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 34,
                          );
                        },
                      ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style: GoogleFonts.nunito(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: GoogleFonts.nunito(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(
    ProfileDashboard? dashboard, {
    required int cartCount,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEFEFEF)),
      ),
      child: Row(
        children: [
          _StatItem(
            label: 'Orders',
            value: dashboard?.orderCount.toString() ?? '0',
          ),
          const _StatDivider(),
          _StatItem(
            label: 'Wishlist',
            value: dashboard?.wishlistCount.toString() ?? '0',
          ),
          const _StatDivider(),
          _StatItem(
            label: 'Cart',
            value: cartCount.toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.nunito(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildMenuCard(List<_ProfileMenuItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEFEFEF)),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isLast = index == items.length - 1;

          return Column(
            children: [
              InkWell(
                onTap: item.onTap == null ? null : () => item.onTap!(context),
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 11,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F6F6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          item.icon,
                          size: 19,
                          color: const Color(0xFF7D7D7D),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: GoogleFonts.nunito(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              item.subtitle,
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: Color(0xFFB7B7B7),
                      ),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: GoogleFonts.nunito(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.red.shade700,
        ),
      ),
    );
  }

  Widget _buildLogoutButton(AuthState authState) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () async {
          final profileState = context.read<ProfileState>();
          final navigator = Navigator.of(context);
          final shouldLogout = await showDialog<bool>(
            context: context,
            builder: (dialogContext) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Text(
                  'Sign Out?',
                  style: GoogleFonts.nunito(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                content: Text(
                  'Are you sure you want to sign out of your account?',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Sign Out',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              );
            },
          );

          if (shouldLogout != true || !context.mounted) {
            return;
          }

          await authState.logout();
          profileState.clear();
          if (!mounted) return;
          navigator.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        },
        icon: const Icon(Icons.logout, size: 18),
        label: Text(
          'Sign Out',
          style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        elevation: 0,
        currentIndex: 2,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey.shade400,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        onTap: _onBottomNavTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final void Function(BuildContext context)? onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });
}

class _EditProfileSheet extends StatefulWidget {
  final AuthUser user;

  const _EditProfileSheet({required this.user});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _avatarPathController;
  bool _isSaving = false;
  String? _selectedAvatarFilePath;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
    _avatarPathController = TextEditingController(
      text: widget.user.avatarPath ?? '',
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _avatarPathController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final navigator = Navigator.of(context);
    final profileState = context.read<ProfileState>();
    final authState = context.read<AuthState>();
    final previousAvatarUrl = widget.user.avatarUrl;
    setState(() => _isSaving = true);

    try {
      final user = await profileState.updateProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        avatarPath: _avatarPathController.text.trim(),
        avatarFilePath: _selectedAvatarFilePath,
      );
      if (previousAvatarUrl != null && previousAvatarUrl.isNotEmpty) {
        await NetworkImage(previousAvatarUrl).evict();
      }
      if (user.avatarUrl != null && user.avatarUrl!.isNotEmpty) {
        await NetworkImage(user.avatarUrl!).evict();
      }
      await authState.setCurrentUser(user);
      await profileState.loadDashboard();
      if (!mounted) return;
      navigator.pop();
      showAppSnackBar(context, 'Profile updated');
    } catch (error) {
      if (!mounted) return;
      showAppSnackBar(context, error.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _pickAvatar() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile == null || !mounted) {
      return;
    }

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      compressQuality: 90,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: '',
          toolbarColor: AppColors.primary,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: AppColors.primary,
          statusBarLight: false,
          navBarLight: false,
          backgroundColor: Colors.black,
          cropFrameColor: AppColors.primary,
          cropGridColor: Colors.white24,
          hideBottomControls: false,
          lockAspectRatio: true,
          initAspectRatio: CropAspectRatioPreset.square,
          cropStyle: CropStyle.circle,
        ),
        IOSUiSettings(
          title: 'Crop Avatar',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
          rotateButtonsHidden: false,
          rotateClockwiseButtonHidden: false,
          cropStyle: CropStyle.circle,
        ),
      ],
    );

    if (croppedFile == null || !mounted) {
      return;
    }

    setState(() {
      _selectedAvatarFilePath = croppedFile.path;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDADADA),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Edit Profile',
                style: GoogleFonts.nunito(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: ClipOval(
                        child: DecoratedBox(
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF8B45),
                          ),
                          child: _selectedAvatarFilePath != null
                              ? Image.file(
                                  File(_selectedAvatarFilePath!),
                                  fit: BoxFit.cover,
                                )
                              : widget.user.avatarUrl == null
                              ? const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 38,
                                )
                              : Image.network(
                                  widget.user.avatarUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 38,
                                    );
                                  },
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: _isSaving ? null : _pickAvatar,
                      icon: const Icon(Icons.upload_outlined),
                      label: const Text('Upload Avatar'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _firstNameController,
                label: 'First Name',
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Please enter your first name'
                    : null,
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _lastNameController,
                label: 'Last Name',
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Please enter your last name'
                    : null,
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _phoneController,
                label: 'Phone',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withValues(
                      alpha: 0.55,
                    ),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          'Save Changes',
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.nunito(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: const Color(0xFFF7F7F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 36, color: const Color(0xFFEDEDED));
  }
}
