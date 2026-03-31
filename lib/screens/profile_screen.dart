import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../constants/colors.dart';
import '../models/auth_user.dart';
import '../models/profile_dashboard.dart';
import '../state/auth_state.dart';
import '../state/profile_state.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final int initialNavIndex;

  const ProfileScreen({super.key, this.initialNavIndex = 3});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late int _selectedNavIndex;

  List<_ProfileMenuItem> get _accountItems => const [
    _ProfileMenuItem(
      icon: Icons.person_outline,
      title: 'Personal Details',
      subtitle: 'Name, email, phone number',
    ),
    _ProfileMenuItem(
      icon: Icons.history,
      title: 'Order History',
      subtitle: 'Past and current orders',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedNavIndex = widget.initialNavIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<AuthState>().isAuthenticated) {
        context.read<ProfileState>().loadDashboard();
      }
    });
  }

  void _onBottomNavTap(int index) {
    if (index == 0) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _selectedNavIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthState>();
    final profileState = context.watch<ProfileState>();
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
                    _buildQuickStats(dashboard),
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
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        Text(
          'Profile',
          style: GoogleFonts.nunito(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(999),
          child: Ink(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFE8E8E8)),
            ),
            child: const Icon(Icons.settings_outlined, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(AuthUser? user) {
    final fullName = user?.fullName.trim().isNotEmpty == true
        ? user!.fullName.trim()
        : 'Customer';
    final email = user?.email ?? 'No email available';

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
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
              image: const DecorationImage(
                image: NetworkImage('https://i.pravatar.cc/180?img=58'),
                fit: BoxFit.cover,
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
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Edit Profile',
                    style: GoogleFonts.nunito(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(ProfileDashboard? dashboard) {
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
            value: dashboard?.cartCount.toString() ?? '0',
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
                onTap: () {},
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
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () async {
          final profileState = context.read<ProfileState>();
          await authState.logout();
          profileState.clear();
          if (!mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        },
        icon: const Icon(Icons.logout, size: 18),
        label: Text(
          'Sign Out',
          style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFD96B6B),
          side: const BorderSide(color: Color(0xFFF0D3D3)),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
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
        currentIndex: _selectedNavIndex,
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
            icon: Icon(Icons.storefront_outlined),
            label: 'Shop',
          ),
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

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
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
