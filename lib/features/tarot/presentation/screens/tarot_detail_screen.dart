import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/tarot_providers.dart';

class TarotDetailScreen extends ConsumerStatefulWidget {
  final String cardId; // <-- required
  const TarotDetailScreen({super.key, required this.cardId});

  @override
  ConsumerState<TarotDetailScreen> createState() => _TarotDetailScreenState();
}

class _TarotDetailScreenState extends ConsumerState<TarotDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flipCtrl;
  late final Animation<double> _flipAnim;

  @override
  void initState() {
    super.initState();
    _flipCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 550));
    _flipAnim = CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOut);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // load the selected card
      ref.read(tarotDetailViewModelProvider.notifier).load(widget.cardId);
      // short delay to show back briefly, then flip
      Future.delayed(const Duration(milliseconds: 180), () {
        _flipCtrl.forward();
        ref.read(tarotDetailViewModelProvider.notifier).reveal();
      });
    });
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sel = ref.watch(tarotDetailViewModelProvider);
    final isTamil = Localizations.localeOf(context).languageCode.toLowerCase() == 'ta';
    final card = sel.card;

    final backAsset = 'assets/tarot/back.jpg'; // <- your file
    final frontAsset = card != null ? 'assets/tarot/${card.imageAsset}' : backAsset;

    final paragraph = card == null
        ? ''
        : (isTamil
        ? (card.benefitParagraphTa ?? card.benefitParagraphEn ?? '')
        : (card.benefitParagraphEn ?? card.benefitParagraphTa ?? ''));

    return Scaffold(
      appBar: AppBar(title: Text(card?.name ?? 'Tarot')),
      body: card == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          AspectRatio(
            aspectRatio: 2.5 / 4,
            child: AnimatedBuilder(
              animation: _flipAnim,
              builder: (context, _) {
                final showFront = _flipAnim.value > 0.5;
                final angle = _flipAnim.value * 3.1415926;
                final img = showFront
                    ? Image.asset(frontAsset, fit: BoxFit.cover)
                    : Image.asset(backAsset, fit: BoxFit.cover);
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(angle),
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(showFront ? 3.1415926 : 0),
                    child: ClipRRect(borderRadius: BorderRadius.circular(16), child: img),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            card!.name,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            paragraph,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.45),
          ),
        ],
      ),
    );
  }
}
