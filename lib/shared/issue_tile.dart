import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';
import 'package:vitcc_electrical_issues/models/issue.dart';
import 'package:vitcc_electrical_issues/models/issue_location.dart';
import 'package:vitcc_electrical_issues/models/user.dart';
import 'package:vitcc_electrical_issues/shared/field_value.dart';
import 'package:vitcc_electrical_issues/shared/loading_widget.dart';
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
        // Issue title
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

        // Status and priority
        buildIssueStatusAndPrioritySection(issue, theme),

        // Issue Description
        if (issue.description.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              issue.description,
              style: TextStyle(
                color: theme.primaryColor,
              ),
            ),
          )
        else
          SizedBox(height: 8),

        // Other attributes
        FadeIn(
          preferences: AnimationPreferences(
            duration: const Duration(milliseconds: 300),
            offset: const Duration(milliseconds: 70),
          ),
          child: FutureBuilder<UserSnapshot?>(
              future: PlatformUser.getUserFromId(issue.raisedBy.id),
              builder: (context, snapshot) {
                final author = snapshot.data;

                return Wrap(
                  direction: Axis.vertical,
                  children: [
                    // Location
                    ...buildIssueLocationAttributes(issue.location),

                    // Issue raised on (time)
                    FieldValueWidget(
                      icon: FontAwesome5.clock,
                      value: Jiffy(issue.raisedOn.toDate()).fromNow(),
                    ),

                    // Author attributes
                    if (author is UserSnapshot)
                      ...buildIssueAuthorAttributes(author.user)
                    else
                      Loading.alt()
                  ],
                );
              }),
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
                ? 'Raised ${Jiffy(issue.raisedOn.toDate()).fromNow()}'
                : 'Resolved ${Jiffy(issue.resolvedOn!.toDate()).fromNow()}',
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

  List<Widget> buildIssueLocationAttributes(IssueLocation location) {
    String formattedFloor = '';

    try {
      formattedFloor = Jiffy(location.floor, 'd').format('do floor');
    } catch (exception) {
      formattedFloor = 'Floor: ${location.floor}';
    }

    return [
      FieldValueWidget(
        icon: FontAwesome5.map_marker_alt,
        value: '${location.block}, $formattedFloor',
      ),
      FieldValueWidget(
        value: location.room,
        field: 'Room / Location',
      ),
    ];
  }

  List<Widget> buildIssueAuthorAttributes(PlatformUser author) {
    return [
      FieldValueWidget(
        icon: FontAwesome5.user,
        value: author.name,
        field: 'Raised by',
      ),
      FieldValueWidget(
        value: author.email,
        field: 'Email',
      ),
      FieldValueWidget(
        icon: FontAwesome5.mobile,
        value: author.phoneNumber,
        field: 'Contact No.',
      ),
    ];
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
