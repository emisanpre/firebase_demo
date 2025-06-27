import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> register() async {
    final currentContext = context;
    try {
      final auth = FirebaseAuth.instance;
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      await userCredential.user!.sendEmailVerification();
      if (!currentContext.mounted) return;
      ScaffoldMessenger.of(currentContext).showSnackBar(
        const SnackBar(content: Text('Code verification sent to your email.')),
      );
      Navigator.pop(currentContext);
    } on FirebaseException catch (e) {
      if (!currentContext.mounted) return;
      ScaffoldMessenger.of(currentContext).showSnackBar(
        SnackBar(content: Text('Unexpected error: $e')),
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
      appBar: AppBar(title: const Text('Register')),
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
              onPressed: register,
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
