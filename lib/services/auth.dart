import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vitcc_electrical_issues/models/user.dart';

class AuthService {
  static Stream<UserSnapshot?> get user =>
      FirebaseAuth.instance.authStateChanges().asyncMap((user) {
        if (user != null) {
          return PlatformUser.get(user);
        }
      });

  static User? get currentUser => FirebaseAuth.instance.currentUser;

  /// Sign in w/ Google Account.
  static Future<UserCredential?> signInWithGoogle() async {
    // Trigger the authentication flow
    final googleUser = await GoogleSignIn().signIn();

    // Return if login was unsuccessful.
    if (googleUser == null) {
      return null;
    }

    // Obtain the auth details from the request
    final googleAuth = await googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  // TODO: handle deep links later
  // NOTE: Temprorily disabled at firebase console.
  static Future<void> signInWithVitEmail(String email) async {
    await FirebaseAuth.instance.sendSignInLinkToEmail(
      email: email,
      actionCodeSettings: ActionCodeSettings(
        url: _authDomain,
        handleCodeInApp: true,
      ),
    );
  }

  /// Authorized domain of this app.
  static const _authDomain = 'https://vitcc-electrical-issues.firebaseapp.com';

  /// Signs out the current user and notifies [user] stream.
  static Future<void> signOut() => FirebaseAuth.instance.signOut();

  // Avoid attempting to instantiate objects of this class.
  AuthService._();
}
