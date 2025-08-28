import 'package:flutter/material.dart';
import '../models/tarot_card_lite.dart';

class TarotQuickDetailScreen extends StatefulWidget {
  final TarotCardLite card;
  const TarotQuickDetailScreen({super.key, required this.card});

  @override
  State<TarotQuickDetailScreen> createState() => _TarotQuickDetailScreenState();
}

class _TarotQuickDetailScreenState extends State<TarotQuickDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flipCtrl;
  late final Animation<double> _flipAnim;

  @override
  void initState() {
    super.initState();
    _flipCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _flipAnim = CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOut);
    Future.delayed(const Duration(milliseconds: 120), () => _flipCtrl.forward());
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTamil = Localizations.localeOf(context).languageCode.toLowerCase() == 'ta';
    final text = isTamil
        ? (widget.card.benefitTa ?? widget.card.benefitEn ?? '')
        : (widget.card.benefitEn ?? widget.card.benefitTa ?? '');

    final backAsset = 'assets/tarot/back.jpg';
    final frontAsset = 'assets/tarot/${widget.card.image}';

    return Scaffold(
      appBar: AppBar(title: Text(widget.card.name)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Hero(
            tag: widget.card.id,
            child: AspectRatio(
              aspectRatio: 2.5 / 4,
              child: AnimatedBuilder(
                animation: _flipAnim,
                builder: (context, _) {
                  final showFront = _flipAnim.value > 0.5;
                  final angle = _flipAnim.value * 3.1415926;
                  final img = showFront
                      ? Image.asset(frontAsset, fit: BoxFit.cover)
                      : Image.asset(backAsset, fit: BoxFit.cover);
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(angle),
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(showFront ? 3.1415926 : 0),
                      child: ClipRRect(borderRadius: BorderRadius.circular(16), child: img),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.card.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.45),
          ),
        ],
      ),
    );
  }
}
