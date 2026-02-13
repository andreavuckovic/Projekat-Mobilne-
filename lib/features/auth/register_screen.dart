import 'package:firebase_auth/firebase_auth.dart';
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
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final pass2Ctrl = TextEditingController();

  bool loading = false;
  String? err;

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    pass2Ctrl.dispose();
    super.dispose();
  }

  String _messageForError(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'An account with this email already exists.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'weak-password':
          return 'Password must meet the requirements.';
        case 'network-request-failed':
          return 'Network error. Please check your connection.';
        default:
          return 'Registration failed. Please try again.';
      }
    }

    final msg = e.toString();
    if (msg.contains('Your account is deactivated')) {
      return 'Your account is deactivated.';
    }
    return 'Registration failed. Please try again.';
  }

  bool _hasUppercase(String s) {
    for (final ch in s.runes) {
      final c = String.fromCharCode(ch);
      if (c.toUpperCase() == c && c.toLowerCase() != c) return true;
    }
    return false;
  }

  bool _hasNumber(String s) {
    for (final ch in s.runes) {
      if (ch >= 48 && ch <= 57) return true;
    }
    return false;
  }

  bool _hasSpecial(String s) {
    const specials = r'!@#$%^&*()_+-=[]{};:"\|,.<>/?~`';
    for (final ch in s.runes) {
      final c = String.fromCharCode(ch);
      if (specials.contains(c)) return true;
    }
    return false;
  }

  Future<void> _register() async {
    setState(() {
      loading = true;
      err = null;
    });

    final name = nameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final password = passCtrl.text.trim();
    final confirm = pass2Ctrl.text.trim();

    if (name.isEmpty) {
      setState(() {
        err = 'Please enter your name.';
        loading = false;
      });
      return;
    }

    if (!email.contains('@')) {
      setState(() {
        err = 'Please enter a valid email address.';
        loading = false;
      });
      return;
    }

    if (password.length < 8 ||
        !_hasUppercase(password) ||
        !_hasNumber(password) ||
        !_hasSpecial(password)) {
      setState(() {
        err =
            'Password must be at least 8 characters long and include at least one uppercase letter, one number and one special character.';
        loading = false;
      });
      return;
    }

    if (password != confirm) {
      setState(() {
        err = 'Passwords do not match.';
        loading = false;
      });
      return;
    }

    try {
      await ref.read(authProvider.notifier).register(email, password, name);
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
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 10),
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
