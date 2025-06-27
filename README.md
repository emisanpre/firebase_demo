# firebase_demo

A Flutter demo app showcasing Firebase Authentication integration.

This project demonstrates how to use Firebase Authentication in Flutter, including:

- User sign-in and registration
- Email verification flow
- Reactive authentication state with `authStateChanges`
- Local Firebase Auth Emulator usage for safer and faster development

---

## Development Recommendations

To make development easier and avoid affecting your real Firebase project, this demo is configured to use the **Firebase Authentication Emulator** when running in debug mode.

### How to use the emulator

1. Make sure you have the Firebase Emulator installed and running:

```bash
firebase emulators:start
