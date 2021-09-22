import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:vitcc_electrical_issues/main.dart';
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
          child: Text(ElectricalIssueTrackerApp.title),
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
                        .showBottomSheet((_) => _RaiseNewIssueBottomSheet())
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
  final descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 5, 15, 0),
      height: 450,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 400,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  color: Colors.grey.shade300,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextFieldWidget(
                    controller: descriptionController,
                    hintText: 'Describe the issue',
                    minLines: 4,
                    maxLines: null,
                  ),
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
        ],
      ),
    );
  }
}
