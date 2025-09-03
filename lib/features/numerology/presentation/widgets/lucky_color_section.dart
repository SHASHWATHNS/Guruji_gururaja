import 'package:flutter/material.dart';

class LuckyColorSection extends StatefulWidget {
  const LuckyColorSection({super.key});

  @override
  State<LuckyColorSection> createState() => _LuckyColorSectionState();
}

class _LuckyColorSectionState extends State<LuckyColorSection> {
  int _selected = 0;

  // 12 ராசிகள் – lucky colors + short benefits (Tamil)
  static final List<_ColorInfo> _items = <_ColorInfo>[
    _ColorInfo(
      rasiTa: 'மேஷம்',
      eng: 'Aries',
      swatches: const [_Swatch('சிகப்பு', Color(0xFFE53935)), _Swatch('ஸ்கார்லெட்', Color(0xFFEF5350))],
      descTa: 'சிகப்பு தைரியம், தலைமையன்மை, வேகமான முடிவு. முயற்சியில் வெற்றி, ஆற்றல் அதிகரிப்பு.',
      tileColor: const Color(0xFFFFEBEE),
    ),
    _ColorInfo(
      rasiTa: 'ரிஷபம்',
      eng: 'Taurus',
      swatches: const [_Swatch('பச்சை', Color(0xFF43A047)), _Swatch('இளம்பச்சை', Color(0xFFA5D6A7)), _Swatch('இளஞ்சிவப்பு', Color(0xFFF8BBD0))],
      descTa: 'பச்சை/இளஞ்சிவப்பு நிலைத்தன்மை, செல்வ உயர்வு, உறவு இனிமை.',
      tileColor: const Color(0xFFE8F5E9),
    ),
    _ColorInfo(
      rasiTa: 'மிதுனம்',
      eng: 'Gemini',
      swatches: const [_Swatch('மஞ்சள்', Color(0xFFFBC02D)), _Swatch('பச்சை', Color(0xFF66BB6A))],
      descTa: 'மஞ்சள்/பச்சை தொடர்பாற்றல், நுண்ணறிவு, வணிக நுட்பம்.',
      tileColor: const Color(0xFFFFF8E1),
    ),
    _ColorInfo(
      rasiTa: 'கடகம்',
      eng: 'Cancer',
      swatches: const [_Swatch('வெள்ளை', Color(0xFFFFFFFF)), _Swatch('வெள்ளி', Color(0xFFeceff1))],
      descTa: 'வெள்ளை/வெள்ளி மனஅமைதி, பாதுகாப்பு, குடும்ப ஒற்றுமை.',
      tileColor: const Color(0xFFF5F5F5),
    ),
    _ColorInfo(
      rasiTa: 'சிம்மம்',
      eng: 'Leo',
      swatches: const [_Swatch('தங்கம்', Color(0xFFFFD54F)), _Swatch('ஆரஞ்சு', Color(0xFFFF9800))],
      descTa: 'தங்க/ஆரஞ்சு அதிகாரம், புகழ், மேடைத் திறன்.',
      tileColor: const Color(0xFFFFF3E0),
    ),
    _ColorInfo(
      rasiTa: 'கன்னி',
      eng: 'Virgo',
      swatches: const [_Swatch('பச்சை', Color(0xFF4CAF50)), _Swatch('பழுப்பு', Color(0xFF8D6E63))],
      descTa: 'பச்சை/பழுப்பு ஆரோக்கியம், பகுத்தறிவு, ஒழுங்கு.',
      tileColor: const Color(0xFFE8F5E9),
    ),
    _ColorInfo(
      rasiTa: 'துலாம்',
      eng: 'Libra',
      swatches: const [_Swatch('இளநீலம்', Color(0xFF90CAF9)), _Swatch('வெள்ளை', Color(0xFFFFFFFF))],
      descTa: 'இளநீலம்/வெள்ளை சமநிலை, கண்ணியம், உறவு ஒற்றுமை.',
      tileColor: const Color(0xFFE3F2FD),
    ),
    _ColorInfo(
      rasiTa: 'விருச்சிகம்',
      eng: 'Scorpio',
      swatches: const [_Swatch('கடுஞ்சிகப்பு', Color(0xFFB71C1C)), _Swatch('மரூன்', Color(0xFF7B1FA2))],
      descTa: 'மரூன்/கடுஞ்சிகப்பு இலக்கு தீவிரம், ஆழம் தேவைப் பணிகளில் பலன்.',
      tileColor: const Color(0xFFF3E5F5),
    ),
    _ColorInfo(
      rasiTa: 'தனுசு',
      eng: 'Sagittarius',
      swatches: const [_Swatch('ஊதா', Color(0xFF7E57C2)), _Swatch('வயலட்', Color(0xFF9575CD))],
      descTa: 'ஊதா ஞானம், ஆன்மிக சிந்தனை, அதிர்ஷ்டம்; உயர்கல்வி, வெளிநாடு.',
      tileColor: const Color(0xFFF3E5F5),
    ),
    _ColorInfo(
      rasiTa: 'மகரம்',
      eng: 'Capricorn',
      swatches: const [_Swatch('கருப்பு', Color(0xFF000000)), _Swatch('கடுநீலம்', Color(0xFF283593))],
      descTa: 'கருப்பு/கடுநீலம் கட்டுப்பாடு, பொறுமை, பதவி உயர்வு.',
      tileColor: const Color(0xFFE8EAF6),
    ),
    _ColorInfo(
      rasiTa: 'கும்பம்',
      eng: 'Aquarius',
      swatches: const [_Swatch('ஆழ்நீலம்', Color(0xFF1565C0)), _Swatch('எலெக்ட்ரிக் நீலம்', Color(0xFF2196F3))],
      descTa: 'நவீனம், புதுமை, நண்பர் வட்டம் விரிவு, சிந்தனைச் சுதந்திரம்.',
      tileColor: const Color(0xFFE3F2FD),
    ),
    _ColorInfo(
      rasiTa: 'மீனம்',
      eng: 'Pisces',
      swatches: const [_Swatch('கடல்பச்சை', Color(0xFF26A69A)), _Swatch('மஞ்சள்', Color(0xFFFFD54F))],
      descTa: 'கடல்பச்சை/மஞ்சள் கருணை, உள்ளுணர்வு, கலைச்சிந்தனை; மனஅமைதி.',
      tileColor: const Color(0xFFE0F2F1),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final border = Colors.grey.shade300;
    final selected = _items[_selected];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.palette_outlined, size: 20),
              const SizedBox(width: 8),
              Text(
                'நல்ல நிறங்கள் (Lucky Colors)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ]),
            const SizedBox(height: 12),

            // Taller tiles to prevent overflow
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.80, // <— was 1.06; more height now
              ),
              itemCount: _items.length,
              itemBuilder: (_, i) {
                final it = _items[i];
                final isSel = i == _selected;
                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => setState(() => _selected = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    decoration: BoxDecoration(
                      color: it.tileColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isSel ? Colors.black87 : border, width: isSel ? 1.4 : 1),
                      boxShadow: isSel
                          ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 2),
                        _SwatchRow(swatches: it.swatches, size: 16),
                        const SizedBox(height: 10),
                        Text(
                          it.rasiTa,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          it.eng,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            _ColorDetails(info: selected),
          ],
        ),
      ),
    );
  }
}

/* ------------------------------ UI Pieces ------------------------------ */

class _ColorDetails extends StatelessWidget {
  const _ColorDetails({required this.info});
  final _ColorInfo info;

  @override
  Widget build(BuildContext context) {
    final border = Colors.grey.shade300;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BigSwatch(swatches: info.swatches),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _Chip(text: info.rasiTa),
                    _Chip(text: info.eng),
                    for (final s in info.swatches) _Chip(text: s.name),
                  ],
                ),
                const SizedBox(height: 8),
                Text(info.descTa, style: const TextStyle(fontSize: 15.5, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SwatchRow extends StatelessWidget {
  const _SwatchRow({required this.swatches, this.size = 14});
  final List<_Swatch> swatches;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      alignment: WrapAlignment.center,
      children: swatches
          .map((s) => Container(
        width: size * 1.6,
        height: size * 1.6,
        decoration: BoxDecoration(
          color: s.color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black.withOpacity(0.15)),
        ),
      ))
          .toList(),
    );
  }
}

class _BigSwatch extends StatelessWidget {
  const _BigSwatch({required this.swatches});
  final List<_Swatch> swatches;

  @override
  Widget build(BuildContext context) {
    const size = 72.0;
    final decoration = BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: Colors.grey.shade300),
      gradient: swatches.length >= 2 ? LinearGradient(colors: swatches.map((s) => s.color).toList()) : null,
      color: swatches.length == 1 ? swatches.first.color : null,
    );
    return Container(width: size, height: size, decoration: decoration);
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
    );
  }
}

/* ------------------------------ Models ------------------------------ */

class _ColorInfo {
  final String rasiTa;
  final String eng;
  final List<_Swatch> swatches;
  final String descTa;
  final Color tileColor;

  const _ColorInfo({
    required this.rasiTa,
    required this.eng,
    required this.swatches,
    required this.descTa,
    required this.tileColor,
  });
}

class _Swatch {
  final String name;
  final Color color;
  const _Swatch(this.name, this.color);
}
