import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/get_card_by_id.dart';
import '../state/deck_state.dart';
import '../state/selection_state.dart';

class TarotDetailViewModel extends StateNotifier<SelectionState> {
  final GetCardById getCardById;
  final DeckState deckState;

  TarotDetailViewModel({
    required this.getCardById,
    required this.deckState,
  }) : super(const SelectionState());

  void load(String id) {
    final card = getCardById(id, deckState.cards);
    state = state.copyWith(card: card, flipRevealed: false);
  }

  void reveal() {
    state = state.copyWith(flipRevealed: true);
  }
}
