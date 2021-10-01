import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';
import 'package:vitcc_electrical_issues/models/issue.dart';
import 'package:vitcc_electrical_issues/models/user.dart';
import 'package:vitcc_electrical_issues/shared/field_value.dart';
import 'package:vitcc_electrical_issues/shared/marquee_widget.dart';

class IssueTile extends StatefulWidget {
  const IssueTile({Key? key}) : super(key: key);

  @override
  State<IssueTile> createState() => _IssueTileState();
}

class _IssueTileState extends State<IssueTile> {
  bool _isExpanded = true; // TODO revert it to false later after testing.

  void toggleTileSelectionState() {
    setState(() => _isExpanded = !_isExpanded);
  }

  static const _shrinkedPadding = const EdgeInsets.all(12);
  static const _expandedPadding = const EdgeInsets.fromLTRB(12, 20, 12, 20);
  static final _shrinkedBorderRadius = BorderRadius.circular(10);
  static final _expandedBorderRadius = BorderRadius.circular(14);

  @override
  Widget build(BuildContext context) {
    final issueSnapshot = Provider.of<IssueSnapshot?>(context);

    if (issueSnapshot == null) {
      return buildShimmer(context);
    }

    final theme = Theme.of(context);

    return InkWell(
      onTap: toggleTileSelectionState,
      highlightColor: theme.primaryColorLight,
      child: AnimatedContainer(
        curve: Curves.fastLinearToSlowEaseIn,
        duration: const Duration(milliseconds: 500),
        padding: _isExpanded ? _expandedPadding : _shrinkedPadding,
        margin: const EdgeInsets.fromLTRB(8, 6, 8, 6),
        decoration: BoxDecoration(
          color: issueSnapshot.isActive ? theme.cardColor : theme.hoverColor,
          borderRadius:
              _isExpanded ? _expandedBorderRadius : _shrinkedBorderRadius,
        ),
        child: _isExpanded
            ? buildExpandedTile(context, issueSnapshot)
            : buildShrinkedTile(context, issueSnapshot.issue),
      ),
    );
  }

  Widget buildShrinkedTile(BuildContext context, Issue issue) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildIssueTitleWidget(theme, issue),

            // Location Short
            FadeInRight(
              preferences: AnimationPreferences(
                duration: const Duration(milliseconds: 300),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(9, 1, 1, 1),
                child: Text(
                  issue.location.block,
                  style: TextStyle(
                    color: theme.disabledColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            FadeInRight(
              preferences: AnimationPreferences(
                duration: const Duration(milliseconds: 300),
                offset: const Duration(milliseconds: 150),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  FontAwesome5.map_marker_alt,
                  size: 12,
                  color: theme.disabledColor,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        buildIssueStatusAndPrioritySection(issue, theme),
      ],
    );
  }

  Widget buildExpandedTile(BuildContext context, IssueSnapshot issueSnapshot) {
    final theme = Theme.of(context);
    final user = Provider.of<UserSnapshot>(context).user;
    final issue = issueSnapshot.issue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Do not remove parent Row although single child.
            // Child's marquee widget's constraints are set using child's expanded widget which requires this row as parent.
            buildIssueTitleWidget(theme, issue),
          ],
        ),
        SizedBox(height: 8),
        buildIssueStatusAndPrioritySection(issue, theme),
        SizedBox(height: 8),
        FadeIn(
          preferences: AnimationPreferences(
            duration: const Duration(milliseconds: 300),
            offset: const Duration(milliseconds: 70),
          ),
          child: Wrap(
            direction: Axis.vertical,
            spacing: 4,
            runSpacing: 4,
            children: [
              FieldValueWidget(
                icon: FontAwesome5.user,
                value: issue.raisedBy.id,
                field: 'Raised by',
              ),
              // Row(
              //   children: [
              //     Icon(FontAwesome5.user),
              //     Text('Raised by: '),
              //     Text(issue.raisedBy.id),
              //   ],
              // )
            ],
          ),
        )
      ],
    );
  }

  Widget buildIssueTitleWidget(ThemeData theme, Issue issue) {
    return Expanded(
      key: Key('title${issue.title}'),
      child: MarqueeWidget(
        child: Text(
          issue.title,
          style: TextStyle(
            fontSize: 14,
            color: theme.primaryColor,
          ),
        ),
      ),
    );
  }

  Widget buildIssueStatusAndPrioritySection(Issue issue, ThemeData theme) {
    return Row(
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
        if (issue.isImportant) buildFlag(theme, 'IMPORTANT'),
        if (issue.isUrgent) buildFlag(theme, 'URGENT'),
      ],
    );
  }

  Widget buildFlag(ThemeData theme, String flagDescription) {
    return Padding(
      key: Key('flag:$flagDescription'),
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
