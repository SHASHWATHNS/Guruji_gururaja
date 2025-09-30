import 'package:flutter/material.dart';
import '../../data/models/good_bad_times_model.dart';
import 'info_row.dart';

class TimingsSection extends StatelessWidget {
  const TimingsSection({super.key, required this.times});

  final GoodBadTimes times;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 18, bottom: 8),
          child: Divider(thickness: 1.2),
        ),
        InfoRow(title: 'ராகு காலம்', value: times.rahuKaalam?.formatHHmm() ?? '00:00 – 00:00'),
        InfoRow(title: 'எமகண்டம்', value: times.yamaGandam?.formatHHmm() ?? '00:00 – 00:00'),
        InfoRow(title: 'குளிகை', value: times.gulikaKalam?.formatHHmm() ?? '00:00 – 00:00'),
        InfoRow(title: 'அபிஜித்', value: times.abhijit?.formatHHmm() ?? '00:00 – 00:00'),
        InfoRow(title: 'பிரம்ம முகூர்த்தம்', value: times.brahmaMuhurat?.formatHHmm() ?? '00:00 – 00:00'),
        InfoRow(title: 'அமிர்த காலம்', value: times.amritKaal?.formatHHmm() ?? '00:00 – 00:00'),
        if (times.durMuhurat.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...List.generate(times.durMuhurat.length, (i) {
            return InfoRow(title: 'துர்முஹூர்த்தம் ${i + 1}', value: times.durMuhurat[i].formatHHmm());
          }),
        ],
        InfoRow(title: 'வர்ஜ்யம்', value: times.varjyam?.formatHHmm() ?? '00:00 – 00:00'),
      ],
    );
  }
}
