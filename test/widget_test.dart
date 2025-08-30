import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Use a RELATIVE import so the test definitely sees your app file.
import '../lib/app/app.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(child: AstroApp()), // <-- no const
    );

    // Sanity check: MaterialApp(router) exists.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
