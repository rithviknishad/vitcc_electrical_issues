import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:vitcc_electrical_issues/main.dart';

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
      floatingActionButton: _RaiseANewIssueFAB(),
    );
  }
}

class _RaiseANewIssueFAB extends StatelessWidget {
  const _RaiseANewIssueFAB({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {},
      tooltip: 'Click to raise a new issue.',
      label: Text('Raise a new issue'),
      icon: Icon(FontAwesome5.feather),
    );
  }
}
