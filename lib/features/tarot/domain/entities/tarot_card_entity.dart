class TarotCardEntity {
  final String id;
  final String name;
  final String imageAsset; // e.g., "TARROT1.JPG"
  final String? benefitParagraphEn;
  final String? benefitParagraphTa;

  const TarotCardEntity({
    required this.id,
    required this.name,
    required this.imageAsset,
    this.benefitParagraphEn,
    this.benefitParagraphTa,
  });
}
