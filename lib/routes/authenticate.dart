import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:vitcc_electrical_issues/services/auth_service.dart';
import 'package:vitcc_electrical_issues/shared/loading_widget.dart';
import 'package:vitcc_electrical_issues/shared/text_field_widget.dart';
import 'package:vitcc_electrical_issues/shared/wave_widget.dart';

class AuthenticatePage extends StatefulWidget {
  @override
  _AuthenticatePageState createState() => _AuthenticatePageState();
}

class _AuthenticatePageState extends State<AuthenticatePage>
    with WidgetsBindingObserver {
  static final vitMailRegEx = RegExp(r"@(vitstudent.ac.in|vit.ac.in)$");

  /// To validate the form that may contain vit email for sign in with link.
  final formKey = GlobalKey<FormState>();

  /// For sign in with link using VIT mail.
  final vitMailController = TextEditingController();

  /// Whether the specified vit mail is valid.
  bool vitMailIsValid = false;

  /// Whether a process related to authentication / auth_service is running.
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    vitMailController.dispose();
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

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
                            : theme.colorScheme.secondary,
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
                  Form(
                    key: formKey,
                    child: TextFieldWidget(
                      controller: vitMailController,
                      hintText: 'VIT Email',
                      obscureText: false,
                      prefixIconData: FontAwesome5.id_badge,
                      suffixIconData: vitMailIsValid ? Icons.check : null,
                      onChanged: (_) {
                        final result =
                            formKey.currentState?.validate() ?? false;

                        if (vitMailIsValid != result) {
                          setState(() => vitMailIsValid = result);
                        }
                      },
                      validator: MultiValidator([
                        EmailValidator(errorText: 'Invliad email address'),
                        PatternValidator(
                          vitMailRegEx,
                          errorText:
                              "Email address should belong to 'vit.ac.in' or 'vitstudent.ac.in' domain",
                        )
                      ]),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  _Button(
                    text: 'Sign in with Google',
                    hasBorder: false,
                    onTap: () async {
                      setState(() => isLoading = true);

                      await AuthService.signInWithGoogle();

                      setState(() => isLoading = false);
                    },
                  )
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
  final Function() onTap;

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
          color: hasBorder ? theme.accentColor : theme.primaryColor,
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
                  color: hasBorder ? theme.primaryColor : theme.accentColor,
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
