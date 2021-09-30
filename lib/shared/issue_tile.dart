import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';
import 'package:vitcc_electrical_issues/models/issue.dart';
import 'package:vitcc_electrical_issues/shared/marquee_widget.dart';

class IssueTile extends StatelessWidget {
  const IssueTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final issue = Provider.of<IssueSnapshot?>(context)?.issue;

    if (issue == null) {
      return buildShimmer(context);
    }

    final theme = Theme.of(context);

    return InkWell(
      onTap: () {}, // TODO: handle opening
      highlightColor: theme.primaryColorLight,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: issue.isActiveIssue ? theme.cardColor : theme.hoverColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: MarqueeWidget(
                    child: Text(
                      issue.title,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.all(1),
                  child: Text(
                    issue.location.block,
                    style: TextStyle(
                      color: theme.disabledColor,
                      fontSize: 12,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    FontAwesome5.map_marker_alt,
                    size: 12,
                    color: theme.disabledColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    issue.isActiveIssue
                        ? 'Raised on ${Jiffy(issue.raisedOn.toDate()).format('MMMM do')}'
                        : 'Resolved on ${Jiffy(issue.resolvedOn!.toDate()).format('MMMM do')}',
                    style: TextStyle(
                      color: theme.disabledColor,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (issue.isImportant) buildFlag(context, 'IMPORTANT'),
                if (issue.isUrgent) buildFlag(context, 'URGENT'),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget buildFlag(BuildContext context, String flagDescription) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            flagDescription,
            style: TextStyle(
              fontSize: 12,
              color: theme.primaryColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildShimmer(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: SpinKitPulse(
                  color: theme.primaryColor,
                  size: 50.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
