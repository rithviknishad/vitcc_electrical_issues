import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  final bool alternate;

  const Loading([this.alternate = false]);

  factory Loading.alt() => Loading(true);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bgColor =
        alternate ? theme.colorScheme.secondary : theme.primaryColor;

    final fgColor =
        alternate ? theme.primaryColor : theme.colorScheme.secondary;

    return Material(
      color: bgColor,
      child: Center(
        child: SpinKitPulse(
          color: fgColor,
          size: 50.0,
        ),
      ),
    );
  }
}
