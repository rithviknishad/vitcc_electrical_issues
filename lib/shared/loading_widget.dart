import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  final bool alternate;

  const Loading([this.alternate = false]);

  factory Loading.alt() => Loading(true);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: alternate ? theme.colorScheme.onPrimary : theme.primaryColor,
      child: Center(
        child: SpinKitPulse(
          color: alternate ? theme.primaryColor : theme.colorScheme.onPrimary,
          size: 50.0,
        ),
      ),
    );
  }
}
