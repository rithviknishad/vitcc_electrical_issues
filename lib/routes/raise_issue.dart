import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:vitcc_electrical_issues/models/issue.dart';
import 'package:vitcc_electrical_issues/models/issue_location.dart';
import 'package:vitcc_electrical_issues/models/misc.dart';
import 'package:vitcc_electrical_issues/shared/text_field_widget.dart';
import 'package:vitcc_electrical_issues/models/user.dart';

class RaiseNewIssueBottomSheet extends StatefulWidget {
  const RaiseNewIssueBottomSheet({Key? key}) : super(key: key);

  @override
  _RaiseNewIssueBottomSheetState createState() =>
      _RaiseNewIssueBottomSheetState();
}

class _RaiseNewIssueBottomSheetState extends State<RaiseNewIssueBottomSheet> {
  final formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  bool isImportant = false;
  bool isUrgent = false;

  final blockController = TextEditingController();
  final otherBlockController = TextEditingController();
  final floorController = TextEditingController();
  final roomController = TextEditingController();

  // Storing `Theme.of(context)` and `MediaQuery.of(context).size` here, so that different builders of this object can share it.
  // Marked `late` so that it's initialized lazily to prevent "_dependOnInheritedWidgetOfType called before initState" issue.
  late final theme = Theme.of(context);
  late final size = MediaQuery.of(context).size;

  /// This is used to prevent accidental submissions of incomplete issues.
  ///
  /// When the value is `false`, the submit button will validate the form and
  /// set the value to `true`. Upon pressing again, the form will be revalidated
  /// and the issue will be submitted.
  ///
  /// Failing to validate during revalidate process will cause this lock to be
  /// set to `false` again.
  bool canSubmit = false;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    blockController.dispose();
    otherBlockController.dispose();
    floorController.dispose();
    roomController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size.height,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Builder(builder: buildIssueTitleSection),
              SizedBox(height: 16),
              Builder(builder: buildIssuePrioritySection),
              SizedBox(height: 16),
              Builder(builder: buildIssueLocationSection),
              SizedBox(height: 16),
              Builder(builder: buildIssueDescriptionSection),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _onSubmitButtonPressed,
                child: Text(
                  canSubmit ? 'Yes, Submit!' : 'Submit',
                ),
              ),
              SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onSubmitButtonPressed() async {
    // Cancel issue submission if failed to validate form and reset canSubmit.
    if (!(formKey.currentState?.validate() ?? false)) {
      setState(() => canSubmit = false);
      return;
    }

    // Set canSubmit and return.
    if (!canSubmit) {
      setState(() => canSubmit = true);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Tap again just to confirm'),
            FaIcon(
              FontAwesomeIcons.clipboardCheck,
              color: Colors.white,
            ),
          ],
        ),
      ));

      return;
    }

    // The following is allowed to run, only if form is valid and submission
    // is user conscious.

    final currentUser = Provider.of<UserSnapshot>(context, listen: false);

    final location = IssueLocation(
      block: blockController.text == 'Other'
          ? otherBlockController.text
          : blockController.text,
      floor: floorController.text,
      room: roomController.text,
    );

    final issue = await Issue.create(
      creatorSnapshot: currentUser,
      title: titleController.text,
      description: descriptionController.text,
      location: location,
      isImportant: isImportant,
      isUrgent: isUrgent,
    );

    Navigator.of(context).pop(issue);
  }

  Widget buildIssueTitleSection(BuildContext context) {
    return Column(
      children: [
        TextFieldWidget(
          controller: titleController,
          hintText: 'What is the issue?',
          validator: RequiredValidator(
            errorText: 'Describe the issue in short',
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              'e.g. "Air Conditioner not working"',
              style: theme.textTheme.caption,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildIssuePrioritySection(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              'Is this issue important or urgent?',
              style: TextStyle(
                color: theme.primaryColor,
              ),
            ),
          ),
        ),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ActionChip(
                backgroundColor: isImportant
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onPrimary,
                label: Text(
                  'Important',
                  style: TextStyle(
                    color: isImportant
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onPressed: () => setState(() => isImportant = !isImportant),
                elevation: 0,
                pressElevation: 0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ActionChip(
                backgroundColor: isUrgent
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onPrimary,
                label: Text(
                  'Urgent',
                  style: TextStyle(
                    color: isUrgent
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onPressed: () => setState(() => isUrgent = !isUrgent),
                elevation: 0,
                pressElevation: 0,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              'Select applicable priorities for this issue',
              style: theme.textTheme.caption,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildIssueLocationSection(BuildContext context) {
    final misc = Provider.of<MiscSnapshot>(context).misc;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              'Where is the issue?',
              style: TextStyle(
                color: theme.primaryColor,
              ),
            ),
          ),
          SizedBox(height: 4),
          FormField<String>(
            initialValue: '',
            validator: RequiredValidator(
              errorText: "Select a block otherwise select 'Other'",
            ),
            builder: (field) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (field.hasError)
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          field.errorText!,
                          style: TextStyle(
                            color: theme.errorColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  Wrap(
                    alignment: WrapAlignment.start,
                    runAlignment: WrapAlignment.start,
                    spacing: 8.0,
                    children: [
                      for (final block in [...misc.locationBlocks, 'Other'])
                        ActionChip(
                          backgroundColor: block == blockController.text
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onPrimary,
                          label: Text(
                            block,
                            style: TextStyle(
                              color: block == blockController.text
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onPressed: () {
                            field.didChange(block);
                            setState(() => blockController.text = block);
                          },
                          elevation: 0,
                          pressElevation: 0,
                        ),
                    ],
                  ),
                ],
              );
            },
          ),

          // Other location, pushed into tree conditionally
          if (blockController.text == 'Other') ...[
            SizedBox(height: 8),
            TextFieldWidget(
              controller: otherBlockController,
              hintText: 'Which block / area?',
              validator: RequiredValidator(
                errorText: 'Required to resolve the issue.',
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "e.g. 'Dominos Pizza' or 'Gym'",
                  style: theme.textTheme.caption,
                ),
              ),
            ),
          ],

          SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(
                width: 100,
                child: TextFieldWidget(
                  controller: floorController,
                  hintText: 'Floor',
                  validator: RequiredValidator(
                    errorText: "e.g. '6' or 'N/A'",
                  ),
                ),
              ),
              SizedBox(
                width: 160,
                child: TextFieldWidget(
                  controller: roomController,
                  hintText: 'Room / Location',
                  validator: RequiredValidator(
                    errorText: "e.g. '603' or 'Cabin #' or 'N/A'",
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget buildIssueDescriptionSection(BuildContext context) {
    return Column(
      children: [
        TextFieldWidget(
          controller: descriptionController,
          maxLines: null,
          hintText: 'Describe the issue (optional)',
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              'Include details such as when this issue started or how the issue was noticed, etc.',
              style: theme.textTheme.caption,
            ),
          ),
        ),
      ],
    );
  }
}
