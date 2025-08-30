import 'package:flutter/material.dart';

class StonesSection extends StatefulWidget {
  const StonesSection({super.key});

  @override
  State<StonesSection> createState() => _StonesSectionState();
}

class _StonesSectionState extends State<StonesSection> {
  int _selected = 0;

  // Stone data (Tamil labels + image file names under assets/stones/)
  static final _items = <_StoneInfo>[
    _StoneInfo(
      grahaTa: 'சூரியன்',
      stoneTa: 'மாணிக்கம்',
      image: 'manikkam.jpeg',
      descTa:
      'மாணிக்கம் (சூரியனுக்கு) - இது பெயர், புகழ், வீரியம், நல்லொழுக்கம், அரவணைப்பு மற்றும் கட்டளையிடும் திறனை அளிக்கிறது. இது ஒரு நபரை அவர் பிறந்த இடத்தை விட உயர்ந்த நிலைக்கு உயர்த்தும்.',
      tileColor: const Color(0xFFFFF0E1),
    ),
    _StoneInfo(
      grahaTa: 'சந்திரன்',
      stoneTa: 'முத்து',
      image: 'muthu.jpeg',
      descTa:
      'முத்து (சந்திரனுக்கு) - பேரிக்காய் மனத் திறன்களை வலுப்படுத்துகிறது, உணர்ச்சிகளை அமைதிப்படுத்துகிறது மற்றும் மன அமைதியைத் தூண்டுகிறது. மணமகள் தனது திருமணத்தின் போது அணியும் முத்து மூக்குத்தி மற்றும் நெக்லஸ் தாம்பத்திய பேரின்பத்தை உறுதி செய்கிறது.',
      tileColor: const Color(0xFFEFF8FF),
    ),
    _StoneInfo(
      grahaTa: 'செவ்வாய்',
      stoneTa: 'பவளம்',
      image: 'pavazham.jpeg',
      descTa:
      'சிவப்பு பவளம் (செவ்வாய் கிரகத்திற்கு) - ஒருவர் அதிக தைரியமாக இருக்க உதவுகிறது. இரத்த நோய்களுக்கும் இது பரிந்துரைக்கப்படுகிறது.',
      tileColor: const Color(0xFFFFEEF1),
    ),
    _StoneInfo(
      grahaTa: 'புதன்',
      stoneTa: 'மரகதம்',
      image: 'maragatham.jpeg',
      descTa:
      'மரகதம் (புதனுக்கு) – நினைவாற்றல், தொடர்பு மற்றும் உள்ளுணர்வை மேம்படுத்த உதவுகிறது. செல்வத்தைப் பெறுவதற்கும் இது பயனுள்ளதாக இருக்கும்.',
      tileColor: const Color(0xFFEFFBF1),
    ),
    _StoneInfo(
      grahaTa: 'குரு',
      stoneTa: 'புஷ்பராகம்',
      image: 'pushparagam.jpeg',
      descTa:
      'மஞ்சள் நீலக்கல் / புஷ்பராகம் - இது ஒருவரின் நிதி நிலையை மேம்படுத்த அணியப்படுகிறது. இது ஒரு பெண்ணுக்கு பொருத்தமான பொருத்தத்தைக் கண்டுபிடிப்பதில் உள்ள தடைகளை நீக்கி திருமண வாய்ப்புகளை மேம்படுத்துகிறது.',
      tileColor: const Color(0xFFFFF8E5),
    ),
    _StoneInfo(
      grahaTa: 'சுக்கிரன்',
      stoneTa: 'வைரம்',
      image: 'vairam.jpeg',
      descTa:
      'வைரம் - பெயர், புகழ் மற்றும் செல்வத்தை சம்பாதிக்க இது அணியப்படுகிறது. இது பாலியல் வீரியத்தை மேம்படுத்துவதாகவும் கூறப்படுகிறது.',
      tileColor: const Color(0xFFFFF1F9),
    ),
    _StoneInfo(
      grahaTa: 'சனி',
      stoneTa: 'நீலம்',
      image: 'neelam.jpeg',
      descTa:
      'நீல நீலக்கல் (சனி கிரகத்திற்கு) - இது தீய சக்திகளைத் தடுத்து துரதிர்ஷ்டத்தைத் தவிர்க்க உதவுகிறது. சில நேரங்களில், இந்த கல் எதிர்மறையாக செயல்படுகிறது, எனவே அணிவதற்கு முன்பு ஒரு வாரம் சோதிக்க வேண்டும். இது நல்ல ஆரோக்கியம், செல்வம், மகிழ்ச்சி அளிக்கிறது; இழந்த செல்வத்தையும் சொத்துக்களையும் மீட்டெடுக்க உதவும்.',
      tileColor: const Color(0xFFEFF3FF),
    ),
    _StoneInfo(
      grahaTa: 'ராகு',
      stoneTa: 'கோமேதகம்',
      image: 'gomedhakam.jpeg',
      descTa:
      'ஹோசோனைட் (ராகுவுக்கானது) - ராகு இலக்குகளை நிறைவேற்றுவதில் தடைகளை உருவாக்குவதாகக் கூறப்படுகிறது. இந்த ரத்தினம் மக்களுடனான உறவை மேம்படுத்துகிறது மற்றும் திடீர் துரதிர்ஷ்டங்களிலிருந்து பாதுகாக்கிறது. வயிற்று நோய்களைத் தவிர்க்கவும், பேரழிவுகள் மற்றும் தீய சக்திகளைத் தடுக்கவும் உதவும்.',
      tileColor: const Color(0xFFFFF4EA),
    ),
    _StoneInfo(
      grahaTa: 'கேது',
      stoneTa: 'வைடூரியம் (பூனைக்கண்)',
      image: 'vaiduriyam.jpeg',
      descTa:
      'பூனைக்கண் (கேதுவுக்கு) - இந்த ரத்தினம் அணிபவரை எதிரிகள், மர்மமான ஆபத்துகள் மற்றும் நோய்களிலிருந்து பாதுகாக்கிறது. நீரில் மூழ்குதல், போதை போன்ற விபத்துகளிலிருந்து தாயத்து போல செயல்படுகிறது; சூதாட்டக்காரர்களுக்கு நல்ல அதிர்ஷ்டத்தையும் தருவதாகக் கூறப்படுகிறது.',
      tileColor: const Color(0xFFEFFAF9),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final borderColor = Colors.grey.shade300;
    final selected = _items[_selected];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.auto_awesome, size: 20),
              const SizedBox(width: 8),
              Text(
                'ரத்தினங்கள் (Stones)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ]),
            const SizedBox(height: 12),

            // 3x3 pastel grid of stones (taller cells + single-line labels)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.86, // <— taller cell (fixes overflow)
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
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: it.tileColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isSel ? Colors.black87 : borderColor, width: isSel ? 1.4 : 1),
                      boxShadow: isSel
                          ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _StoneImage(filename: it.image, size: 40), // was 44
                        const SizedBox(height: 8),
                        Text(
                          it.stoneTa,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis, // single line
                        ),
                        const SizedBox(height: 2),
                        Text(
                          it.grahaTa,
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis, // single line
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Details card
            _StoneDetails(info: selected),
          ],
        ),
      ),
    );
  }
}

class _StoneDetails extends StatelessWidget {
  const _StoneDetails({required this.info});
  final _StoneInfo info;

  @override
  Widget build(BuildContext context) {
    final borderColor = Colors.grey.shade300;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StoneImage(filename: info.image, size: 72),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _Chip(text: info.grahaTa),
                      _Chip(text: info.stoneTa),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    info.descTa,
                    style: const TextStyle(fontSize: 15.5, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
    );
  }
}

class _StoneImage extends StatelessWidget {
  const _StoneImage({required this.filename, required this.size});
  final String filename;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 6),
      child: Image.asset(
        'assets/stones/$filename',
        height: size,
        width: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: size,
          width: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(size / 6),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const Icon(Icons.image_not_supported, size: 20, color: Colors.black54),
        ),
      ),
    );
  }
}

class _StoneInfo {
  final String grahaTa;
  final String stoneTa;
  final String image; // file in assets/stones/
  final String descTa;
  final Color tileColor;

  const _StoneInfo({
    required this.grahaTa,
    required this.stoneTa,
    required this.image,
    required this.descTa,
    required this.tileColor,
  });
}
