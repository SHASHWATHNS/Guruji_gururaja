import 'dart:math';
import '../entities/tarot_card_entity.dart';

class ShuffleDeck {
  const ShuffleDeck();

  List<TarotCardEntity> call(List<TarotCardEntity> input) {
    final list = List<TarotCardEntity>.from(input);
    list.shuffle(Random());
    return list;
  }
}
