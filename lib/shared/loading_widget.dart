import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.primaryColor,
      child: Center(
        child: SpinKitPulse(
          color: theme.colorScheme.secondary,
          size: 50.0,
        ),
      ),
    );
  }
}
