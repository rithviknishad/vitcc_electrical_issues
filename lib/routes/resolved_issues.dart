import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:provider/provider.dart';
import 'package:vitcc_electrical_issues/models/issue.dart';
import 'package:vitcc_electrical_issues/shared/issue_tile.dart';
import 'package:vitcc_electrical_issues/shared/query_builder.dart';

class ResolvedIssuesPage extends StatefulWidget {
  const ResolvedIssuesPage({Key? key}) : super(key: key);

  @override
  State<ResolvedIssuesPage> createState() => _ResolvedIssuesPageState();
}

class _ResolvedIssuesPageState extends State<ResolvedIssuesPage> {
  bool isLoading = false;

  Stream<List<IssueSnapshot>>? queryResultStream;

  Future<void> updateQuery(QueryBuilder<Issue> query) async {
    setState(() => isLoading = true);

    queryResultStream = Issue.resolvedIssues(query);

    setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    updateQuery(Issue.defaultResolvedIssueQuery);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            pinned: true,
            title: FadeInRight(
              preferences: const AnimationPreferences(
                duration: Duration(milliseconds: 400),
              ),
              child: Text("Resolved Issues"),
            ),
          ),

          // Query Filter Dialog
          SliverToBoxAdapter(
            child: _QueryBuilderView(
              onQueryChanged: updateQuery,
            ),
          ),

          // Queried Results View
          StreamProvider<List<IssueSnapshot>>.value(
            value: queryResultStream,
            initialData: [],
            child: _QueryResultsView(),
          ),
        ],
      ),
    );
  }
}

class _QueryBuilderView extends StatelessWidget {
  const _QueryBuilderView({
    required this.onQueryChanged,
    Key? key,
  }) : super(key: key);

  final void Function(QueryBuilder<Issue> newQuery) onQueryChanged;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class _QueryResultsView extends StatelessWidget {
  const _QueryResultsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final queryResults = Provider.of<List<IssueSnapshot>>(context);

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final issue = queryResults[index];

          return Provider<IssueSnapshot>.value(
            value: issue,
            child: IssueTile(offset: index),
          );
        },
        childCount: queryResults.length,
      ),
    );
  }
}
