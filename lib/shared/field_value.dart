import 'package:flutter/material.dart';

class FieldValueWidget extends StatelessWidget {
  final IconData icon;
  final String? field;
  final String value;
  final VoidCallback? onPressed;
  final List<Widget>? actions;

  FieldValueWidget({
    required this.icon,
    this.field,
    required this.value,
    this.onPressed,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                Icon(
                  icon,
                  size: 18,
                  color: value.isNotEmpty
                      ? theme.primaryColor
                      : theme.disabledColor,
                ),

                // Value
                SizedBox(width: 16),
                if (value.isNotEmpty)
                  Text(value)
                else
                  Text(
                    'Not specified',
                    style: TextStyle(color: theme.disabledColor),
                  ),

                // Field Name
                SizedBox(width: 10),
                if (field != null)
                  Text(
                    '($field)',
                    style: TextStyle(
                        color: theme.disabledColor, letterSpacing: 0.5),
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
