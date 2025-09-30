import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../chart_providers.dart';

// l10n
import '../../../../../core/i18n/app_localizations.dart';

class RaasiChart extends ConsumerWidget {
  const RaasiChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(raasiSvgProvider);
    return async.when(
      loading: () => const Center(
        child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          '${context.l10n.t('chart.raasi.error')}: $e',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
      data: (svg) {
        final maxW = MediaQuery.sizeOf(context).width - 24;
        final box = maxW.clamp(260.0, 520.0);
        return Container(
          color: Colors.white,
          width: box,
          height: box,
          alignment: Alignment.center,
          child: InteractiveViewer(
            boundaryMargin: const EdgeInsets.all(32),
            minScale: 0.5,
            maxScale: 8,
            child: SvgPicture.string(svg, fit: BoxFit.contain, allowDrawingOutsideViewBox: true),
          ),
        );
      },
    );
  }
}
