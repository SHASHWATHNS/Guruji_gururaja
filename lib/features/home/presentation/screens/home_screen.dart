import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../viewmodels/home_view_model.dart';
import '../widgets/home_header.dart';
import '../widgets/menu_button.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(menuItemsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: HomeHeader()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const gap = 12.0;
                  final twoColWidth = (constraints.maxWidth - gap) / 2;

                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      for (final item in items)
                        SizedBox(
                          width: item.isFullWidth ? constraints.maxWidth : twoColWidth,
                          child: MenuButton(
                            text: item.title,
                            highlighted: item.isHighlighted,
                            onTap: () => context.push(item.route),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
