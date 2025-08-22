import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/menu_item.dart';

final menuItemsProvider = Provider<List<MenuItem>>((ref) {
  return const [
    MenuItem(title: 'HOROSCOPE', route: '/horoscope'),
    MenuItem(title: 'ALP MATCH MAKING', route: '/alp-matchmaking'),

    MenuItem(title: 'PANCHANGA', route: '/panchanga'),
    MenuItem(title: 'PRASHNA', route: '/prashna'),

    MenuItem(title: 'HOROSCOPE MATCHING', route: '/horoscope-matching', isFullWidth: true),

    MenuItem(title: 'PURCHASE', route: '/purchase', isHighlighted: true),
    MenuItem(title: 'SETTINGS', route: '/settings'),

    MenuItem(title: 'ABOUT FOUNDER AND METHOD', route: '/about-founder'),
    MenuItem(title: 'YOUTUBE VIDEOS', route: '/youtube'),

    MenuItem(title: 'SHARES', route: '/shares'),
    MenuItem(title: 'TRAINING VIDEO', route: '/training'),

    MenuItem(title: 'TRANSIT DATA', route: '/transit'),
    MenuItem(title: 'NUMEROLOGY', route: '/numerology'),
  ];
});
