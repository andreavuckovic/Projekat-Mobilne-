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
  final emailCtrl = TextEditingController(text: 'test@mail.com');

  @override
  void dispose() {
    emailCtrl.dispose();
    super.dispose();
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
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(authProvider.notifier)
                    .loginAsUser(emailCtrl.text.trim());
                context.go('/');
              },
              child: const Text('Login as User'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(authProvider.notifier)
                    .loginAsAdmin(emailCtrl.text.trim());
                context.go('/');
              }, 
              child: const Text('Login as Admin'),
            ),
          ],
        ),
      ),
    );
  }
}
