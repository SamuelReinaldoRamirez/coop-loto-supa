import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _controller = TextEditingController();
  bool _loading = false;

  void _submit() {
    final username = _controller.text.trim();
    if (username.isEmpty) return;
    setState(() => _loading = true);
    // For now simple local "auth": just navigate with the username as query param
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() => _loading = false);
      // navigate to groups page, pass username as query param for safer routing
      context.go('/groups?username=${Uri.encodeComponent(username)}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Nom d\'utilisateur'),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading ? const CircularProgressIndicator() : const Text('Se connecter'),
            ),
          ],
        ),
      ),
    );
  }
}
