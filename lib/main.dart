import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vitcc_electrical_issues/models/misc.dart';
import 'package:vitcc_electrical_issues/models/user.dart';
import 'package:vitcc_electrical_issues/routes/authenticate.dart';
import 'package:vitcc_electrical_issues/routes/dashboard/dashboard.dart';
import 'package:vitcc_electrical_issues/services/auth_service.dart';
import 'package:vitcc_electrical_issues/shared/loading_widget.dart';

void main() => runApp(ElectricalIssueTrackerApp());

class ElectricalIssueTrackerApp extends StatelessWidget {
  static const title = 'Electrical Issue Tracker';

  const ElectricalIssueTrackerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: title,
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
                return MultiProvider(
                  providers: [
                    StreamProvider<MiscSnapshot?>.value(
                      value: Misc.watch,
                      initialData: null,
                    ),
                  ],
                  child: DashboardPage(),
                );
              }

              // Show authentication page if not signed in.
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
  static const _fontFamily = 'Ubuntu';

  static get _theme => ThemeData(
        fontFamily: _fontFamily,
        brightness: Brightness.light,

        primaryColor: _primary,

        colorScheme: ColorScheme.light(
          primary: _primary,
          onPrimary: _accent,
          secondary: _secondary,
          surface: _accent,
          onSurface: _primary,
        ),

        scaffoldBackgroundColor: _accent,

        appBarTheme: AppBarTheme(
          color: Colors.white,
          iconTheme: IconThemeData(
            color: _primary,
          ),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.white,
            statusBarIconBrightness: Brightness.dark,
          ),
          elevation: 0,
          actionsIconTheme: const IconThemeData(
            color: _primary,
          ),
          titleTextStyle: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 18,
            color: _primary,
          ),
        ),

        iconTheme: const IconThemeData(color: _primary),

        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: _primary,
          foregroundColor: _accent,
        ),

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
