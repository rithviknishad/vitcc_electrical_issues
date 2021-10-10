import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vitcc_electrical_issues/shared/platform_utils.dart';

class AuthService {
  static final firebaseAuth = FirebaseAuth.instance;

  static final Map<String, GoogleSignIn> providers = {
    if (kIsWebDesktop)
      'VIT ID': GoogleSignIn(
        hostedDomain: 'vit.ac.in',
      ),
    if (kIsWebDesktop)
      'VIT Student ID': GoogleSignIn(
        hostedDomain: 'vitstudent.ac.in',
      ),
  };

  static Stream<User?> get user => firebaseAuth.userChanges();

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

  static Future<FirebaseAuthException?> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (exception) {
      return exception;
    }
  }

  static Future<FirebaseAuthException?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (exception) {
      return exception;
    }
  }
}
