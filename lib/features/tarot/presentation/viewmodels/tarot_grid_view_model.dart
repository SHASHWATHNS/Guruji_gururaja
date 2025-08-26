import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/tarot_card_entity.dart';
import '../../domain/usecases/load_tarot_deck.dart';
import '../../domain/usecases/shuffle_deck.dart';
import '../state/deck_state.dart';

class TarotGridViewModel extends StateNotifier<DeckState> {
  final LoadTarotDeck loadTarotDeck;
  final ShuffleDeck shuffleDeck;

  TarotGridViewModel({
    required this.loadTarotDeck,
    required this.shuffleDeck,
  }) : super(const DeckState());

  Future<void> init() async {
    state = state.copyWith(status: DeckStatus.loading);
    try {
      final deck = await loadTarotDeck();
      final shuffled = shuffleDeck(deck);
      state = state.copyWith(status: DeckStatus.ready, cards: shuffled);
    } catch (e) {
      state = state.copyWith(status: DeckStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> shuffle() async {
    if (state.status != DeckStatus.ready || state.cards.isEmpty) return;
    // turn on "shuffling" for visual animation
    state = state.copyWith(shuffling: true, selectedId: null);
    // brief animation duration (match UI duration ~600ms)
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final shuffled = shuffleDeck(state.cards);
    state = state.copyWith(cards: shuffled);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    state = state.copyWith(shuffling: false);
  }

  TarotCardEntity? selectCard(String id) {
    state = state.copyWith(selectedId: id);
    try {
      return state.cards.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
