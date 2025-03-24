// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Necesario para inputFormatters

class InputField extends StatelessWidget {
  final String? hintText;
  final String? labelText;
  final String? helperText;
  final IconData? icon;
  final Widget? suffixIcon;
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
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final double? height;

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
    this.inputFormatters,
    this.maxLines = 1,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TextFormField(
        controller: controller,
        autofocus: false,
        validator: validator,
        readOnly: readOnly,
        enabled: enabled,
        maxLines: maxLines,
        textCapitalization: textCapitalization,
        keyboardType: keyboardType ?? TextInputType.text,
        obscureText: obscureText,
        onChanged: onChanged,
        inputFormatters:
            inputFormatters, // Agregar inputFormatters al TextFormField
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
      ),
    );
  }
}
