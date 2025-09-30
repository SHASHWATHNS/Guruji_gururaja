import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// l10n
import '../../../../core/i18n/app_localizations.dart';

// Form state
import '../../form/horoscope_form_screen.dart'
    show birthDataProvider, HoroscopeFormScreen;

// Tabs
import '../../tabs/summary/summary_tab.dart';
import '../../tabs/chart/chart_screen.dart';
import '../../tabs/dasa/dasha_tab.dart';

class HoroscopeTabsScreen extends ConsumerWidget {
  const HoroscopeTabsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bd = ref.watch(birthDataProvider);

    if (bd == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (ctx) => HoroscopeFormScreen(
              onSubmitted: () {
                Navigator.of(ctx).pushReplacement(
                  MaterialPageRoute(builder: (_) => const HoroscopeTabsScreen()),
                );
              },
            ),
          ),
        );
      });

      return const Scaffold(body: SizedBox.shrink());
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.t('horoscope.title')),
          bottom: TabBar(
            tabs: [
              Tab(text: context.l10n.t('tabs.summary')),
              Tab(text: context.l10n.t('tabs.chart')),
              Tab(text: context.l10n.t('tabs.dasha')),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            SummaryTab(),
            ChartScreen(),
            DashaTab(),
          ],
        ),
      ),
    );
  }
}
