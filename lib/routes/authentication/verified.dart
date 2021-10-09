import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class Verified extends StatelessWidget {
  const Verified({
    required this.child,
    Key? key,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final firebaseUser = Provider.of<User>(context);

    if (firebaseUser.emailVerified) {
      return child;
    }

    return _RequiresVerificationPage(firebaseUser);
  }
}

class _RequiresVerificationPage extends StatelessWidget {
  final User user;

  const _RequiresVerificationPage(this.user, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FadeIn(
                preferences: AnimationPreferences(
                  duration: const Duration(milliseconds: 500),
                  offset: const Duration(milliseconds: 300),
                ),
                child: Icon(
                  FontAwesomeIcons.solidPaperPlane,
                  color: theme.colorScheme.onPrimary,
                  size: 32,
                ),
              ),
              SizedBox(height: 30),
              FadeIn(
                preferences: AnimationPreferences(
                  duration: const Duration(milliseconds: 500),
                ),
                child: Text(
                  'A verification mail has been sent to',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontSize: 18,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              SizedBox(height: 16),
              FadeIn(
                preferences: AnimationPreferences(
                  duration: const Duration(milliseconds: 500),
                  offset: const Duration(milliseconds: 300),
                ),
                child: Text(
                  user.email ?? 'your inbox',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary.withOpacity(0.8),
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              SizedBox(height: 48),
              TimeGatedButton(
                onPressed: user.sendEmailVerification,
                onTimerInitialized: user.sendEmailVerification,
                label: 'RESEND MAIL',
                everySecond: user.reload,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class TimeGatedButton extends StatefulWidget {
  final Duration delay;
  final VoidCallback onPressed;
  final VoidCallback? everySecond;
  final String label;
  final VoidCallback? onTimerInitialized;

  const TimeGatedButton({
    Key? key,
    this.delay = const Duration(seconds: 30),
    this.everySecond,
    required this.onPressed,
    required this.label,
    this.onTimerInitialized,
  }) : super(key: key);

  @override
  _TimeGatedButtonState createState() => _TimeGatedButtonState();
}

class _TimeGatedButtonState extends State<TimeGatedButton> {
  static const refreshInterval = Duration(seconds: 1);

  late Duration _pendingDuration;

  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();

    _pendingDuration = widget.delay;
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void initializeTimer() {
    _refreshTimer ??= Timer.periodic(refreshInterval, (timer) {
      if (!buttonIsEnabled) {
        _pendingDuration -= refreshInterval;
      }

      widget.everySecond?.call();

      setState(() {});
    });

    widget.onTimerInitialized?.call();
  }

  bool get buttonIsEnabled => _pendingDuration.isNegative;

  @override
  Widget build(BuildContext context) {
    if (_refreshTimer == null) {
      initializeTimer();
    }

    final theme = Theme.of(context);

    final buttonLabel = buttonIsEnabled
        ? widget.label
        : '${widget.label} (${_pendingDuration.inSeconds}s)';

    final backgroundColor = buttonIsEnabled
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.primary;

    final foregroundColor = buttonIsEnabled
        ? theme.colorScheme.primary
        : theme.colorScheme.onPrimary.withOpacity(0.6);

    return FadeIn(
      key: Key('$buttonIsEnabled'),
      preferences: AnimationPreferences(
        duration: const Duration(milliseconds: 500),
        offset: buttonIsEnabled
            ? const Duration(milliseconds: 300)
            : const Duration(milliseconds: 2000),
      ),
      child: TextButton(
        onPressed: onButtonPressed,
        style: TextButton.styleFrom(
          backgroundColor: backgroundColor,
          primary: foregroundColor,
        ),
        child: Text(
          buttonLabel,
          style: TextStyle(
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  void onButtonPressed() {
    if (!buttonIsEnabled) {
      return;
    }

    setState(() => _pendingDuration = widget.delay);

    widget.onPressed();
  }
}
