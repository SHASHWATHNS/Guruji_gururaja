import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:guraj_astro/features/auth/presentation/viewmodels/auth_view_model.dart';
import '../../../../../core/constants/app_colors.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  Timer? _timer;
  int _secs = 0;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secs = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secs <= 1) {
        t.cancel();
        setState(() => _secs = 0);
      } else {
        setState(() => _secs--);
      }
    });
  }

  Future<void> _requestOtp() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid phone number')),
      );
      return;
    }
    await ref.read(authProvider.notifier).requestOtp(phone);
    _startTimer();
  }

  Future<void> _verify() async {
    final ok = await ref.read(authProvider.notifier).verifyOtp(_otpCtrl.text.trim());
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP')),
      );
      return;
    }
    if (!mounted) return;
    context.go('/'); // go to Home and clear stack
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBEA),
      appBar: AppBar(
        backgroundColor: AppColors.headerBar,
        centerTitle: true,
        leading: const SizedBox.shrink(),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('GURUJI GURURAJA',
                style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black, fontSize: 18)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)),
              child: const Text('LOGIN',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13, letterSpacing: 1)),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: Colors.black12,
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/img.png',
                    width: 88, height: 88, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 88, height: 88, color: Colors.white, alignment: Alignment.center,
                      child: const Text('GG', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Phone
              TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  counterText: '',
                  labelText: 'Phone Number',
                  hintText: 'Enter 10‑digit number',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // Request OTP
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: st.isRequestingOtp || _secs > 0 ? null : _requestOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange, foregroundColor: Colors.white, elevation: 0,
                  ),
                  child: Text(_secs > 0 ? 'Resend in $_secs s' : 'Request OTP',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              if (st.otpHint.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('OTP: ${st.otpHint}', style: const TextStyle(color: Colors.black54)),
                ),

              const SizedBox(height: 16),

              // OTP
              TextField(
                controller: _otpCtrl,
                keyboardType: TextInputType.number,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  counterText: '',
                  labelText: 'Enter OTP',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // Login
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _verify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700, foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14), elevation: 0,
                  ),
                  child: const Text('LOGIN',
                      style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
