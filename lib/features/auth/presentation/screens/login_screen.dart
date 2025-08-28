import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../viewmodels/auth_view_model.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginRegisterState();
}

class _LoginRegisterState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;

  // Login
  final _loginPhoneCtrl = TextEditingController();
  final _loginPwdCtrl   = TextEditingController();

  // Register
  final _regNameCtrl  = TextEditingController();
  final _regPhoneCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPwdCtrl   = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _loginPhoneCtrl.dispose();
    _loginPwdCtrl.dispose();
    _regNameCtrl.dispose();
    _regPhoneCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPwdCtrl.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _doLogin() async {
    final phone = _loginPhoneCtrl.text.trim();
    final pass  = _loginPwdCtrl.text.trim();
    if (phone.length < 10 || pass.length < 4) {
      _toast('Enter valid phone and password');
      return;
    }
    final vm = ref.read(authProvider.notifier);
    final res = await vm.login(phone: phone, password: pass);
    if (!res.success) {
      _toast(res.message.isEmpty ? 'Login failed' : res.message);
      return;
    }
    if (!mounted) return;
    context.go('/');
  }

  Future<void> _doRegister() async {
    final name  = _regNameCtrl.text.trim();
    final phone = _regPhoneCtrl.text.trim();
    final email = _regEmailCtrl.text.trim();
    final pass  = _regPwdCtrl.text.trim();

    // 🔴 make email required
    if (name.isEmpty || phone.length < 10 || email.isEmpty || pass.length < 4) {
      _toast('Enter name, valid phone, email and password');
      return;
    }

    final vm = ref.read(authProvider.notifier);

    // 🔴 always send email (no nullable)
    final res = await vm.register(name: name, phone: phone, password: pass, email: email);
    if (kDebugMode) {
      print('[REGISTER] success=${res.success} msg=${res.message}');
    }
    if (!res.success) {
      _toast(res.message.isEmpty ? 'Registration failed' : res.message);
      return;
    }
    if (!mounted) return;
    context.go('/');
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
              child: const Text('AUTHENTICATION',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13, letterSpacing: 1)),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tab,
          labelColor: Colors.black,
          tabs: const [Tab(text: 'LOGIN'), Tab(text: 'REGISTER')],
        ),
      ),
      body: AbsorbPointer(
        absorbing: st.isLoading,
        child: Stack(
          children: [
            TabBarView(
              controller: _tab,
              children: [
                _LoginTab(phoneCtrl: _loginPhoneCtrl, pwdCtrl: _loginPwdCtrl, onLogin: _doLogin),
                _RegisterTab(
                  nameCtrl: _regNameCtrl,
                  phoneCtrl: _regPhoneCtrl,
                  emailCtrl: _regEmailCtrl,
                  pwdCtrl: _regPwdCtrl,
                  onRegister: _doRegister,
                ),
              ],
            ),
            if (st.isLoading)
              const ColoredBox(
                color: Color(0x55FFFFFF),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}

class _LoginTab extends StatelessWidget {
  final TextEditingController phoneCtrl;
  final TextEditingController pwdCtrl;
  final VoidCallback onLogin;
  const _LoginTab({required this.phoneCtrl, required this.pwdCtrl, required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        children: [
          _Logo(),
          const SizedBox(height: 18),
          TextField(
            controller: phoneCtrl,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              counterText: '',
              labelText: 'Phone Number',
              hintText: 'Enter 10-digit number',
              prefixIcon: Icon(Icons.phone),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: pwdCtrl,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onLogin,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
              child: const Text('LOGIN', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }
}

class _RegisterTab extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController pwdCtrl;
  final VoidCallback onRegister;

  const _RegisterTab({
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.emailCtrl,
    required this.pwdCtrl,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        children: [
          _Logo(),
          const SizedBox(height: 18),
          TextField(
            controller: nameCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: phoneCtrl,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              counterText: '',
              labelText: 'Phone Number',
              hintText: 'Enter 10-digit number',
              prefixIcon: Icon(Icons.phone),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 12),
          TextField(
            controller: pwdCtrl,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onRegister,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
              child: const Text('CREATE ACCOUNT', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
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
    );
  }
}
