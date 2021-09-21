import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
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
      backgroundColor: theme.accentColor,
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
    );
  }
}
