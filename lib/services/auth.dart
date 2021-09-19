import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vitcc_electrical_issues/models/user.dart';

class AuthService {
  static final firebaseAuth = FirebaseAuth.instance;
  static final googleSignIn = GoogleSignIn();

  static Stream<UserSnapshot?> get user =>
      FirebaseAuth.instance.authStateChanges().asyncMap((user) {
        if (user != null) {
          return PlatformUser.get(user);
        }
      });

  static User? get currentUser => firebaseAuth.currentUser;

  /// Sign in w/ Google Account.
  static Future<void> signInWithGoogle() async {
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

  // TODO: handle deep links later
  // NOTE: Temprorily disabled at firebase console.
  static Future<void> signInWithVitEmail(String email) async {
    await firebaseAuth.sendSignInLinkToEmail(
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
  static Future<void> signOut() async {
    // sign out from firebase
    await firebaseAuth.signOut();

    // sign out from google, if signed in using google sign-in.
    if (await googleSignIn.isSignedIn()) {
      await googleSignIn.signOut();
    }
  }

  // Avoid attempting to instantiate objects of this class.
  AuthService._();
}
