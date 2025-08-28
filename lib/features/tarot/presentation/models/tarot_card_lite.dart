class TarotCardLite {
  final String id;
  final String name;
  final String image; // e.g. TARROT1.JPG
  final String? benefitEn;
  final String? benefitTa;

  const TarotCardLite({
    required this.id,
    required this.name,
    required this.image,
    this.benefitEn,
    this.benefitTa,
  });

  factory TarotCardLite.fromJson(Map<String, dynamic> j) {
    return TarotCardLite(
      id: j['id'] as String,
      name: j['name'] as String,
      image: j['image'] as String,
      benefitEn: j['benefit_paragraph_en'] as String?,
      benefitTa: j['benefit_paragraph_ta'] as String?,
    );
  }
}
