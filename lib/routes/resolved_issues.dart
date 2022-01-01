import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:vitcc_electrical_issues/models/issue.dart';
import 'package:vitcc_electrical_issues/models/issue_location.dart';
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
            key: Key('query_view'),
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

class _QueryBuilderView extends StatefulWidget {
  const _QueryBuilderView({
    required this.onQueryChanged,
    Key? key,
  }) : super(key: key);

  final void Function(QueryBuilder<Issue> newQuery) onQueryChanged;

  @override
  State<_QueryBuilderView> createState() => _QueryBuilderViewState();
}

class _QueryBuilderViewState extends State<_QueryBuilderView> {
  // final resolvedByController = TextEditingController();
  // final raisedByController = TextEditingController();

  final issueTitleController = TextEditingController();

  var raisedOnStartDate = DateTime.now().subtract(const Duration(days: 7));
  var raisedOnEndDate = DateTime.now();

  var issueLocationFilter = IssueLocation(block: '', floor: '', room: '');

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);

    widget.onQueryChanged((query) {
      query = query
          .where(IssueKeys.raisedOn, isGreaterThanOrEqualTo: raisedOnStartDate)
          .where(IssueKeys.raisedOn, isLessThanOrEqualTo: raisedOnEndDate);

      return query;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SfDateRangePicker(
            selectionMode: DateRangePickerSelectionMode.range,
            initialSelectedRange: PickerDateRange(
              raisedOnStartDate,
              raisedOnEndDate,
            ),
            headerHeight: 60,
            onSelectionChanged: (args) {
              final value = args.value;

              if (value is PickerDateRange) {
                setState(() {
                  assert(
                    value.startDate != null,
                    "This shouldn't be null as per configuration of the picker.",
                  );

                  raisedOnStartDate = value.startDate ?? raisedOnStartDate;
                  raisedOnEndDate = value.endDate ?? DateTime.now();
                });
              }
            },
          ),
        ),
        ElevatedButton(
          onPressed: () => setState(() {}),
          child: Text('Run Query'),
        ),
      ],
    );
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
