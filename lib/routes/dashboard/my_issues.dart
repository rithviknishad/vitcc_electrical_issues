import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:provider/provider.dart';
import 'package:vitcc_electrical_issues/models/issue.dart';
import 'package:vitcc_electrical_issues/models/user.dart';
import 'package:vitcc_electrical_issues/shared/issue_tile.dart';

class MyIssuesSection extends StatelessWidget {
  const MyIssuesSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserSnapshot>(context).user;

    if (user.hasActiveIssues || user.hasResolvedIssues) {
      return buildMyIssuesView(context, user);
    } else {
      return buildYouHaveNoIssues(context);
    }
  }

  Widget buildMyIssuesView(BuildContext context, PlatformUser user) {
    final theme = Theme.of(context);
    final activeIssues = user.activeIssues;
    final resolvedIssues = user.resolvedIssues;

    return Column(
      children: [
        SizedBox(height: 8),
        Text(
          'Issues raised by you',
          style: TextStyle(color: theme.disabledColor),
        ),
        SizedBox(height: 8),
        // List all active issues
        for (final issue in activeIssues)
          StreamProvider<IssueSnapshot?>.value(
            value: issue,
            initialData: null,
            child: IssueTile(),
          ),

        // List all resolved issues
        for (final issue in resolvedIssues)
          FutureProvider<IssueSnapshot?>.value(
            value: issue,
            initialData: null,
            child: IssueTile(),
          )
      ],
    );
  }

  Widget buildYouHaveNoIssues(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FontAwesome5.smile_wink,
            color: theme.disabledColor,
          ),
          SizedBox(width: 14),
          Text(
            'You have not raised any issues so far',
            style: TextStyle(
              color: theme.disabledColor,
            ),
          ),
        ],
      ),
    );
  }
}
