import '../../domain/entities/tarot_card_entity.dart';
import '../../domain/repositories/tarot_repository.dart';
import '../datasources/tarot_local_data_source.dart';

class TarotRepositoryImpl implements TarotRepository {
  final TarotLocalDataSource local;

  TarotRepositoryImpl({required this.local});

  @override
  Future<List<TarotCardEntity>> loadDeck() async {
    final models = await local.loadFromAssets();
    return models.map((m) => m.toEntity()).toList(growable: false);
  }

  @override
  TarotCardEntity? getById(String id, List<TarotCardEntity> deck) {
    try {
      return deck.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
