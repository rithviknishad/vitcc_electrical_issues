import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FieldValueWidget extends StatelessWidget {
  final IconData? icon;
  final String? field;
  final String? value;
  final VoidCallback? onPressed;
  final List<Widget>? actions;

  FieldValueWidget({
    this.icon,
    this.field,
    required this.value,
    this.onPressed,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isSpecified = value?.isNotEmpty ?? false;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                FadeInLeft(
                  preferences: AnimationPreferences(
                    duration: const Duration(milliseconds: 200),
                    offset: const Duration(milliseconds: 100),
                  ),
                  child: FaIcon(
                    icon,
                    size: 18,
                    color:
                        isSpecified ? theme.primaryColor : theme.disabledColor,
                  ),
                ),

                // Value
                SizedBox(width: 16),

                FadeInLeft(
                  preferences: AnimationPreferences(
                    duration: const Duration(milliseconds: 200),
                  ),
                  child: Text(
                    isSpecified ? '$value' : 'Not specified',
                    style: TextStyle(
                      color: isSpecified
                          ? theme.primaryColor
                          : theme.disabledColor,
                    ),
                  ),
                ),

                // Field Name
                SizedBox(width: 10),
                if (field != null)
                  FadeIn(
                    preferences: AnimationPreferences(
                      duration: const Duration(milliseconds: 300),
                      offset: const Duration(milliseconds: 150),
                    ),
                    child: Text(
                      '($field)',
                      style: TextStyle(
                        color: theme.disabledColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (actions != null) Row(children: actions!),
      ],
    );
  }
}
