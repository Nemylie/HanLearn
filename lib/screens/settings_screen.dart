import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// New screens
import 'update_email_screen.dart';
import 'change_password_screen.dart';
import 'delete_account_screen.dart';
import 'about_us_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_conditions_screen.dart';
import 'update_display_name_screen.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _wordBankNotifications = true; // toggle only (temporary)

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;

    final Color bg = theme.scaffoldBackgroundColor;
    final Color cardBg = isDark ? const Color(0xFF2A2A2E) : Colors.white;
    final Color divider = isDark ? Colors.white12 : Colors.black12;
    final Color titleColor = isDark ? Colors.white : Colors.black87;
    final Color subtitleColor = isDark ? Colors.white70 : Colors.black54;

    // Header color uses your app primary (maroon)
    final Color headerColor = theme.colorScheme.primary;
    final size = MediaQuery.of(context).size;
    final headerHeight = size.height * 0.35;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Top curved header
          ClipPath(
            clipper: _SettingsHeaderClipper(),
            child: Container(
              height: headerHeight,
              width: double.infinity,
              color: headerColor,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // AppBar-like row (back + centered title)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new),
                        color: Colors.white,
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Settings',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Content panel
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: isDark ? 0.25 : 0.10),
                            blurRadius: 16,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 18),

                          _NavTile(
                            icon: Icons.person_outline,
                            iconColor: isDark ? Colors.white70 : headerColor,
                            title: 'Change Appearance',
                            titleColor: titleColor,
                            subtitle: null,
                            subtitleColor: subtitleColor,
                            trailingColor:
                                isDark ? Colors.white54 : Colors.black45,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const UpdateDisplayNameScreen()),
                            ),
                          ),
                          _Divider(color: divider),

                          _NavTile(
                            icon: Icons.email_outlined,
                            iconColor: isDark ? Colors.white70 : headerColor,
                            title: 'Update Email',
                            titleColor: titleColor,
                            subtitle: null,
                            subtitleColor: subtitleColor,
                            trailingColor:
                                isDark ? Colors.white54 : Colors.black45,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const UpdateEmailScreen()),
                            ),
                          ),
                          _Divider(color: divider),

                          _NavTile(
                            icon: Icons.lock_outline,
                            iconColor: isDark ? Colors.white70 : headerColor,
                            title: 'Change Password',
                            titleColor: titleColor,
                            subtitle: null,
                            subtitleColor: subtitleColor,
                            trailingColor:
                                isDark ? Colors.white54 : Colors.black45,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ChangePasswordScreen()),
                            ),
                          ),
                          _Divider(color: divider),

                          _NavTile(
                            icon: Icons.delete_outline,
                            iconColor: isDark ? Colors.redAccent : Colors.red,
                            title: 'Delete Account',
                            titleColor: isDark ? Colors.redAccent : Colors.red,
                            subtitle: null,
                            subtitleColor: subtitleColor,
                            trailingColor:
                                isDark ? Colors.white54 : Colors.black45,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const DeleteAccountScreen()),
                            ),
                          ),

                          const SizedBox(height: 16),
                          _Divider(color: divider),
                          const SizedBox(height: 12),

                          _SectionHeader(title: 'General', color: titleColor),
                          _SwitchTile(
                            icon: Icons.dark_mode,
                            iconColor: isDark ? Colors.white70 : headerColor,
                            title: 'Dark Mode',
                            subtitle: 'Use dark theme throughout the app',
                            value: themeProvider.isDark,
                            titleColor: titleColor,
                            subtitleColor: subtitleColor,
                            onChanged: (_) => themeProvider.toggleTheme(),
                          ),
                          _SwitchTile(
                            icon: Icons.notifications_none,
                            iconColor: isDark ? Colors.white70 : headerColor,
                            title: 'Notifications',
                            subtitle:
                                'Word bank reminders (toggle only for now)',
                            value: _wordBankNotifications,
                            titleColor: titleColor,
                            subtitleColor: subtitleColor,
                            onChanged: (v) =>
                                setState(() => _wordBankNotifications = v),
                          ),

                          const SizedBox(height: 16),
                          _Divider(color: divider),
                          const SizedBox(height: 12),

                          // INFORMATION
                          _SectionHeader(
                              title: 'Information', color: titleColor),
                          _NavTile(
                            icon: Icons.info_outline,
                            iconColor: isDark ? Colors.white70 : headerColor,
                            title: 'About Us',
                            titleColor: titleColor,
                            subtitle: null,
                            subtitleColor: subtitleColor,
                            trailingColor:
                                isDark ? Colors.white54 : Colors.black45,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const AboutUsScreen()),
                              );
                            },
                          ),
                          _Divider(color: divider),
                          _NavTile(
                            icon: Icons.privacy_tip_outlined,
                            iconColor: isDark ? Colors.white70 : headerColor,
                            title: 'Privacy Policy',
                            titleColor: titleColor,
                            subtitle: null,
                            subtitleColor: subtitleColor,
                            trailingColor:
                                isDark ? Colors.white54 : Colors.black45,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const PrivacyPolicyScreen()),
                              );
                            },
                          ),
                          _Divider(color: divider),
                          _NavTile(
                            icon: Icons.description_outlined,
                            iconColor: isDark ? Colors.white70 : headerColor,
                            title: 'Terms & Conditions',
                            titleColor: titleColor,
                            subtitle: null,
                            subtitleColor: subtitleColor,
                            trailingColor:
                                isDark ? Colors.white54 : Colors.black45,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const TermsConditionsScreen()),
                              );
                            },
                          ),

                          const SizedBox(height: 18),
                        ],
                      ),
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
}

/* -------------------- UI helpers -------------------- */

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  const _SectionHeader({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final Color color;
  const _Divider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Divider(height: 1, thickness: 1, color: color),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Color titleColor;
  final String? subtitle;
  final Color subtitleColor;
  final Color trailingColor;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.titleColor,
    required this.subtitle,
    required this.subtitleColor,
    required this.trailingColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 12, 14),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle!,
                      style: TextStyle(fontSize: 12.5, color: subtitleColor),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: trailingColor),
          ],
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final Color titleColor;
  final Color subtitleColor;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.titleColor,
    required this.subtitleColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 12, 10),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12.5, color: subtitleColor),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: theme.colorScheme.secondary,
            onChanged: onChanged, // toggle only
          ),
        ],
      ),
    );
  }
}

/* -------------------- Header clipper -------------------- */

class _SettingsHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 50,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
