import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import "package:share_plus/share_plus.dart";
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/i18n/app_localizations.dart';

class AboutFounderScreen extends ConsumerWidget {
  const AboutFounderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n.t;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.headerBar,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              t('app.title'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.black,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                t('about.chip'),
                style: const TextStyle(
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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          // Profile card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(80),
                    child: Image.asset(
                      'assets/images/about_face.jpg', // keep your app asset for reliability
                      width: 120, height: 120, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 120, height: 120,
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: const Text('GG', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    t('about.name'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    t('about.role'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Bio card (from website content)
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(t('about.section.bio')),
                  const SizedBox(height: 6),
                  Text(t('about.bio.origin'), style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Text(t('about.bio.inspiration'), style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Text(t('about.bio.work'), style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Text(t('about.bio.trust'), style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Reach card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(t('about.section.contact')),
                  const SizedBox(height: 8),
                  _ActionTile(
                    icon: Icons.location_on_outlined,
                    label: t('about.contact.location'),
                    onTap: () {},
                  ),
                  _ActionTile(
                    icon: Icons.call,
                    label: '${t('about.contact.phone')}: +91 95850 65142',
                    onTap: () async {
                      final uri = Uri.parse('tel:+919585065142');
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    },
                  ),
                  _ActionTile(
                    icon: Icons.mail_outline,
                    label: t('about.email'),
                    onTap: () async {
                      final uri = Uri.parse('mailto:support@gurujigururaja.in?subject=%5BGURUJI%5D%20App%20Inquiry');
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    },
                  ),
                  _ActionTile(
                    icon: Icons.public,
                    label: t('about.website'),
                    onTap: () async {
                      final uri = Uri.parse('https://gurujigururaja.in/');
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    },
                  ),
                  _ActionTile(
                    icon: Icons.share,
                    label: t('about.share'),
                    onTap: () => Share.share('Check out GURUJI GURURAJA app: https://www.gurujigururaja.in/app'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: Colors.grey.shade700,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
