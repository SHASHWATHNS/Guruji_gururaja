import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/tarot_local_data_source.dart';
import '../../data/repositories/tarot_repository_impl.dart';
import '../../domain/repositories/tarot_repository.dart';
import '../../domain/usecases/get_card_by_id.dart';
import '../../domain/usecases/load_tarot_deck.dart';
import '../../domain/usecases/shuffle_deck.dart';
import '../state/deck_state.dart';
import '../state/selection_state.dart';
import '../viewmodels/tarot_grid_view_model.dart';
import '../viewmodels/tarot_detail_view_model.dart';

final tarotRepositoryProvider = Provider<TarotRepository>((ref) {
  final ds = TarotLocalDataSourceImpl(
    jsonAssetPath: 'assets/tarot/data/tarot_cards.json', // <-- correct path
  );
  return TarotRepositoryImpl(local: ds);
});

final loadTarotDeckProvider = Provider<LoadTarotDeck>((ref) {
  return LoadTarotDeck(repository: ref.read(tarotRepositoryProvider));
});
final shuffleDeckProvider = Provider<ShuffleDeck>((ref) {
  return const ShuffleDeck();
});
final getCardByIdProvider = Provider<GetCardById>((ref) {
  return GetCardById(repository: ref.read(tarotRepositoryProvider));
});

final tarotGridViewModelProvider =
StateNotifierProvider<TarotGridViewModel, DeckState>((ref) {
  return TarotGridViewModel(
    loadTarotDeck: ref.read(loadTarotDeckProvider),
    shuffleDeck: ref.read(shuffleDeckProvider),
  )..init();
});

final tarotDetailViewModelProvider =
StateNotifierProvider<TarotDetailViewModel, SelectionState>((ref) {
  return TarotDetailViewModel(
    getCardById: ref.read(getCardByIdProvider),
    deckState: ref.watch(tarotGridViewModelProvider),
  );
});
