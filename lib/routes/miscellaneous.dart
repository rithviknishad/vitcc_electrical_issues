//ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/link.dart';
import 'package:vitcc_electrical_issues/main.dart';
import 'package:vitcc_electrical_issues/models/maintainer.dart';
import 'package:vitcc_electrical_issues/models/user.dart';
import 'package:vitcc_electrical_issues/services/auth_service.dart';

class MiscellaneousDialog extends StatelessWidget {
  MiscellaneousDialog({
    required this.userSnapshot,
    Key? key,
  }) : super(key: key);

  final UserSnapshot userSnapshot;

  String? appVersion; // Will be obtained by future builder in child

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final materialLocalizations = MaterialLocalizations.of(context);

    final appIcon = Image(
      image: ElectricalIssueTrackerApp.appIcon,
    );

    return AlertDialog(
      content: ListBody(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              appIcon,
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ListBody(
                    children: [
                      Text(
                        ElectricalIssueTrackerApp.appName,
                        style: theme.textTheme.headline5,
                      ),
                      FutureBuilder<PackageInfo>(
                        future: PackageInfo.fromPlatform(),
                        builder: (context, snapshot) {
                          appVersion = 'version ${snapshot.data?.version}';
                          return Text(
                            appVersion ?? '',
                            style: theme.textTheme.bodyText2,
                          );
                        },
                      ),
                      const SizedBox(height: 18),
                      Text(
                        ElectricalIssueTrackerApp.appLegalese,
                        style: theme.textTheme.caption,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Current user attributes
          ...buildUserAttributes(theme, userSnapshot),

          // Sign out button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton.icon(
              onPressed: () {
                AuthService.signOut();
                Navigator.of(context).pop();
              },
              icon: Icon(FontAwesome5.sign_out_alt),
              label: Text('Sign out'),
            ),
          ),

          // Project maintained by
          SizedBox(height: 8),
          ...buildProjectMaintainers(theme),

          // Facing issues using the platform
          SizedBox(height: 16),
          ...buildIssueTrackerWidgets(theme),

          // Contribution pointers
          SizedBox(height: 16),
          ...buildProjectRepositoryAttributes(theme),
        ],
      ),
      actions: [
        TextButton(
          child: Text(materialLocalizations.viewLicensesButtonLabel),
          onPressed: () {
            showLicensePage(
              context: context,
              applicationName: ElectricalIssueTrackerApp.appName,
              applicationVersion: appVersion,
              applicationIcon: appIcon,
              applicationLegalese: ElectricalIssueTrackerApp.appLegalese,
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

  List<Widget> buildUserAttributes(ThemeData theme, UserSnapshot userSnapshot) {
    final attributeValueStyle = theme.textTheme.caption?.copyWith(
      fontWeight: FontWeight.bold,
    );

    final user = userSnapshot.user;

    final permissions = {
      'Create new issue': user.scope.canCreateIssue,
      'View issues raised by you': true,
      'Purge active issues raised by you': true,
      'Purge resolved issues raised by you': false,
      'View all active issues raised by anyone': user.scope.canViewActiveIssues,
      'View all resolved issues raised by anyone':
          user.scope.canViewResolvedIssues,
      'Resolve an active issue': user.scope.canResolveIssue,
      'Purge active issues NOT raised by you': user.scope.canPurgeIssue,
      'Purge resolved issues NOT raised by you': false,
    };

    return [
      buildUserAttribute(
        'Signed in as',
        user.name ?? user.email ?? userSnapshot.id,
        theme.textTheme.caption,
        attributeValueStyle,
      ),
      buildUserAttribute(
        'Email',
        '${user.email}',
        theme.textTheme.caption,
        attributeValueStyle,
      ),
      buildUserAttribute(
        'UID',
        userSnapshot.id,
        theme.textTheme.caption,
        attributeValueStyle,
      ),
      SizedBox(height: 8),
      Padding(
        padding: const EdgeInsets.all(4),
        child: Text(
          'You have the following permissions ',
          style: theme.textTheme.caption,
        ),
      ),
      SizedBox(height: 6),
      for (final permission in permissions.entries)
        Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              SizedBox(width: 8),
              Icon(
                permission.value ? FontAwesome5.check : FontAwesome5.times,
                color: permission.value ? Colors.green : Colors.red,
                size: 12,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  permission.key,
                  style: theme.textTheme.caption?.copyWith(
                    color: permission.value ? Colors.green : Colors.red,
                  ),
                ),
              )
            ],
          ),
        )
    ];
  }

  Widget buildUserAttribute(
    String key,
    String value,
    TextStyle? keyTheme,
    TextStyle? valueTheme,
  ) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('$key ', style: keyTheme),
          Text(value, style: valueTheme),
        ],
      ),
    );
  }

  List<Widget> buildIssueTrackerWidgets(ThemeData theme) {
    return [
      Text(
        'Facing issues using the platform?',
        style: theme.textTheme.bodyText2?.copyWith(
          color: theme.primaryColor,
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            flex: 3,
            child: Link(
              uri: Uri.tryParse(ElectricalIssueTrackerApp.appIssueTracker),
              builder: (context, followLink) {
                return MaterialButton(
                  padding: const EdgeInsets.all(1),
                  onPressed: followLink,
                  child: Text(
                    'View/report on GitHub',
                    style: theme.textTheme.caption,
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                'or',
                style: theme.textTheme.caption?.copyWith(
                  color: theme.primaryColor,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Link(
              uri: Uri.tryParse(
                'mailto:${ElectricalIssueTrackerApp.appIssueTrackerMailing}',
              ),
              builder: (context, followLink) {
                return MaterialButton(
                  padding: const EdgeInsets.all(1),
                  onPressed: followLink,
                  child: Text(
                    'Send us a mail',
                    style: theme.textTheme.caption,
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> buildProjectMaintainers(ThemeData theme) {
    return [
      Text(
        'Project maintained by',
        style: theme.textTheme.bodyText2?.copyWith(
          color: theme.primaryColor,
        ),
      ),
      SizedBox(height: 8),
      for (final maintainer in Maintainer.all)
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 26,
              width: 26,
              child: CircleAvatar(
                foregroundImage: NetworkImage('${maintainer.photoURL}&s=70'),
                child: Text(maintainer.username[0]),
              ),
            ),
            SizedBox(width: 8),
            Link(
              uri: Uri.tryParse(maintainer.uri),
              builder: (context, followLink) {
                return TextButton(
                  onPressed: followLink,
                  child: Text(
                    'github.com/${maintainer.username}',
                    style:
                        theme.textTheme.caption?.copyWith(letterSpacing: 0.5),
                  ),
                );
              },
            ),
          ],
        ),
    ];
  }

  List<Widget> buildProjectRepositoryAttributes(ThemeData theme) {
    return [
      Text(
        'Willing to contribute to this open source project?',
        style: theme.textTheme.bodyText2?.copyWith(
          color: theme.primaryColor,
        ),
      ),
      Link(
        uri: Uri.tryParse(ElectricalIssueTrackerApp.appRepository),
        builder: (context, followLink) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                backgroundColor: theme.primaryColor,
              ),
              onPressed: followLink,
              icon: Icon(
                FontAwesome5.github,
                color: Colors.white,
              ),
              label: Text(
                'vitcc_electrical_issues',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          );
        },
      ),
    ];
  }
}
