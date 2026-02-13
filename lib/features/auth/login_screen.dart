import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;
  String? err;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  String _messageForError(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'user-disabled':
          return 'Your account is deactivated.';
        case 'user-not-found':
          return 'No account exists for this email.';
        case 'wrong-password':
          return 'Incorrect email or password.';
        case 'invalid-credential':
          return 'Incorrect email or password.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        case 'network-request-failed':
          return 'Network error. Please check your connection.';
        default:
          return 'Login failed. Please try again.';
      }
    }

    final msg = e.toString();
    if (msg.contains('Your account is deactivated')) {
      return 'Your account is deactivated.';
    }
    return 'Login failed. Please try again.';
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      loading = true;
      err = null;
    });
    try {
      await action();
      if (mounted) context.go('/');
    } catch (e) {
      setState(() => err = _messageForError(e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
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
            const SizedBox(height: 14),
            if (err != null) Text(err!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: loading
                  ? null
                  : () => _run(() => ref
                      .read(authProvider.notifier)
                      .login(emailCtrl.text.trim(), passCtrl.text.trim())),
              child: Text(loading ? '...' : 'Login'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => context.push('/register'),
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
