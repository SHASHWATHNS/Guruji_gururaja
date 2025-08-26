import '../../domain/entities/tarot_card_entity.dart';

enum DeckStatus { initial, loading, ready, error }

class DeckState {
  final DeckStatus status;
  final List<TarotCardEntity> cards;
  final bool shuffling;
  final String? selectedId;
  final String? errorMessage;

  const DeckState({
    this.status = DeckStatus.initial,
    this.cards = const [],
    this.shuffling = false,
    this.selectedId,
    this.errorMessage,
  });

  DeckState copyWith({
    DeckStatus? status,
    List<TarotCardEntity>? cards,
    bool? shuffling,
    String? selectedId,
    String? errorMessage,
  }) {
    return DeckState(
      status: status ?? this.status,
      cards: cards ?? this.cards,
      shuffling: shuffling ?? this.shuffling,
      selectedId: selectedId,
      errorMessage: errorMessage,
    );
  }
}
