import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_demo/feature/auth/login_screen.dart';
import 'package:firebase_demo/feature/auth/verify_email.dart';
import 'package:firebase_demo/feature/home_screen.dart';
import 'package:firebase_demo/shared/configuration/firebase_options.dart';
import 'package:firebase_demo/shared/default_on_tap_outside_unfocus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  /// Use local Firebase Auth Emulator during development for safer and faster
  /// testing.
  if (kDebugMode) {
    await FirebaseAuth.instance.useAuthEmulator('127.0.0.1', 9099);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      actions: {
        EditableTextTapOutsideIntent:
            Action<EditableTextTapOutsideIntent>.overridable(
              context: context,
              defaultAction: EditableTextTapOutsideAction(),
            ),
      },
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Stream<User?> _streamUser;

  @override
  void initState() {
    super.initState();
    _streamUser = FirebaseAuth.instance.userChanges();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _streamUser,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data!.emailVerified) {
          return const HomeScreen();
        } else if (snapshot.hasData && !snapshot.data!.emailVerified) {
          return const VerifyEmailCodeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
