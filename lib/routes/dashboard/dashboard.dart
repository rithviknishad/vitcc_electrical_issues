import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:provider/provider.dart';
import 'package:vitcc_electrical_issues/main.dart';
import 'package:vitcc_electrical_issues/models/misc.dart';
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
  final title = TextEditingController();
  final description = TextEditingController();

  bool isImportant = false;
  bool isUrgent = false;

  final locationBlock = TextEditingController();
  final locationFloor = TextEditingController();
  final locationRoom = TextEditingController();

  // Storing "Theme.of(context)" here, so that different builders of this object can share it.
  // Marked `late` so that it's initialized lazily to prevent "_dependOnInheritedWidgetOfType called before initState" issue.
  late final theme = Theme.of(context);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SizedBox(
      height: size.height,
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
            Builder(builder: buildIssueTitleSection),
            SizedBox(height: 8),
            Builder(builder: buildIssuePrioritySection),
            SizedBox(height: 16),
            Builder(builder: buildIssueLocationSection),
            SizedBox(height: 16),
            Builder(builder: buildIssueDescriptionSection),
          ],
        ),
      ),
    );
  }

  Widget buildIssueTitleSection(BuildContext context) {
    return Column(
      children: [
        TextFieldWidget(
          controller: title,
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
      ],
    );
  }

  Widget buildIssuePrioritySection(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              'Is this issue important or urgent?',
              style: TextStyle(
                color: theme.primaryColor,
              ),
            ),
          ),
        ),
        Row(
          children: [
            SizedBox(width: 8),
            ActionChip(
              backgroundColor:
                  isImportant ? theme.primaryColor : theme.colorScheme.surface,
              label: Text(
                '${isImportant ? '' : 'Not'} Important',
                style: TextStyle(
                  color: isImportant
                      ? theme.colorScheme.surface
                      : theme.primaryColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onPressed: () => setState(() => isImportant = !isImportant),
              elevation: 0,
              pressElevation: 0,
            ),
            SizedBox(width: 8),
            ActionChip(
              backgroundColor:
                  isUrgent ? theme.primaryColor : theme.colorScheme.surface,
              label: Text(
                '${isUrgent ? '' : 'Not'} Urgent',
                style: TextStyle(
                  color:
                      isUrgent ? theme.colorScheme.surface : theme.primaryColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onPressed: () => setState(() => isUrgent = !isUrgent),
              elevation: 0,
              pressElevation: 0,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              'Click the chips to toggle between selection states',
              style: theme.textTheme.caption,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildIssueLocationSection(BuildContext context) {
    final misc = Provider.of<MiscSnapshot?>(context)?.data()!;

    if (misc == null) {
      // TODO: impl. a nice loader here...
      return Container();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              'Where is the issue?',
              style: TextStyle(
                color: theme.primaryColor,
              ),
            ),
          ),
        ),
        Wrap(
          alignment: WrapAlignment.spaceEvenly,
          runAlignment: WrapAlignment.spaceEvenly,
          spacing: 8.0,
          // runSpacing: 8.0,
          children: [
            for (final block in misc.locationBlocks)
              ActionChip(
                backgroundColor: block == locationBlock.text
                    ? theme.primaryColor
                    : theme.colorScheme.surface,
                label: Text(
                  block,
                  style: TextStyle(
                    color: block == locationBlock.text
                        ? theme.colorScheme.surface
                        : theme.primaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onPressed: () => setState(() => locationBlock.text = block),
                elevation: 0,
                pressElevation: 0,
              ),
          ],
        ),
      ],
    );
  }

  Widget buildIssueDescriptionSection(BuildContext context) {
    return Column(
      children: [
        TextFieldWidget(
          controller: description,
          hintText: 'Describe the issue',
        ),
      ],
    );
  }
}
