import '../entities/tarot_card_entity.dart';
import '../repositories/tarot_repository.dart';

class GetCardById {
  final TarotRepository repository;
  GetCardById({required this.repository});

  TarotCardEntity? call(String id, List<TarotCardEntity> deck) {
    return repository.getById(id, deck);
  }
}
