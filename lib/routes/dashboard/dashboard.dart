import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:provider/provider.dart';
import 'package:vitcc_electrical_issues/main.dart';
import 'package:vitcc_electrical_issues/models/user.dart';
import 'package:vitcc_electrical_issues/routes/dashboard/active_issues.dart';
import 'package:vitcc_electrical_issues/routes/dashboard/counters.dart';
import 'package:vitcc_electrical_issues/routes/dashboard/my_issues.dart';
import 'package:vitcc_electrical_issues/routes/dashboard/raise_issue_section.dart';
import 'package:vitcc_electrical_issues/routes/miscellaneous.dart';
import 'package:vitcc_electrical_issues/routes/raise_issue.dart';
import 'package:vitcc_electrical_issues/shared/dialog_result.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();

  static _DashboardPageState of(BuildContext context) =>
      context.findAncestorStateOfType<_DashboardPageState>()!;
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedPage = 2;

  int get selectedPage => _selectedPage;

  set selectedPage(int value) {
    if (value != selectedPage) {
      setState(() => _selectedPage = value);
    }
  }

  bool _raiseNewIssueFormIsShown = false;

  void showMiscellaneousDialog(BuildContext context) async {
    await showDialog<DialogResult>(
      context: context,
      builder: (_) => MiscellaneousDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = Provider.of<UserSnapshot>(context).user;

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
            onTap: () => showMiscellaneousDialog(context),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: PhysicalModel(
                color: Colors.transparent,
                elevation: 3,
                shape: BoxShape.circle,
                child: CircleAvatar(
                  backgroundColor: theme.primaryColor,
                  child: Text(
                    user.name?[0] ?? '',
                    style: TextStyle(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  foregroundImage: userPhoto,
                ),
              ),
            ),
          )
        ],
      ),
      body: CupertinoScrollbar(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(8),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              // The analytics widget
              ActiveAndResolvedCountWidget(),

              // View all active issues if user has permission
              if (user.scope.canViewActiveIssue) ActiveIssuesSection(),

              // Raise an issue section
              RaiseAnIssueSection(),

              // All issues raised by the user.
              MyIssuesSection(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> showRaiseNewIssueForm(BuildContext context) async {
    setState(() => _raiseNewIssueFormIsShown = true);

    await Scaffold.of(context)
        .showBottomSheet(
          (_) => RaiseNewIssueBottomSheet(),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        )
        .closed;

    setState(() => _raiseNewIssueFormIsShown = false);
  }
}
