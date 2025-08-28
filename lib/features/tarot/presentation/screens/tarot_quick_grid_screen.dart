import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/tarot_card_lite.dart';
import 'tarot_quick_detail_screen.dart';

class TarotQuickGridScreen extends StatefulWidget {
  const TarotQuickGridScreen({super.key});

  @override
  State<TarotQuickGridScreen> createState() => _TarotQuickGridScreenState();
}

class _TarotQuickGridScreenState extends State<TarotQuickGridScreen> {
  List<TarotCardLite> _cards = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadJson();
  }

  Future<void> _loadJson() async {
    try {
      const path = 'assets/tarot/data/tarot_cards.json';
      final raw = await rootBundle.loadString(path);
      final list = jsonDecode(raw) as List<dynamic>;
      setState(() {
        _cards = list
            .map((e) => TarotCardLite.fromJson(e as Map<String, dynamic>))
            .toList();
        _error = null;
      });
    } catch (e) {
      setState(() => _error = 'Failed to load tarot_cards.json: $e');
    }
  }

  Future<void> _shuffleWithPopup() async {
    // show blocking popup
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const _ShufflingDialog(),
    );
    // dialog dismiss is controlled by us below
  }

  void _performShuffle() {
    setState(() {
      _cards = List<TarotCardLite>.from(_cards)..shuffle(Random());
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tarot')),
        body: Center(child: Text(_error!)),
      );
    }
    if (_cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Tarot')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Tarot')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // layout config
          const cols = 6;
          const rows = 13;

          // padding & spacing
          const outerHPad = 12.0;
          const outerVPad = 12.0;
          const crossAxisSpacing = 6.0;
          const mainAxisSpacing = 6.0;

          // reserve space for bottom button
          const buttonHeight = 48.0;
          const buttonVPad = 14.0;

          final usableWidth = constraints.maxWidth - (outerHPad * 2);
          final usableHeight = constraints.maxHeight -
              (outerVPad * 2) -
              (buttonHeight + buttonVPad * 2);

          final tileWidth =
              (usableWidth - crossAxisSpacing * (cols - 1)) / cols;
          final tileHeight =
              (usableHeight - mainAxisSpacing * (rows - 1)) / rows;
          final childAspectRatio = tileWidth / tileHeight;

          return Column(
            children: [
              // grid (fixed height, no scroll)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: outerHPad, vertical: outerVPad),
                child: SizedBox(
                  height: usableHeight,
                  width: double.infinity,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _cards.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      mainAxisSpacing: mainAxisSpacing,
                      crossAxisSpacing: crossAxisSpacing,
                      childAspectRatio: childAspectRatio,
                    ),
                    itemBuilder: (context, index) {
                      final c = _cards[index];
                      return _CardBackTile(
                        heroTag: c.id,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TarotQuickDetailScreen(card: c),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              // bottom shuffle button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: outerHPad,
                  vertical: buttonVPad,
                ),
                child: SizedBox(
                  height: buttonHeight,
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.shuffle),
                    label: const Text('Shuffle'),
                    onPressed: () async {
                      // 1) show popup
                      final future = _shuffleWithPopup();

                      // 2) wait ~2 seconds, then perform shuffle and close popup
                      await Future.delayed(const Duration(seconds: 2));
                      if (!mounted) return;
                      _performShuffle();
                      Navigator.of(context, rootNavigator: true).pop(); // close popup

                      await future; // ensure dialog future completes cleanly
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ShufflingDialog extends StatefulWidget {
  const _ShufflingDialog();

  @override
  State<_ShufflingDialog> createState() => _ShufflingDialogState();
}

class _ShufflingDialogState extends State<_ShufflingDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    // 900ms per cycle → smooth dot step
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Big, blocking dialog
    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SizedBox(
          width: 360,
          height: 220,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.style, size: 56, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 24),
                AnimatedBuilder(
                  animation: _ctrl,
                  builder: (_, __) {
                    // 0..1 → 0,1,2,3 dots
                    final phase = (_ctrl.value * 4).floor() % 4; // 0..3
                    final dots = '.' * phase;
                    return Text(
                      'Shuffling$dots',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Please wait a moment',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// simple back-tile
class _CardBackTile extends StatelessWidget {
  final String heroTag;
  final VoidCallback onTap;
  const _CardBackTile({required this.heroTag, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Hero(
          tag: heroTag,
          child: AspectRatio(
            aspectRatio: 2.5 / 4,
            child: Image.asset(
              'assets/tarot/back.jpg',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
