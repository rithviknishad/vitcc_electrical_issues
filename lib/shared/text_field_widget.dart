import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TextFieldWidget extends StatelessWidget {
  final String hintText;
  final IconData? prefixIconData;
  final IconData? suffixIconData;
  final String? suffixText;
  final bool obscureText;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final GestureTapCallback? onSuffixIconTap;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final int? minLines;
  final int? maxLines;
  final AutovalidateMode autovalidateMode;

  const TextFieldWidget({
    required this.hintText,
    this.prefixIconData,
    this.suffixIconData,
    this.suffixText,
    this.obscureText = false,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
    this.onFieldSubmitted,
    this.onSuffixIconTap,
    required this.controller,
    this.validator,
    this.keyboardType,
    this.autofillHints,
    this.inputFormatters,
    this.readOnly = false,
    this.minLines,
    this.maxLines = 1,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget? _prefixIcon, _suffixIcon;

    if (prefixIconData != null) {
      _prefixIcon = FaIcon(
        prefixIconData,
        size: 18,
        color: theme.primaryColor,
      );
    }

    if (suffixIconData != null) {
      _suffixIcon = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onSuffixIconTap,
        child: FaIcon(
          suffixIconData,
          size: 18,
          color: theme.primaryColor,
        ),
      );
    }

    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: controller,
      style: TextStyle(
        color: theme.primaryColor,
        fontSize: 14.0,
      ),
      minLines: minLines,
      maxLines: maxLines,
      cursorColor: theme.primaryColor,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: hintText,
        suffixText: suffixText,
        prefixIcon: _prefixIcon,
        suffixIcon: _suffixIcon,
        labelStyle: TextStyle(
          color: theme.primaryColor,
        ),
      ),
      textCapitalization: textCapitalization,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      enableSuggestions: true,
      inputFormatters: inputFormatters,
      readOnly: readOnly,
    );
  }
}
