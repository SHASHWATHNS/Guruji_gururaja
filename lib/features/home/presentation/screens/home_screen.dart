import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../horoscope/presentation/screens/horoscope_screen.dart';
import '../../../panchanga/presentation/screens/panchanga_screen.dart';

import '../widgets/home_header.dart';
import '../widgets/menu_button.dart';
import 'package:go_router/go_router.dart';


class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      // Back to the old overall light yellow
      backgroundColor: const Color(0xFFFFF3CD),
      // No AppBar (as before)
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Column(
            children: [
              const HomeHeader(),
              const SizedBox(height: 0),

              // Row 1
              _twoTiles(
                context,
                left: MenuButton(
                  label: 'HOROSCOPE',
                  icon: Icons.auto_awesome,
                  color: Colors.red.shade400,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HoroscopeScreen()),
                  ),
                ),
                right: MenuButton(
                  label: 'THIRUMANA\nPORUTHAM',
                  icon: Icons.favorite,
                  color: Colors.pink.shade400,
                  onTap: () => _soon(context, 'Thirumana Porutham'),
                ),
              ),

              // Row 2
              _twoTiles(
                context,
                left: MenuButton(
                  label: 'PANCHANGAM',
                  icon: Icons.calendar_today,
                  color: Colors.orange.shade600,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PanchangaScreen()),
                  ),
                ),
                right: MenuButton(
                  label: 'NUMEROLOGY',
                  icon: Icons.calculate,
                  color: Colors.teal.shade600,
                  onTap: () => _soon(context, 'Numerology'),
                ),
              ),

              // Row 3
              _twoTiles(
                context,
                left: MenuButton(
                  label: 'JAMMUKUL\nPRASHANA',
                  icon: Icons.question_answer,
                  color: Colors.indigo.shade500,
                  onTap: () => _soon(context, 'Jammukul Prashana'),
                ),
                right: MenuButton(
                  label: 'TARAT',
                  icon: Icons.style,
                  color: Colors.purple.shade500,
                  onTap: () => _soon(context, 'Tarat'),
                ),
              ),

              const SizedBox(height: 8),

              // Purchase
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.shopping_bag),
                  label: const Text(
                    'PURCHASE',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                  onPressed: () => _soon(context, 'Purchase'),
                ),
              ),

              const SizedBox(height: 12),

              // Row 4
              _twoTiles(
                context,
                left: MenuButton(
                  label: 'ABOUT',
                  icon: Icons.info,
                  color: Colors.blueGrey.shade600,
                  onTap: () => _soon(context, 'About'),
                ),
                right: MenuButton(
                  label: 'CLASS\nFEEDBACK',
                  icon: Icons.rate_review,
                  color: Colors.deepOrange.shade400,
                  onTap: () => _soon(context, 'Class Feedback'),
                ),
              ),

              // Row 5
              _twoTiles(
                context,
                left: MenuButton(
                  label: 'TRANSIT DATA',
                  icon: Icons.swap_horiz,
                  color: Colors.brown.shade500,
                  onTap: () => _soon(context, 'Transit Data'),
                ),
                right: MenuButton(
                  label: 'CLASS\nVIDEO',
                  icon: Icons.video_library,
                  color: Colors.blue.shade600,
                  onTap: () => _soon(context, 'Class Video'),
                ),
              ),

              // Row 6
              _twoTiles(
                context,
                left: MenuButton(
                  label: 'YOUTUBE\nVIDEO',
                  icon: Icons.play_circle_fill,
                  color: Colors.red.shade700,
                  onTap: () => _soon(context, 'YouTube Video'),
                ),
                right: MenuButton(
                  label: 'SETTINGS',
                  icon: Icons.settings,
                  color: Colors.grey.shade700,
                  onTap: () => _soon(context, 'Settings'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _twoTiles(BuildContext context, {required Widget left, required Widget right}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: left),
          const SizedBox(width: 12),
          Expanded(child: right),
        ],
      ),
    );
  }

  static void _soon(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label — coming soon')),
    );
  }
}
