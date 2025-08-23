import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class YoutubeVideosScreen extends StatelessWidget {
  const YoutubeVideosScreen({super.key});

  // TODO: Replace with your real links/titles
  static const _channelUrl = 'https://www.youtube.com/@gurujigururaja/videos';
  static const _videos = <({String title, String url})>[
    (title: 'Astro Intro – Basics', url: 'https://youtu.be/1EjAT2QP-Fc?si=StioU2D1QcMEFvL3'),
    (title: 'Rasi Palan – Weekly', url: 'https://youtu.be/Mk8GB0tVd3Y?si=c8Hpi7vmgWscCuzN'),
    (title: 'Panchang Overview', url: 'https://youtu.be/ShafDwdXGwo?si=Qp3t2y0DHwOQ9Mpw'),
    (title: 'Numerology Guide', url: 'https://youtu.be/yBinsSRImms?si=Ay2xBJmX9L8rE6mq'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('YouTube')),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _videos.length + 1, // +1 for channel button
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          if (i == 0) {
            return _ChannelCard(
              onTap: () => _open(_channelUrl),
              title: 'Open My YouTube Channel',
            );
          }
          final v = _videos[i - 1];
          return _VideoButton(title: v.title, onTap: () => _open(v.url));
        },
      ),
    );
  }

  Future<void> _open(String urlStr) async {
    final url = Uri.parse(urlStr);
    // Prefer opening in YouTube app / external browser
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // Fallback to in‑app webview
      await launchUrl(url, mode: LaunchMode.inAppWebView);
    }
  }
}

class _ChannelCard extends StatelessWidget {
  const _ChannelCard({required this.onTap, required this.title});
  final VoidCallback onTap;
  final String title;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.surface,
          boxShadow: kElevationToShadow[1],
        ),
        child: Row(
          children: [
            const Icon(Icons.ondemand_video, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.titleMedium),
            ),
            const Icon(Icons.open_in_new),
          ],
        ),
      ),
    );
  }
}

class _VideoButton extends StatelessWidget {
  const _VideoButton({required this.title, required this.onTap});
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        children: [
          const Icon(Icons.play_circle_outline),
          const SizedBox(width: 12),
          Expanded(child: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis)),
          const Icon(Icons.open_in_new),
        ],
      ),
    );
  }
}
