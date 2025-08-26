import '../../domain/entities/tarot_card_entity.dart';

class SelectionState {
  final TarotCardEntity? card;
  final bool flipRevealed;

  const SelectionState({
    this.card,
    this.flipRevealed = false,
  });

  SelectionState copyWith({
    TarotCardEntity? card,
    bool? flipRevealed,
  }) {
    return SelectionState(
      card: card ?? this.card,
      flipRevealed: flipRevealed ?? this.flipRevealed,
    );
  }
}
