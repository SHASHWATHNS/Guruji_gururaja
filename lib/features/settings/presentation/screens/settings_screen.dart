import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/i18n/app_localizations.dart';
import '../../../../core/settings/app_settings.dart';
import '../../../auth/auth/presentation/viewmodels/auth_view_model.dart';


class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.headerBar,
        centerTitle: true,
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.t('app.title'),
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
                l10n.t('chip.settings'),
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
          // ===== Preferences card =====
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(text: l10n.t('settings.preferences')),

                  // Theme
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.brightness_6),
                    title: Text(l10n.t('settings.theme')),
                    subtitle: Text(_themeLabel(l10n, settings.themeMode)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showThemePicker(context, ref, settings.themeMode),
                  ),

                  const Divider(height: 1),

                  // Language toggle (TA <-> EN)
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: Text(
                      l10n.t('settings.language'),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  LanguageToggle(
                    value: settings.locale,
                    onChanged: (loc) {
                      HapticFeedback.selectionClick();
                      ref.read(appSettingsProvider.notifier).setLocale(loc);
                      // no navigation needed — whole app rebuilds via AstroApp.locale
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ===== Logout =====
          Semantics(
            button: true,
            label: l10n.t('settings.logout'),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: Text(
                  l10n.t('settings.logout'),
                  style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.6),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                onPressed: () async {
                  final confirmed = await _confirmLogout(context);
                  if (confirmed != true) return;
                  try {
                    await ref.read(authProvider.notifier).logout();
                  } catch (_) {}
                  if (context.mounted) context.go('/login');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _themeLabel(AppLocalizations l10n, ThemeMode m) {
    switch (m) {
      case ThemeMode.light:
        return l10n.t('settings.theme.light');
      case ThemeMode.dark:
        return l10n.t('settings.theme.dark');
      default:
        return l10n.t('settings.theme.system');
    }
  }

  Future<void> _showThemePicker(
      BuildContext context,
      WidgetRef ref,
      ThemeMode current,
      ) async {
    final l10n = context.l10n;
    HapticFeedback.selectionClick();
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ThemeOptionTile(
              mode: ThemeMode.system,
              group: current,
              label: l10n.t('settings.theme.system'),
              icon: Icons.phone_iphone,
              onChanged: (v) {
                HapticFeedback.selectionClick();
                ref.read(appSettingsProvider.notifier).setThemeMode(v);
                Navigator.of(context).pop();
              },
            ),
            _ThemeOptionTile(
              mode: ThemeMode.light,
              group: current,
              label: l10n.t('settings.theme.light'),
              icon: Icons.light_mode,
              onChanged: (v) {
                HapticFeedback.selectionClick();
                ref.read(appSettingsProvider.notifier).setThemeMode(v);
                Navigator.of(context).pop();
              },
            ),
            _ThemeOptionTile(
              mode: ThemeMode.dark,
              group: current,
              label: l10n.t('settings.theme.dark'),
              icon: Icons.dark_mode,
              onChanged: (v) {
                HapticFeedback.selectionClick();
                ref.read(appSettingsProvider.notifier).setThemeMode(v);
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<bool?> _confirmLogout(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.t('settings.logout')),
        content: Text(
          'Are you sure you want to log out?', // add a key later if you want this localized
          style: Theme.of(ctx).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('LOG OUT'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
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

class _ThemeOptionTile extends StatelessWidget {
  final ThemeMode mode;
  final ThemeMode group;
  final String label;
  final IconData icon;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeOptionTile({
    required this.mode,
    required this.group,
    required this.label,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = mode == group;
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: selected
          ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
          : const Icon(Icons.radio_button_unchecked),
      onTap: () => onChanged(mode),
    );
  }
}

/// Pill-style TA/EN toggle with a11y + animation
class LanguageToggle extends StatelessWidget {
  final Locale value; // current locale
  final ValueChanged<Locale> onChanged;
  const LanguageToggle({super.key, required this.value, required this.onChanged});

  bool get _isTamil => value.languageCode.toLowerCase() == 'ta';

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: _isTamil,
      label: context.l10n.t('settings.language'),
      hint: 'Double tap to switch language',
      child: SizedBox(
        height: 52,
        child: Stack(
          children: [
            // Track
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F6),
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
            ),
            // Thumb
            AnimatedAlign(
              alignment: _isTamil ? Alignment.centerLeft : Alignment.centerRight,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                heightFactor: 1.0,
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Labels + taps
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(26),
                    onTap: () => onChanged(const Locale('ta')),
                    child: const _LangCell(label: 'TA', emoji: '🇮🇳'),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(26),
                    onTap: () => onChanged(const Locale('en')),
                    child: const _LangCell(label: 'EN', emoji: '🇬🇧'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LangCell extends StatelessWidget {
  final String label;
  final String emoji;
  const _LangCell({required this.label, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
