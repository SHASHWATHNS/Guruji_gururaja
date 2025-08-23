import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/viewmodels/auth_view_model.dart';

// Local state for sample toggles
final notificationsEnabledProvider = StateProvider<bool>((_) => true);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifOn = ref.watch(notificationsEnabledProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.headerBar,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'GURUJI GURURAJA',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.black,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'SETTINGS',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 6),

          // --- Account ---
          const _SectionHeader('Account'),
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: const Text('Profile'),
            subtitle: const Text('View or edit your profile (coming soon)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile — coming soon')),
              );
            },
          ),

          const Divider(height: 1),

          // --- Preferences ---
          const _SectionHeader('Preferences'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active),
            title: const Text('Notifications'),
            value: notifOn,
            onChanged: (v) =>
            ref.read(notificationsEnabledProvider.notifier).state = v,
          ),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Theme'),
            subtitle: const Text('Light (Dark mode coming soon)'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dark mode — coming soon')),
              );
            },
          ),

          const Divider(height: 1),

          // --- About & Help ---
          const _SectionHeader('About & Help'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About Founder'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/about-founder'),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            subtitle: const Text('Opens website (coming soon)'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacy Policy — coming soon')),
              );
            },
          ),

          const Divider(height: 1),

          // --- Advanced ---
          const _SectionHeader('Advanced'),
          ListTile(
            leading: const Icon(Icons.cleaning_services_outlined),
            title: const Text('Clear demo OTP hint'),
            subtitle:
            const Text('Remove the “OTP: 123456” helper from Login'),
            onTap: () {
              ref.read(authProvider.notifier).clearOtpHint(); // ✅ fixed
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Demo OTP hint cleared')),
              );
            },
          ),

          const SizedBox(height: 12),

          // --- Danger zone: Logout ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.logout),
              label: const Text(
                'LOG OUT',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              },
            ),
          ),

          const SizedBox(height: 18),
          const Center(
            child: Text(
              'v1.0.0',
              style: TextStyle(color: Colors.black45),
            ),
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: Colors.grey.shade700,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
