import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:vitcc_electrical_issues/models/user.dart';
import 'package:vitcc_electrical_issues/routes/authenticate.dart';
import 'package:vitcc_electrical_issues/routes/dashboard.dart';
import 'package:vitcc_electrical_issues/services/auth.dart';
import 'package:vitcc_electrical_issues/shared/loading_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VITCC Electrical Issue Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder<FirebaseApp>(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          // Loading screen, when initializing firebase app.
          if (!snapshot.hasData) {
            return Loading();
          }

          // Loading screen, when attempting to authenticate w/ firebase.
          return StreamBuilder<UserSnapshot?>(
              stream: AuthService.user,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Loading();
                }

                // Authenitcated
                if (snapshot.data is UserSnapshot) {
                  return DashboardPage();
                }

                return Authenticate();
              });
        },
      ),
    ),
  );
}

class AppHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SignInButton(
              Buttons.Google,
              onPressed: () => AuthService.signInWithGoogle(),
            ),
          ],
        ),
      ),
    );
  }
}
