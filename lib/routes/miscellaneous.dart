//ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';
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

  final String appName = ElectricalIssueTrackerApp.appName;
  final Widget? appIcon = ElectricalIssueTrackerApp.appIcon;
  final String appLegalese = ElectricalIssueTrackerApp.appLegalese;

  String? appVersion; // Will be obtained by future builder in child

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final materialLocalizations = MaterialLocalizations.of(context);

    final user = userSnapshot.user;

    final attributeValueStyle = theme.textTheme.caption?.copyWith(
      fontWeight: FontWeight.bold,
    );

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
                        appLegalese,
                        style: theme.textTheme.caption,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton.icon(
              onPressed: AuthService.signOut,
              icon: Icon(FontAwesome5.sign_out_alt),
              label: Text('Sign out'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Project Maintained by',
              style: theme.textTheme.bodyText2?.copyWith(
                color: theme.primaryColor,
              ),
            ),
          ),
          for (final maintainer in Maintainer.all)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 26,
                    width: 26,
                    child: CircleAvatar(
                      foregroundImage:
                          NetworkImage('${maintainer.photoURL}&s=70'),
                      child: Text(maintainer.username[0]),
                    ),
                  ),
                ),
                Link(
                  uri: Uri.tryParse(maintainer.uri),
                  builder: (context, followLink) {
                    return TextButton(
                      onPressed: followLink,
                      child: Text(
                        'github.com/${maintainer.username}',
                        style: theme.textTheme.caption
                            ?.copyWith(letterSpacing: 0.5),
                      ),
                    );
                  },
                ),
              ],
            )
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
}
