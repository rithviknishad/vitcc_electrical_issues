import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:vitcc_electrical_issues/routes/authentication/authenticate.dart';
import 'package:vitcc_electrical_issues/routes/authentication/verified.dart';
import 'package:vitcc_electrical_issues/routes/dashboard/dashboard.dart';
import 'package:vitcc_electrical_issues/shared/loading_widget.dart';

void main() => runApp(ElectricalIssueTrackerApp());

class ElectricalIssueTrackerApp extends StatelessWidget {
  static const appName = 'Electrical Issue Tracker';
  static const appIcon = AssetImage('assets/icons/192.png');
  static const appLegalese = 'GNU General Public License v3.0';
  // Move to Misc
  static const appIssueTracker =
      'https://github.com/rithviknishad/vitcc_electrical_issues/issues';
  // Move to Misc
  static const appIssueTrackerMailing = 'rithvik.nishad2019@vitstudent.ac.in';

  static const appRepository =
      'https://github.com/rithviknishad/vitcc_electrical_issues/';

  const ElectricalIssueTrackerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appName,
      theme: _theme,
      home: FutureBuilder<FirebaseApp>(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          // Loading screen, when initializing firebase app.
          if (!snapshot.hasData) {
            return Loading();
          }

          return Authenticated(
            child: Verified(
              child: DashboardPage(),
            ),
          );
        },
      ),
    );
  }

  static const _primary = Color.fromARGB(255, 0, 38, 70);
  static const _accent = Color.fromARGB(255, 245, 248, 253);
  static const _secondary = Color(0xFF924642);
  static const _vistaWhite = Color(0xFFFEF9F7);

  static const _fontFamily = 'Ubuntu';

  static get _theme {
    return ThemeData(
      visualDensity: VisualDensity.standard,
      fontFamily: _fontFamily,
      brightness: Brightness.light,
      primaryColor: _primary,
      colorScheme: ColorScheme.light(
        primary: _primary,
        onPrimary: _accent,
        secondary: _secondary,
        onSecondary: _vistaWhite,
        surface: _accent,
        onSurface: _primary,
        background: _accent,
        onBackground: _primary,
      ),
      disabledColor: Color(0x99002646),
      scaffoldBackgroundColor: _accent,
      cardColor: Colors.white,
      appBarTheme: AppBarTheme(
        color: _accent,
        iconTheme: IconThemeData(
          color: _primary,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: _accent,
          statusBarIconBrightness: Brightness.dark,
        ),
        elevation: 0,
        actionsIconTheme: const IconThemeData(
          color: _primary,
        ),
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          color: _primary,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            topLeft: Radius.circular(20),
          ),
        ),
        elevation: 8,
      ),
      iconTheme: const IconThemeData(
        color: _primary,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _primary,
        foregroundColor: _accent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: _primary,
          primary: _accent,
          onSurface: _accent,
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: _accent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: _primary,
        contentTextStyle: TextStyle(
          fontFamily: _fontFamily,
          color: _accent,
          letterSpacing: 0.5,
        ),
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
}
