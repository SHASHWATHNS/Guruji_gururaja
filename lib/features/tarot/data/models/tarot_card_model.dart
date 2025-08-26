import '../../domain/entities/tarot_card_entity.dart';

class TarotCardModel {
  final String id;
  final String name;
  final String image;
  final String? benefitParagraphEn;
  final String? benefitParagraphTa;

  const TarotCardModel({
    required this.id,
    required this.name,
    required this.image,
    this.benefitParagraphEn,
    this.benefitParagraphTa,
  });

  factory TarotCardModel.fromJson(Map<String, dynamic> j) {
    return TarotCardModel(
      id: j['id'] as String,
      name: j['name'] as String,
      image: j['image'] as String,
      benefitParagraphEn: j['benefit_paragraph_en'] as String?,
      benefitParagraphTa: j['benefit_paragraph_ta'] as String?,
    );
  }

  TarotCardEntity toEntity() => TarotCardEntity(
    id: id,
    name: name,
    imageAsset: image,
    benefitParagraphEn: benefitParagraphEn,
    benefitParagraphTa: benefitParagraphTa,
  );
}
