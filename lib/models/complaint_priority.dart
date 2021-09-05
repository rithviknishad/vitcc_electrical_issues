import 'package:flutter/material.dart';

class ComplaintPriority {
  final String label;
  final Icon icon;

  const ComplaintPriority._(this.label, this.icon);

  static const Normal = ComplaintPriority._(
    'Normal',
    Icon(Icons.auto_fix_normal),
  );

  static const Important = ComplaintPriority._(
    'Important',
    Icon(Icons.important_devices),
  );

  @override
  String toString() => label;
}
