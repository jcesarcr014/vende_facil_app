import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final String? hintText;
  final String? labelText;
  final String? helperText;
  final IconData? icon;
  final Widget? sufixIcon;
  final TextInputType? keyboardType;
  final Function(String)? onChangeText;
  final TextCapitalization? textCapitalization;
  final bool? obscureText;
  final bool? readOnly;
  final TextEditingController controller;
  final Map<String, String>? formValues;
  final String? Function(String?)? validator;
  final String? errorText;

  const InputField({
    Key? key,
    this.hintText,
    this.labelText,
    this.helperText,
    this.icon,
    this.sufixIcon,
    this.keyboardType,
    this.textCapitalization,
    this.obscureText,
    this.formValues,
    this.readOnly,
    required this.controller,
    this.onChangeText,
    this.validator,
    this.errorText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      autofocus: false,
      validator: validator,
      initialValue: null,
      readOnly: readOnly ?? false,
      textCapitalization: textCapitalization ?? TextCapitalization.none,
      keyboardType: keyboardType ?? TextInputType.text,
      obscureText: obscureText ?? false,
      decoration: InputDecoration(
        border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        hintText: hintText,
        labelText: labelText,
        errorText: errorText,
        helperText: helperText,
        suffixIcon: sufixIcon,
        icon: icon == null ? null : Icon(icon),
      ),
    );
  }
}
