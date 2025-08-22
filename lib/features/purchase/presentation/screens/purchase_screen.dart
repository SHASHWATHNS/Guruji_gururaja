import 'package:flutter/material.dart';
class PurchaseScreen extends StatelessWidget {
  const PurchaseScreen({super.key});
  @override
  Widget build(BuildContext context) => const _Stub(title: 'Purchase');
}
class _Stub extends StatelessWidget {
  final String title; const _Stub({required this.title, super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(title)), body: Center(child: Text('$title screen')));
}
