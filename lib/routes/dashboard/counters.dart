import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vitcc_electrical_issues/models/misc.dart';

class ActiveAndResolvedCountWidget extends StatelessWidget {
  const ActiveAndResolvedCountWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final misc = Provider.of<MiscSnapshot?>(context)?.misc;

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      child: LayoutBuilder(builder: (context, constraints) {
        return ConstrainedBox(
          constraints: constraints,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: buildInfoWidget(
                  description: 'issues being resolved',
                  value: misc?.activeIssuesCount,
                ),
              ),
              Expanded(
                child: buildInfoWidget(
                  description: 'issues resolved so far',
                  value: misc?.resolvedIssuesCount,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget buildInfoWidget({required String description, required int? value}) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Column(
          children: [
            Text(
              '${value ?? '-'}',
              style: theme.textTheme.headline5?.apply(
                color: theme.primaryColor,
              ),
            ),
            SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                color: theme.primaryColor.withOpacity(0.75),
              ),
            )
          ],
        );
      },
    );
  }
}
