import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final pass2Ctrl = TextEditingController();

  bool loading = false;
  String? err;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    pass2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() { loading = true; err = null; });

    final email = emailCtrl.text.trim();
    final p1 = passCtrl.text.trim();
    final p2 = pass2Ctrl.text.trim();

    if (!email.contains('@')) {
      setState(() { err = 'Unesi ispravan email'; loading = false; });
      return;
    }
    if (p1.length < 6) {
      setState(() { err = 'Šifra mora imati minimum 6 karaktera'; loading = false; });
      return;
    }
    if (p1 != p2) {
      setState(() { err = 'Šifre se ne poklapaju'; loading = false; });
      return;
    }

    try {
      await ref.read(authProvider.notifier).register(email, p1);
      if (mounted) context.go('/');
    } catch (e) {
      setState(() => err = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: pass2Ctrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm password'),
            ),
            const SizedBox(height: 14),
            if (err != null) Text(err!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: loading ? null : _register,
              child: Text(loading ? '...' : 'Create account'),
            ),
          ],
        ),
      ),
    );
  }
}
 