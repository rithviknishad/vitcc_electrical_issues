import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:vitcc_electrical_issues/models/misc.dart';

class ActiveAndResolvedIssueCounters extends StatelessWidget {
  const ActiveAndResolvedIssueCounters({
    required this.misc,
    Key? key,
  }) : super(key: key);

  final Misc misc;

  @override
  Widget build(BuildContext context) {
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
                  value: misc.activeIssuesCount,
                ),
              ),
              Expanded(
                child: buildInfoWidget(
                  description: 'issues resolved so far',
                  value: misc.resolvedIssuesCount,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget buildInfoWidget({
    required String description,
    required int value,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);

        return Column(
          children: [
            FadeInDown(
              key: Key('$value$description'),
              preferences: const AnimationPreferences(
                duration: const Duration(milliseconds: 300),
                offset: const Duration(milliseconds: 100),
              ),
              child: Text(
                '$value',
                style: theme.textTheme.headline5?.apply(
                  color: theme.primaryColor,
                ),
              ),
            ),
            SizedBox(height: 12),
            FadeIn(
              key: Key(description),
              child: Text(
                description,
                style: TextStyle(
                  color: theme.disabledColor,
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
