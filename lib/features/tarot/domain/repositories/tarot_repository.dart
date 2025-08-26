import '../entities/tarot_card_entity.dart';

abstract class TarotRepository {
  Future<List<TarotCardEntity>> loadDeck(); // from local JSON
  TarotCardEntity? getById(String id, List<TarotCardEntity> deck);
}
