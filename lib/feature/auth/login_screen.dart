import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_demo/feature/auth/register_screen.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> login() async {
    final currentContext = context;
    try {
      final auth = FirebaseAuth.instance;
      final userCredential = await auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = userCredential.user;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();

        if (!currentContext.mounted) return;
        ScaffoldMessenger.of(currentContext).showSnackBar(
          const SnackBar(
            content: Text('Verify your email before continue.'),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!currentContext.mounted) return;
      ScaffoldMessenger.of(currentContext).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    } on Exception catch (e) {
      if (!currentContext.mounted) return;
      ScaffoldMessenger.of(currentContext).showSnackBar(
        SnackBar(content: Text('Unexpected error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log in')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: login,
              child: const Text('Log in'),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterScreen()),
              ),
              child: const Text('Create an account'),
            ),
          ],
        ),
      ),
    );
  }
}
