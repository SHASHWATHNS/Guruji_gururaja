import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/tarot_card_entity.dart';
import '../providers/tarot_providers.dart';
import '../state/deck_state.dart';
import '../widgets/tarot_card_back_tile.dart';
import '../widgets/tarot_shuffle_button.dart';
import 'tarot_detail_screen.dart'; // <-- make sure THIS is imported

class TarotGridScreen extends ConsumerWidget {
  const TarotGridScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deckState = ref.watch(tarotGridViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tarot')),
      body: switch (deckState.status) {
        DeckStatus.loading => const Center(child: CircularProgressIndicator()),
        DeckStatus.error => Center(child: Text(deckState.errorMessage ?? 'Failed to load deck')),
        DeckStatus.ready => _GridContent(deckState: deckState),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

class _GridContent extends ConsumerWidget {
  final DeckState deckState;
  const _GridContent({required this.deckState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(tarotGridViewModelProvider.notifier);

    return CustomScrollView(
      key: const PageStorageKey('tarotGrid'),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Tap any card to reveal.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.5 / 4,
            ),
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final TarotCardEntity card = deckState.cards[index];
                final highlighted = deckState.selectedId == card.id;

                return TarotCardBackTile(
                  heroTag: card.id,
                  highlighted: highlighted,
                  shuffling: deckState.shuffling,
                  onTap: () {
                    final selected = vm.selectCard(card.id);
                    if (selected == null) return;

                    // IMPORTANT: Use MaterialPageRoute (no named route).
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TarotDetailScreen(cardId: card.id),
                      ),
                    );
                  },
                );
              },
              childCount: deckState.cards.length,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            child: Center(
              child: TarotShuffleButton(
                shuffling: deckState.shuffling,
                onPressed: () => vm.shuffle(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
