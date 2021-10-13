import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';
import 'package:vitcc_electrical_issues/models/issue.dart';
import 'package:vitcc_electrical_issues/models/issue_location.dart';
import 'package:vitcc_electrical_issues/models/user.dart';
import 'package:vitcc_electrical_issues/shared/dialog_result.dart';
import 'package:vitcc_electrical_issues/shared/field_value.dart';
import 'package:vitcc_electrical_issues/shared/field_value_edit_dialog.dart';
import 'package:vitcc_electrical_issues/shared/loading_widget.dart';
import 'package:vitcc_electrical_issues/shared/marquee_widget.dart';
import 'package:vitcc_electrical_issues/shared/text_field_widget.dart';

class IssueTile extends StatefulWidget {
  final int offset;

  const IssueTile({
    this.offset = 0,
    Key? key,
  }) : super(key: key);

  @override
  State<IssueTile> createState() => _IssueTileState();
}

class _IssueTileState extends State<IssueTile> {
  bool _isExpanded = false;

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
      key: Key(issueSnapshot.id),
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
                  FontAwesomeIcons.mapMarkerAlt,
                  size: 12,
                  color: theme.disabledColor,
                ),
              ),
            ),
          ],
        ),
        Padding(
          key: Key('issue-status-priority-of-shrinked'),
          padding: const EdgeInsets.only(top: 8),
          child: buildIssueStatusAndPrioritySection(issue, theme),
        ),
      ],
    );
  }

  Widget buildExpandedTile(BuildContext context, IssueSnapshot issueSnapshot) {
    final theme = Theme.of(context);
    final currentUser = Provider.of<UserSnapshot>(context);
    final issue = issueSnapshot.issue;
    final isResolvedIssue = issue.isResolvedIssue;

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

        // Status and priority
        Padding(
          key: Key('issue-status-priority-of-expanded'),
          padding: const EdgeInsets.only(top: 8),
          child: buildIssueStatusAndPrioritySection(issue, theme),
        ),

        // Issue Description
        if (issue.description.trim().isNotEmpty)
          FadeIn(
            preferences: AnimationPreferences(
              duration: const Duration(milliseconds: 400),
              offset: const Duration(milliseconds: 150),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                issue.description,
                style: TextStyle(
                  color: theme.primaryColor,
                ),
              ),
            ),
          )
        else
          SizedBox(height: 8),
        // TODO: consider changing it to 'No description provided' in disabled style.

        // Other attributes
        FadeIn(
          preferences: AnimationPreferences(
            duration: const Duration(milliseconds: 300),
            offset: const Duration(milliseconds: 70),
          ),
          child: FutureBuilder<_AuthorAndResolverPair>(
              future: getAuthorAndResolver(issue),
              builder: (context, snapshot) {
                final author = snapshot.data?.a;
                final resolver = snapshot.data?.b;

                return Wrap(
                  direction: Axis.vertical,
                  children: [
                    // Location
                    ...buildIssueLocationAttributes(issue.location),

                    // TODO: consider making it to a three stage live event style
                    // Issue raised on (time)
                    FieldValueWidget(
                      icon: FontAwesomeIcons.clock,
                      value: Jiffy(issue.raisedOn.toDate())
                          .format('EEEE, MMM do, hh:mm a'),
                      field: 'Raised on',
                    ),

                    // Issue resolve time
                    if (isResolvedIssue && issue.resolvedOn != null)
                      FieldValueWidget(
                        icon: FontAwesomeIcons.clock,
                        value: Jiffy(issue.resolvedOn!.toDate())
                            .format('EEEE, MMM do, hh:mm a'),
                        field: 'Resolved on',
                      ),

                    // Author attributes
                    if (author is UserSnapshot)
                      ...buildUserAttributes(author.user)
                    else
                      Loading.alt(),

                    // Resolver attributes
                    if (isResolvedIssue && resolver is UserSnapshot)
                      ...buildUserAttributes(
                        resolver.user,
                        isResolverAndNotAuthor: true,
                      ),
                  ],
                );
              }),
        ),

        // Issue Resolve remarks
        if (isResolvedIssue && (issue.remarks?.isNotEmpty ?? false))
          buildRemarksWidget(issue.remarks!, theme),

        // Issue ID
        buildIssueId(issueSnapshot, theme),

        if (!isResolvedIssue && currentUser.user.scope.canResolveIssue)
          buildResolveThisIssueButton(currentUser, issueSnapshot, theme),
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
            fontWeight:
                issue.isActiveIssue ? FontWeight.bold : FontWeight.normal,
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
        if (issue.isImportant)
          buildFlag(
            theme,
            'IMPORTANT',
            issue.isActiveIssue,
          ),
        if (issue.isUrgent)
          buildFlag(
            theme,
            'URGENT',
            issue.isActiveIssue,
          ),
      ],
    );
  }

  Widget buildFlag(ThemeData theme, String flagDescription, bool animate) {
    return Tada(
      key: Key('flag:$flagDescription'),
      preferences: AnimationPreferences(
        duration: const Duration(milliseconds: 700),
        offset: Duration(milliseconds: 3000 + widget.offset * 500),
        autoPlay: animate ? AnimationPlayStates.Loop : AnimationPlayStates.None,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.onPrimary,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(8),
        child: Text(
          flagDescription,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.primary,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  List<Widget> buildIssueLocationAttributes(IssueLocation location) {
    var formattedFloor = '';

    try {
      formattedFloor = Jiffy(location.floor, 'd').format('do floor');
    } catch (exception) {
      formattedFloor = 'Floor: ${location.floor}';
    }

    return [
      FieldValueWidget(
        icon: FontAwesomeIcons.mapMarkerAlt,
        value: '${location.block}, $formattedFloor',
      ),
      FieldValueWidget(
        value: location.room,
        field: 'Room / Location',
      ),
    ];
  }

  List<Widget> buildUserAttributes(
    PlatformUser user, {
    bool isResolverAndNotAuthor = false,
  }) {
    final role = '${isResolverAndNotAuthor ? 'Resolved' : 'Raised'} by';

    return [
      FieldValueWidget(
        icon: isResolverAndNotAuthor
            ? FontAwesomeIcons.tools
            : FontAwesomeIcons.user,
        value: user.name,
        field: role,
      ),
      FieldValueWidget(
        value: user.email,
      ),
      FieldValueWidget(
        icon: FontAwesomeIcons.mobile,
        value: user.phoneNumber,
        field: 'Contact No.',
      ),
    ];
  }

  Widget buildRemarksWidget(String remarks, ThemeData theme) {
    return FadeInLeft(
      preferences: AnimationPreferences(
        duration: const Duration(milliseconds: 300),
        offset: const Duration(milliseconds: 150),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Remarks: $remarks',
          style: TextStyle(
            color: theme.primaryColor,
          ),
        ),
      ),
    );
  }

  Widget buildIssueId(IssueSnapshot issueSnapshot, ThemeData theme) {
    return FadeIn(
      preferences: AnimationPreferences(
        duration: const Duration(milliseconds: 400),
        offset: const Duration(milliseconds: 1000),
      ),
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            'ID: ${issueSnapshot.id}',
            style: TextStyle(
              color: theme.disabledColor,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildResolveThisIssueButton(
    UserSnapshot currentUser,
    IssueSnapshot issueSnapshot,
    ThemeData theme,
  ) {
    return OutlinedButton.icon(
      icon: Icon(FontAwesomeIcons.tools, size: 16),
      label: Text('Resolve this issue'),
      onPressed: () =>
          onResolveThisIssuePressed(context, issueSnapshot, currentUser),
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

  Future<_AuthorAndResolverPair> getAuthorAndResolver(Issue issue) async {
    final author = await PlatformUser.getUserFromId(issue.raisedBy.id);

    UserSnapshot? resolver;

    if (issue.resolvedBy != null) {
      resolver = await PlatformUser.getUserFromId(issue.resolvedBy!.id);
    }

    return Pair(author, resolver);
  }

  Future<void> onResolveThisIssuePressed(
    BuildContext context,
    IssueSnapshot issueSnapshot,
    UserSnapshot resolver,
  ) async {
    final _remarksController = TextEditingController();

    final dialogResult = await showDialog<DialogResult>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return FieldValueEditDialog(
          title: 'Resolve this issue?',
          content: TextFieldWidget(
            controller: _remarksController,
            hintText: 'Remarks (optional)',
            prefixIconData: FontAwesomeIcons.alignLeft,
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
          okButtonText: 'Yes, Resolve!',
        );
      },
    );

    // TODO: show a loader here

    if (dialogResult == DialogResult.ok) {
      await issueSnapshot.resolve(
        resolverSnapshot: resolver,
        remarks: _remarksController.text,
      );
    }
  }
}

typedef _AuthorAndResolverPair = Pair<UserSnapshot?, UserSnapshot?>;
