import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:provider/provider.dart';
import 'package:vitcc_electrical_issues/models/misc.dart';
import 'package:vitcc_electrical_issues/models/user.dart';
import 'package:vitcc_electrical_issues/services/auth_service.dart';
import 'package:vitcc_electrical_issues/shared/loading_widget.dart';
import 'package:vitcc_electrical_issues/routes/authentication/wave_widget.dart';
import 'package:vitcc_electrical_issues/shared/platform_utils.dart';
import 'package:vitcc_electrical_issues/shared/text_field_widget.dart';

class Authenticated extends StatelessWidget {
  final Widget child;

  const Authenticated({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
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
                  Provider.value(value: currentUser),
                ],
                child: child,
              );
            },
          );
        }

        return ChangeNotifierProvider(
          create: (_) => AuthenticateViewModel(),
          child: _AuthenticatePage(),
        );
      },
    );
  }
}

class _AuthenticatePage extends StatefulWidget {
  @override
  _AuthenticatePageState createState() => _AuthenticatePageState();
}

class _AuthenticatePageState extends State<_AuthenticatePage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  /// Whether a process related to authentication / auth_service is running.
  bool isLoading = false;

  String? errorMessage;

  @override
  void initState() {
    super.initState();
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AuthenticateViewModel>(context);

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
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Emaild ID
                    buildEmailIDTextField(viewModel),
                    SizedBox(height: 10),

                    // Password
                    buildPasswordTextField(viewModel),
                    SizedBox(height: 10),

                    // Error message
                    if (errorMessage is String)
                      buildErrorMessage(errorMessage!),

                    SizedBox(height: 10),

                    // Sign Up button
                    Row(
                      children: [
                        Expanded(
                          child: _AuthActionButton('Sign up', onSignUpPressed),
                        ),
                        Expanded(
                          child: _AuthActionButton('Sign in', onSignInPressed),
                        ),
                      ],
                    ),

                    if (isWebDesktop) buildSignInWithGoogleProviders(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEmailIDTextField(AuthenticateViewModel viewModel) {
    return ConstrainedBox(
      constraints: BoxConstraints.loose(Size(400, 100)),
      child: TextFieldWidget(
        controller: emailController,
        hintText: ' VIT Mail ID',
        prefixIconData: FontAwesomeIcons.idBadge,
        suffixIconData: viewModel.emailIsValid ? Icons.check : null,
        onChanged: viewModel.isValidEmail,
        validator: MultiValidator([
          EmailValidator(errorText: 'Invalid Email Address'),
          PatternValidator(
            r'@(vitstudent.ac.in|vit.ac.in)$',
            errorText:
                'Should belong to @vit.ac.in or @vitstudent.ac.in domain.',
          )
        ]),
        keyboardType: TextInputType.emailAddress,
      ),
    );
  }

  Widget buildPasswordTextField(AuthenticateViewModel viewModel) {
    return ConstrainedBox(
      constraints: BoxConstraints.loose(Size(400, 100)),
      child: TextFieldWidget(
        controller: passwordController,
        hintText: 'Password',
        obscureText: !viewModel.passwordIsVisible,
        prefixIconData: Icons.lock_outline,
        suffixIconData: viewModel.passwordIsVisible
            ? Icons.visibility
            : Icons.visibility_off,
        onSuffixIconTap: () =>
            viewModel.passwordIsVisible = !viewModel.passwordIsVisible,
        validator: MultiValidator([
          RequiredValidator(errorText: 'Required'),
          MinLengthValidator(4, errorText: 'Must be at least 4 characters'),
        ]),
        autofillHints: [AutofillHints.password],
      ),
    );
  }

  Widget buildErrorMessage(String errorMessage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        errorMessage,
        style: TextStyle(
          color: Colors.red,
          fontSize: 14.0,
        ),
      ),
    );
  }

  Widget buildSignInWithGoogleProviders() {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          for (final provider in AuthService.providers.entries)
            _AuthActionButton(
              'Sign in with ${provider.key}',
              () async {
                setState(() => isLoading = true);

                await AuthService.signInWithGoogle(provider.value);

                if (mounted) {
                  setState(() => isLoading = false);
                }
              },
            ),
        ],
      ),
    );
  }

  Future<void> onSignUpPressed() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => isLoading = true);

      errorMessage = await AuthService.createUserWithEmailAndPassword(
        emailController.text,
        passwordController.text,
      );

      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> onSignInPressed() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => isLoading = true);

      errorMessage = await AuthService.signInWithEmailAndPassword(
        emailController.text,
        passwordController.text,
      );

      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }
}

class _AuthActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final IconData? icon;

  _AuthActionButton(this.text, this.onTap, {this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget content = Text(
      text,
      style: TextStyle(
        color: theme.colorScheme.surface,
        fontWeight: FontWeight.w500,
        fontSize: 16.0,
      ),
    );

    if (icon != null) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: theme.colorScheme.surface,
          ),
          SizedBox(width: 16),
          content,
          SizedBox(width: 44),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ConstrainedBox(
        constraints: BoxConstraints.loose(Size(400, 60)),
        child: Material(
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: theme.primaryColor,
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 50,
                child: Center(
                  child: content,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AuthenticateViewModel extends ChangeNotifier {
  bool _passwordIsVisible = false;

  get passwordIsVisible => _passwordIsVisible;
  set passwordIsVisible(value) {
    _passwordIsVisible = value;
    notifyListeners();
  }

  static const emailPattern =
      r"^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$";

  bool _emailIsValid = false;

  get emailIsValid => _emailIsValid;
  void isValidEmail(String input) async {
    _emailIsValid = RegExp(emailPattern).hasMatch(input);
    notifyListeners();
  }
}
