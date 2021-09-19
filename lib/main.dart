import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:vitcc_electrical_issues/models/user.dart';
import 'package:vitcc_electrical_issues/routes/authenticate.dart';
import 'package:vitcc_electrical_issues/routes/dashboard.dart';
import 'package:vitcc_electrical_issues/services/auth.dart';
import 'package:vitcc_electrical_issues/shared/loading_widget.dart';

void main() => runApp(ElectricalIssueTrackerApp());

class ElectricalIssueTrackerApp extends StatelessWidget {
  const ElectricalIssueTrackerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VITCC Electrical Issue Tracker',
      theme: _theme,
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
            },
          );
        },
      ),
    );
  }

  static const _primary = Color.fromARGB(255, 0, 38, 70);
  static const _accent = Color.fromARGB(255, 245, 248, 253);
  static const _secondary = Color(0xFFFFCA28);

  static final _theme = ThemeData(
    fontFamily: 'Ubuntu',
    brightness: Brightness.light,
    primaryColor: _primary,
    accentColor: _accent,
    appBarTheme: AppBarTheme(
      brightness: Brightness.light,
      color: Colors.white,
      elevation: 0,
      actionsIconTheme: const IconThemeData(color: _primary),
    ),
    iconTheme: const IconThemeData(color: _primary),

    scaffoldBackgroundColor: _accent,
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: _primary,
      actionTextColor: _secondary,
      disabledActionTextColor: Colors.grey,
      contentTextStyle: TextStyle(color: Colors.white),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(_primary),
        textStyle: MaterialStateProperty.all(TextStyle(
          fontFamily: 'Ubuntu',
          color: _accent,
          fontWeight: FontWeight.w500,
        )),
      ),
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _primary,
      selectedItemColor: _secondary,
      unselectedItemColor: Colors.blueGrey,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _accent,
      enabledBorder: UnderlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: _primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.red),
      ),
      labelStyle: const TextStyle(color: _primary, fontSize: 14),
      focusColor: _primary,
    ),
  );
}
