import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vitcc_electrical_issues/models/user.dart';

class AuthService {
  static final firebaseAuth = FirebaseAuth.instance;

  static final providers = {
    'VIT ID': GoogleSignIn(hostedDomain: 'vit.ac.in'),
    'VIT Student ID': GoogleSignIn(hostedDomain: 'vitstudent.ac.in'),

    // Allow sign in with any domain only in debug mode.
    if (kDebugMode) 'Google': GoogleSignIn(),
  };

  static Stream<User?> get user => FirebaseAuth.instance.authStateChanges();

  /// Sign in w/ Google Account.
  static Future<void> signInWithGoogle(GoogleSignIn googleSignIn) async {
    // Try fetching the currently signed-in account.
    var currentUser = googleSignIn.currentUser;

    // Try signing in silently if previously signed in.
    currentUser ??= await googleSignIn.signInSilently();

    // Try interactive sign in.
    currentUser ??= await googleSignIn.signIn();

    // If failed to get google account, stop proceeding.
    if (currentUser == null) return;

    final googleAuth = await currentUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );

    await firebaseAuth.signInWithCredential(credential);
  }

  /// Signs out the current user and notifies [user] stream.
  static Future<void> signOut() async {
    // sign out from firebase
    await firebaseAuth.signOut();

    // sign out from google, if signed in using google sign-in.
    for (final googleSignIn in providers.values) {
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
        return;
      }
    }
  }

  // Avoid attempting to instantiate objects of this class.
  AuthService._();
}
