import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

    return Container();
  }
}
