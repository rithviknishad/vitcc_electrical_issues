import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:provider/provider.dart';
import 'package:vitcc_electrical_issues/main.dart';
import 'package:vitcc_electrical_issues/models/misc.dart';
import 'package:vitcc_electrical_issues/models/user.dart';
import 'package:vitcc_electrical_issues/routes/dashboard/active_issues.dart';
import 'package:vitcc_electrical_issues/routes/dashboard/counters.dart';
import 'package:vitcc_electrical_issues/routes/dashboard/my_issues.dart';
import 'package:vitcc_electrical_issues/routes/dashboard/raise_issue_section.dart';
import 'package:vitcc_electrical_issues/routes/miscellaneous.dart';
import 'package:vitcc_electrical_issues/routes/raise_issue.dart';
import 'package:vitcc_electrical_issues/routes/resolved_issues.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();

  static _DashboardPageState of(BuildContext context) =>
      context.findAncestorStateOfType<_DashboardPageState>()!;
}

class _DashboardPageState extends State<DashboardPage> {
  bool _raiseNewIssueFormIsShown = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final misc = Provider.of<MiscSnapshot>(context).misc;

    final userSnapshot = Provider.of<UserSnapshot>(context);
    final user = userSnapshot.user;

    NetworkImage? userPhoto;

    final photoUrl = Provider.of<User>(context).photoURL;

    if (photoUrl != null) {
      userPhoto = NetworkImage(photoUrl);
    }

    return Scaffold(
      appBar: AppBar(
        title: FadeInLeft(
          preferences: const AnimationPreferences(
            duration: Duration(milliseconds: 400),
          ),
          child: Text(
            _raiseNewIssueFormIsShown
                ? 'Raise an issue'
                : ElectricalIssueTrackerApp.appName,
          ),
        ),
        actions: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => showDialog(
              context: context,
              builder: (_) => MiscellaneousDialog(userSnapshot),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: PhysicalModel(
                color: Colors.transparent,
                elevation: 3,
                shape: BoxShape.circle,
                child: CircleAvatar(
                  backgroundColor: theme.primaryColor,
                  child: Text(
                    ('${user.name}${user.email}-'[0]).toUpperCase(),
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                  foregroundImage: userPhoto,
                ),
              ),
            ),
          ),
        ],
      ),
      body: CupertinoScrollbar(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(8),
          child: Wrap(
            spacing: 10,
            runSpacing: 30,
            children: [
              // The analytics widget
              ActiveAndResolvedIssueCounters(misc: misc),

              // View all active issues if user has permission
              if (user.scope.canViewActiveIssues) ActiveIssuesSection(),

              if (user.scope.canViewResolvedIssues)
                buildResolvedIssuesButton(misc, userSnapshot),

              // Raise an issue section
              if (user.scope.canCreateIssue) RaiseAnIssueSection(),

              // All issues raised by the user.
              MyIssuesSection(),

              // Footer
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> showRaiseNewIssueForm(BuildContext context) async {
    setState(() => _raiseNewIssueFormIsShown = true);

    await Scaffold.of(context)
        .showBottomSheet((_) => RaiseNewIssueBottomSheet())
        .closed;

    setState(() => _raiseNewIssueFormIsShown = false);
  }

  Widget buildResolvedIssuesButton(Misc misc, UserSnapshot userSnapshot) {
    return Center(
      child: OutlinedButton(
        child: Text('View already resolved issues'),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return MultiProvider(
                providers: [
                  Provider.value(value: userSnapshot),
                  Provider.value(value: misc),
                ],
                child: ResolvedIssuesPage(),
              );
            },
          ),
        ),
      ),
    );
  }
}
