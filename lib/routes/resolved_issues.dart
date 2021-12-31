import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:provider/provider.dart';
import 'package:vitcc_electrical_issues/models/issue.dart';
import 'package:vitcc_electrical_issues/shared/issue_tile.dart';

class ResolvedIssuesPage extends StatefulWidget {
  const ResolvedIssuesPage({Key? key}) : super(key: key);

  @override
  State<ResolvedIssuesPage> createState() => _ResolvedIssuesPageState();
}

class _ResolvedIssuesPageState extends State<ResolvedIssuesPage> {
  bool isLoading = false;

  Stream<List<IssueSnapshot>>? queryResultStream;

  Query<Issue> Function(Query<Issue> query) query =
      Issue.defaultResolvedIssueQuery;

  Future<void> runQuery() async {
    setState(() => isLoading = true);

    queryResultStream = Issue.resolvedIssues(query);

    setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    runQuery();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        title: FadeInRight(
          preferences: const AnimationPreferences(
            duration: Duration(milliseconds: 400),
          ),
          child: Text("Resolved Issues"),
        ),
      ),
      body: CupertinoScrollbar(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(8),
          child: StreamProvider<List<IssueSnapshot>>.value(
            value: queryResultStream,
            initialData: [],
            child: _QueryResultsView(),
          ),
        ),
      ),
    );
  }
}

class _QueryResultsView extends StatelessWidget {
  const _QueryResultsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final queryResults = Provider.of<List<IssueSnapshot>>(context);

    return Column(
      children: [
        Text('${queryResults.length} enttries'),
        for (final issue in queryResults.asMap().entries)
          Provider<IssueSnapshot>.value(
            value: issue.value,
            child: IssueTile(offset: issue.key),
          )
      ],
    );
  }
}
