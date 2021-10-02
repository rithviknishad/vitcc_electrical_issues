import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:provider/provider.dart';
import 'package:vitcc_electrical_issues/models/issue.dart';
import 'package:vitcc_electrical_issues/models/misc.dart';

import 'package:vitcc_electrical_issues/shared/issue_tile.dart';
import 'package:vitcc_electrical_issues/shared/loading_widget.dart';

class ActiveIssuesSection extends StatelessWidget {
  const ActiveIssuesSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<IssueSnapshot>?>.value(
      value: Issue.activeIssues,
      initialData: null,
      builder: (context, _) {
        final activeIssues = Provider.of<List<IssueSnapshot>?>(context);

        if (activeIssues == null) {
          return Loading.alt();
        }

        syncMiscWithActiveIssuesLengthIfDrift(context, activeIssues);

        if (activeIssues.isEmpty) {
          return buildAllIssuesResolvedStatus(context);
        }

        return buildIssuesView(context, activeIssues);
      },
    );
  }

  /// Syncs misc's active issues count with active issues length to compensate
  /// drift errors.
  void syncMiscWithActiveIssuesLengthIfDrift(
    BuildContext context,
    List<IssueSnapshot> activeIssues,
  ) {
    // Voluntarily not setting listen to false.
    final misc = Provider.of<MiscSnapshot>(context).misc;

    if (misc.activeIssuesCount != activeIssues.length) {
      Misc.updateActiveIssuesCount(activeIssues.length);
    }
  }

  Widget buildIssuesView(BuildContext context, List<IssueSnapshot> issues) {
    final theme = Theme.of(context);

    return Column(
      children: [
        SizedBox(height: 8),
        Text(
          'Issues currently active',
          style: TextStyle(color: theme.disabledColor),
        ),
        SizedBox(height: 8),
        // List all active issues
        for (final issue in issues)
          Provider<IssueSnapshot>.value(
            value: issue,
            child: IssueTile(),
          ),
      ],
    );
  }

  Widget buildAllIssuesResolvedStatus(BuildContext context) {
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
            'Hooray! No issues left to be resolved.',
            style: TextStyle(
              color: theme.disabledColor,
            ),
          ),
        ],
      ),
    );
  }
}
