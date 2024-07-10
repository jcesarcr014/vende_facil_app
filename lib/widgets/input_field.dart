import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final String? hintText;
  final String? labelText;
  final String? helperText;
  final IconData? icon;
  final Widget? suffixIcon; // corregido el nombre sufixIcon a suffixIcon
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final TextCapitalization textCapitalization;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
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
    this.suffixIcon,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    required this.controller,
    this.onChanged,
    this.validator,
    this.errorText,
    this.formValues,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      autofocus: false,
      validator: validator,
      readOnly: readOnly,
      enabled: enabled,
      textCapitalization: textCapitalization,
      keyboardType: keyboardType ?? TextInputType.text,
      obscureText: obscureText,
      onChanged: onChanged,
      decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        hintText: hintText,
        labelText: labelText,
        errorText: errorText,
        helperText: helperText,
        suffixIcon: suffixIcon,
        icon: icon == null ? null : Icon(icon),
      ),
    );
  }
}
