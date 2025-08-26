import '../entities/tarot_card_entity.dart';
import '../repositories/tarot_repository.dart';

class LoadTarotDeck {
  final TarotRepository repository;
  LoadTarotDeck({required this.repository});

  Future<List<TarotCardEntity>> call() {
    return repository.loadDeck();
  }
}
