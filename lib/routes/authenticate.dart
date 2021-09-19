import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:provider/provider.dart';
import 'package:vitcc_electrical_issues/shared/loading_widget.dart';
import 'package:vitcc_electrical_issues/shared/text_field_widget.dart';
import 'package:vitcc_electrical_issues/shared/wave_widget.dart';

class Authenticate extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (context) => AuthenticateViewModel(),
        child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
              systemNavigationBarColor: Colors.white30,
              systemNavigationBarIconBrightness: Brightness.dark,
            ),
            child: AuthenticateView()),
      );
}

class AuthenticateView extends StatefulWidget {
  @override
  _AuthenticateViewState createState() => _AuthenticateViewState();
}

class _AuthenticateViewState extends State<AuthenticateView> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  final emailController = TextEditingController();
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Loading();
    }

    final theme = Theme.of(context);
    final viewModel = Provider.of<AuthenticateViewModel>(context);
    final size = MediaQuery.of(context).size;
    final keyboardIsOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
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
                          : theme.accentColor,
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
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Email Address Field
                  TextFieldWidget(
                    controller: emailController,
                    hintText: 'VIT Email',
                    obscureText: false,
                    prefixIconData: FontAwesome5.id_badge,
                    suffixIconData: viewModel.emailIsValid ? Icons.check : null,
                    onChanged: (value) => viewModel.isValidEmail(value),
                    validator: MultiValidator([
                      EmailValidator(errorText: 'Invalid email address'),
                      PatternValidator(AuthenticateViewModel.vitEmailPattern,
                          errorText: 'Email shall belong to VIT domain')
                    ]),
                    keyboardType: TextInputType.emailAddress,
                    // autofillHints: [AutofillHints.email],
                  ),

                  // Error Message
                  if (errorMessage != null) ...[
                    SizedBox(height: 12.0),
                    Text(
                      errorMessage!,
                      style: TextStyle(color: Colors.red, fontSize: 14.0),
                    ),
                  ],

                  SizedBox(height: 20),

                  // Authenticate Button
                  _Button(
                    text: 'Authenticate',
                    hasBorder: false,
                    onTap: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        setState(() => isLoading = true);

                        // dynamic result = await AuthService.signInWithEmailAndPassword(
                        //   emailController.text,
                        //   passwordController.text,
                        // );

                        // if (result == null) {
                        //   setState(() {
                        //     isLoading = false;
                        //     errorMessage = 'Invalid Credentials';
                        //   });
                        // }
                      }
                    },
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}

class AuthenticateViewModel extends ChangeNotifier {
  bool _passwordIsVisible = false;

  bool get passwordIsVisible => _passwordIsVisible;

  set passwordIsVisible(bool value) {
    if (passwordIsVisible != value) {
      _passwordIsVisible = value;
      notifyListeners();
    }
  }

  static final emailPattern =
      r"^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$";

  static final vitEmailPattern = r"@(vitstudent.ac.in|vit.ac.in)$";

  bool _emailIsValid = false;

  bool get emailIsValid => _emailIsValid;

  void isValidEmail(String input) async {
    bool isValid = true;

    isValid &= RegExp(emailPattern).hasMatch(input);
    isValid &= RegExp(vitEmailPattern).hasMatch(input);

    if (emailIsValid != isValid) {
      _emailIsValid = isValid;
      notifyListeners();
    }
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
