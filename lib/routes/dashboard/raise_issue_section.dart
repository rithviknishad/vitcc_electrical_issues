import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:vitcc_electrical_issues/routes/dashboard/dashboard.dart';

class RaiseAnIssueSection extends StatelessWidget {
  const RaiseAnIssueSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        // color: theme.colorScheme.surface,
      ),
      child: Column(
        children: [
          Text(
            'Having an electrical issue in campus?',
            style: TextStyle(
              color: theme.primaryColor,
            ),
          ),
          SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton.extended(
                onPressed: () =>
                    DashboardPage.of(context).showRaiseNewIssueForm(context),
                tooltip: 'Click to raise a new issue.',
                label: Text('Raise a new issue'),
                icon: Icon(FontAwesome5.feather),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
