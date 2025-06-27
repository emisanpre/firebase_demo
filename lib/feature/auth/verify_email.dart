import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerifyEmailCodeScreen extends StatefulWidget {
  const VerifyEmailCodeScreen({super.key});

  @override
  State<VerifyEmailCodeScreen> createState() => _VerifyEmailCodeScreenState();
}

class _VerifyEmailCodeScreenState extends State<VerifyEmailCodeScreen> {
  late final TextEditingController _codeController;
  late final FirebaseAuth _auth;
  late final StreamController<VerifyEmailStatus> _statusController;
  late bool _isCodeNotEmpty;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    _auth = FirebaseAuth.instance;
    _statusController = StreamController<VerifyEmailStatus>();
    _isCodeNotEmpty = false;
    _codeController.addListener(_onCodeChanged);
  }

  void _onCodeChanged() {
    final isNotEmpty = _codeController.text.trim().isNotEmpty;
    if (isNotEmpty != _isCodeNotEmpty) {
      setState(() {
        _isCodeNotEmpty = isNotEmpty;
      });
    }
  }

  @override
  void dispose() {
    _codeController
      ..removeListener(_onCodeChanged)
      ..dispose();
    _statusController.close();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    final currentContext = context;
    final code = _codeController.text.trim();
    _statusController.add(VerifyEmailStatus.loading);

    try {
      final action = await _auth.checkActionCode(code);
      final operation = action.operation;

      if (operation == ActionCodeInfoOperation.verifyEmail) {
        await _auth.applyActionCode(code);
        _statusController.add(VerifyEmailStatus.success);
      } else {
        if(!currentContext.mounted) return;
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(
            content: Text('''Code operation must be ActionCodeInfoOperation.verifyEmail.\nActual: $operation'''),
          ),
        );
        _statusController.add(VerifyEmailStatus.invalidOperation);
      }
    } on FirebaseAuthException catch (e) {
      if(!currentContext.mounted) return;
      ScaffoldMessenger.of(currentContext).showSnackBar(
        SnackBar(
          content: Text('Firebase error: ${e.message}'),
        ),
      );
      _statusController.add(VerifyEmailStatus.error);
    } on Exception catch (e) {
      if (!currentContext.mounted) return;
      ScaffoldMessenger.of(currentContext).showSnackBar(
        SnackBar(content: Text('Unexpected error: $e')),
      );
      _statusController.add(VerifyEmailStatus.error);
    }
  }

  Future<void> _resendCode() async {
    final currentContext = context;
    try{
      await _auth.currentUser!.sendEmailVerification();

      if (!currentContext.mounted) return;
      ScaffoldMessenger.of(currentContext).showSnackBar(
        const SnackBar(
          content: Text('Code verification sent to your email.'),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if(!currentContext.mounted) return;
      ScaffoldMessenger.of(currentContext).showSnackBar(
        SnackBar(
          content: Text('Firebase error: ${e.message}'),
        ),
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
      appBar: AppBar(title: const Text('Verify email')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Input the code you received on the your email.'),
            const SizedBox(height: 8),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Email code',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isCodeNotEmpty 
                ? _verifyCode
                : null,
              child: const Text('Verify'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _resendCode,
              child: const Text('Resend code'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _auth.signOut,
              child: const Text('Log out'),
            ),
            const SizedBox(height: 24),
            StreamBuilder<VerifyEmailStatus>(
              stream: _statusController.stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();

                switch (snapshot.requireData) {
                  case VerifyEmailStatus.loading:
                    return const CircularProgressIndicator();
                  case VerifyEmailStatus.success:
                    return const Text('✅ Email verified successfully.');
                  case VerifyEmailStatus.invalidOperation:
                    return const Text(
                      '⚠️ The code is invalid.',
                    );
                  case VerifyEmailStatus.error:
                    return const Text(
                      '❌ Error verifying the code.',
                    );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

enum VerifyEmailStatus {
  loading,
  success,
  invalidOperation,
  error,
}
