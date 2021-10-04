import 'package:flutter/material.dart';
import 'package:vitcc_electrical_issues/main.dart';

class MiscellaneousDialog extends StatelessWidget {
  const MiscellaneousDialog({Key? key}) : super(key: key);

  final String appName = ElectricalIssueTrackerApp.appName;
  final Widget? appIcon = ElectricalIssueTrackerApp.appIcon;
  final String appLegalese = ElectricalIssueTrackerApp.appLegalese;
  final String appVersion = ElectricalIssueTrackerApp.appVersion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final materialLocalizations = MaterialLocalizations.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      content: ListBody(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (appIcon != null)
                IconTheme(
                  data: theme.iconTheme,
                  child: appIcon!,
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ListBody(
                    children: [
                      Text(
                        appName,
                        style: theme.textTheme.headline5,
                      ),
                      Text(
                        appVersion,
                        style: theme.textTheme.bodyText2,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        appLegalese,
                        style: theme.textTheme.caption,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // TODO: other stuffs,
        ],
      ),
      actions: [
        TextButton(
          child: Text(materialLocalizations.viewLicensesButtonLabel),
          onPressed: () {
            showLicensePage(
              context: context,
              applicationName: appName,
              applicationVersion: appVersion,
              applicationIcon: appIcon,
              applicationLegalese: appLegalese,
            );
          },
        ),
        TextButton(
          child: Text(materialLocalizations.closeButtonLabel),
          onPressed: Navigator.of(context).pop,
        ),
      ],
      scrollable: true,
    );
  }
}
