import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:vitcc_electrical_issues/main.dart';
import 'package:vitcc_electrical_issues/models/issue_location.dart';
import 'package:vitcc_electrical_issues/shared/text_field_widget.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: FadeInLeft(
          preferences: const AnimationPreferences(
            duration: Duration(milliseconds: 400),
          ),
          child: Text(
            _raiseNewIssueFormIsShown
                ? 'Raise an issue'
                : ElectricalIssueTrackerApp.title,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [],
        ),
      ),
      floatingActionButton: _raiseNewIssueFormIsShown
          ? null
          : Builder(
              builder: (context) {
                return FloatingActionButton.extended(
                  onPressed: () async {
                    setState(() => _raiseNewIssueFormIsShown = true);

                    await Scaffold.of(context)
                        .showBottomSheet(
                          (_) => _RaiseNewIssueBottomSheet(),
                          backgroundColor: theme.appBarTheme.backgroundColor,
                        )
                        .closed;

                    setState(() => _raiseNewIssueFormIsShown = false);
                  },
                  tooltip: 'Click to raise a new issue.',
                  label: Text('Raise a new issue'),
                  icon: Icon(FontAwesome5.feather),
                );
              },
            ),
    );
  }
}

class _RaiseNewIssueBottomSheet extends StatefulWidget {
  const _RaiseNewIssueBottomSheet({Key? key}) : super(key: key);

  @override
  __RaiseNewIssueBottomSheetState createState() =>
      __RaiseNewIssueBottomSheetState();
}

class __RaiseNewIssueBottomSheetState extends State<_RaiseNewIssueBottomSheet> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  bool isImportant = false;
  bool isUrgent = false;

  IssueLocation issueLocation = IssueLocation(
    block: '',
    floor: '',
    room: '',
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Title of the issue
            TextFieldWidget(
              controller: titleController,
              hintText: 'What is the issue?',
              validator: RequiredValidator(
                errorText: 'Describe the issue in short',
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'e.g. "Air Conditioner not working"',
                  style: theme.textTheme.caption,
                ),
              ),
            ),

            SizedBox(height: 8),

            // Describe the issue
            TextFieldWidget(
              controller: descriptionController,
              hintText: 'Describe the issue',
            ),

            // Tips on describing an issue
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                'Tips to describe an issue\n1. Check if appliance has power',
              ),
            )
          ],
        ),
      ),
    );
  }
}
