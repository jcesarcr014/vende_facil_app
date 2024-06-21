import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class InputFieldMoney extends StatefulWidget {
  final String? hintText;
  final String? labelText;
  final String? helperText;
  final IconData? icon;
  final Widget? suffixIcon;
  final TextCapitalization textCapitalization;
  final bool readOnly;
  final bool enabled;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String? errorText;
  final double? fontSize;

  const InputFieldMoney(
      {Key? key,
      this.hintText,
      this.labelText,
      this.helperText,
      this.icon,
      this.suffixIcon,
      this.textCapitalization = TextCapitalization.none,
      this.readOnly = false,
      this.enabled = true,
      required this.controller,
      this.validator,
      this.errorText,
      this.fontSize})
      : super(key: key);

  @override
  _InputFieldMoneyState createState() => _InputFieldMoneyState();
}

class _InputFieldMoneyState extends State<InputFieldMoney> {
  String? errorText;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_formatMoney);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_formatMoney);
    super.dispose();
  }

  void _formatMoney() {
    final text = widget.controller.text;
    if (text.isNotEmpty) {
      // Reemplazamos cualquier carácter no numérico y punto decimal
      final value =
          double.tryParse(text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      autofocus: false,
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      style: TextStyle(fontSize: widget.fontSize),
      decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        hintText: widget.hintText,
        labelText: widget.labelText,
        errorText: errorText,
        helperText: widget.helperText,
        suffixIcon: widget.suffixIcon,
        icon: widget.icon == null
            ? const Icon(Icons.attach_money)
            : Icon(widget.icon),
      ),
    );
  }

  void validate() {
    setState(() {
      errorText = widget.validator?.call(widget.controller.text);
    });
  }
}
