import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vitcc_electrical_issues/models/user.dart';

class WelcomeCard extends StatelessWidget {
  const WelcomeCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = Provider.of<UserSnapshot>(context);

    return Container(
      height: 100,
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.surface,
      ),
      child: Row(
        children: [
          Text(
            '${currentUser.user.user.uid}',
          ),
        ],
      ),
    );
  }
}
