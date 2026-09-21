import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _controller = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  final AuthService _auth = AuthService();

  @override
  void initState() {
    super.initState();
    _checkStoredToken();
  }

  Future<void> _checkStoredToken() async {
    setState(() => _loading = true);
    try {
      final ok = await _auth.tryAutoLogin();
      if (ok) {
        final pseudo = await _auth.getPseudo() ?? '';
        if (!mounted) return;
        // context.go('/groups?username=${Uri.encodeComponent(pseudo)}');
        context.go('/home', extra: pseudo);
        return;
      }
    } catch (e) {
      // ignore auto-login errors, show login form
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _submit() async {
    final username = _controller.text.trim();
    if (username.isEmpty) return;
    setState(() => _loading = true);
    final password = _passwordController.text;
    try {
      final resp = await _auth.login(username, password);
      final pseudo = resp['pseudo'] as String? ?? username;
      if (!mounted) return;
      context.go('/home', extra: pseudo);
      // context.go('/groups?username=${Uri.encodeComponent(pseudo)}');
    } catch (e) {
      // show simple error
      if (!mounted) return;
      // show detailed error to help debugging
      final msg = e is Exception ? e.toString() : 'Login failed';
      // also print to console
      // ignore: avoid_print
      print('[Login] error: $msg');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed: $msg')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Mot de passe'),
              obscureText: true,
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
