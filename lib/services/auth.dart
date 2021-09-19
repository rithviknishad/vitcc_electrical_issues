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
  static Future<UserCredential?> signInWithGoogle() async {
    // Maybe the user is already signed in. Who knows?
    var currentUser = googleSignIn.currentUser;

    // Sneaky Peeky, try to get inside seamlessly.
    currentUser ??= await googleSignIn.signInSilently();

    // Oho! Maybe we should ask the user again.
    currentUser ??= await googleSignIn.signIn();

    // Let's go back home :(
    if (currentUser == null) {
      return null;
    }

    // Retrieve the google sign in authentication of the user.
    final googleAuth = await currentUser.authentication;

    // Constructs a credential
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );

    // Once signed in, return the UserCredential
    return await firebaseAuth.signInWithCredential(credential);
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
    await firebaseAuth.signOut();

    if (await googleSignIn.isSignedIn()) {
      await googleSignIn.signOut();
    }
  }

  // Avoid attempting to instantiate objects of this class.
  AuthService._();
}
