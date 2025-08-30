import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/auth/presentation/viewmodels/auth_view_model.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
  late final Animation<double> _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);

  @override
  void initState() {
    super.initState();
    _ctrl.repeat(reverse: true);
    scheduleMicrotask(() async {
      await ref.read(authProvider.notifier).loadSession();
      await Future.delayed(const Duration(milliseconds: 1800));
      if (!mounted) return;
      final loggedIn = ref.read(authProvider).isLoggedIn;
      context.go(loggedIn ? '/' : '/login');
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: FadeTransition(opacity: _fade, child: const _LogoBox()),
        ),
      ),
    );
  }
}

class _LogoBox extends StatelessWidget {
  const _LogoBox({super.key});
  @override
  Widget build(BuildContext context) {
    const double size = 500;
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/images/splash.jpg',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.white,
          alignment: Alignment.center,
          child: const Text('Splash',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.black87)),
        ),
      ),
    );
  }
}
