import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vitcc_electrical_issues/models/misc.dart';
import 'package:vitcc_electrical_issues/models/user.dart';
import 'package:vitcc_electrical_issues/services/auth_service.dart';
import 'package:vitcc_electrical_issues/shared/loading_widget.dart';
import 'package:vitcc_electrical_issues/shared/wave_widget.dart';

class Authenticated extends StatelessWidget {
  final Widget child;

  const Authenticated({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService.user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Loading();
        }

        final currentUser = snapshot.data;

        if (currentUser is User) {
          final userStream = PlatformUser.watch(currentUser);
          return MultiProvider(
            providers: [
              StreamProvider.value(value: Misc.watch, initialData: null),
              StreamProvider.value(value: userStream, initialData: null),
            ],
            builder: (context, _) {
              final userSnapshot = Provider.of<UserSnapshot?>(context);
              final miscSnapshot = Provider.of<MiscSnapshot?>(context);

              if (userSnapshot == null || miscSnapshot == null) {
                return Loading();
              }

              return MultiProvider(
                providers: [
                  Provider.value(value: userSnapshot),
                  Provider.value(value: miscSnapshot),
                ],
                child: child,
              );
            },
          );
        }

        return _AuthenticatePage();
      },
    );
  }
}

class _AuthenticatePage extends StatefulWidget {
  @override
  _AuthenticatePageState createState() => _AuthenticatePageState();
}

class _AuthenticatePageState extends State<_AuthenticatePage> {
  /// Whether a process related to authentication / auth_service is running.
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Loading();
    }

    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final keyboardIsOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white30,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              height: size.height - 200,
              color: theme.primaryColor,
            ),
            AnimatedPositioned(
              duration: Duration(seconds: 1),
              curve: Curves.fastLinearToSlowEaseIn,
              top: keyboardIsOpen ? -size.height / 3.7 : 0.0,
              child: WaveWidget(
                size: size,
                yOffset: size.height / 3.0,
                color: Colors.white,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: size.height * 0.15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: size.width * 0.8,
                    child: Text(
                      'Electrical Issue Tracker',
                      style: TextStyle(
                        color: keyboardIsOpen
                            ? theme.primaryColor
                            : theme.colorScheme.surface,
                        fontSize: 36.0,
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.center,
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  for (final provider in AuthService.providers.entries)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: ConstrainedBox(
                        constraints: BoxConstraints.loose(Size(400, 60)),
                        child: _Button(
                          text: 'Sign in with ${provider.key}',
                          hasBorder: false,
                          onTap: () async {
                            setState(() => isLoading = true);

                            await AuthService.signInWithGoogle(provider.value);

                            if (mounted) {
                              setState(() => isLoading = false);
                            }
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Button extends StatelessWidget {
  final String text;
  final bool hasBorder;
  final VoidCallback onTap;

  _Button({
    required this.text,
    required this.hasBorder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: hasBorder
              ? Border.all(color: theme.primaryColor, width: 1.0)
              : Border.fromBorderSide(BorderSide.none),
          color: hasBorder ? theme.colorScheme.surface : theme.primaryColor,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            height: 60.0,
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  color: hasBorder
                      ? theme.primaryColor
                      : theme.colorScheme.surface,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
