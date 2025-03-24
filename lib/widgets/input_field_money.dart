import 'package:flutter/material.dart';
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
  final double? maxValue; // Nuevo parámetro opcional para el valor máximo

  const InputFieldMoney({
    super.key,
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
    this.fontSize,
    this.maxValue, // Inicialización del nuevo parámetro
  });

  @override
  State<InputFieldMoney> createState() => _InputFieldMoneyState();
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

  // Formateo del dinero y validación del valor máximo
  void _formatMoney() {
    final text = widget.controller.text;
    if (text.isNotEmpty) {
      // Reemplazar caracteres no numéricos y punto decimal
      final value =
          double.tryParse(text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;

      // Si el valor es mayor que el máximo permitido, mostrar mensaje de error
      if (widget.maxValue != null && value > widget.maxValue!) {
        setState(() {
          errorText = "El valor no puede ser mayor a ${widget.maxValue}";
        });
      } else {
        setState(() {
          errorText = null;
        });
      }
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
        // Formateador adicional para evitar valores mayores que maxValue
        if (widget.maxValue != null)
          TextInputFormatter.withFunction((oldValue, newValue) {
            try {
              final value = double.tryParse(newValue.text) ?? 0.0;
              if (value > widget.maxValue!) {
                return oldValue; // Rechazar cambios si el valor es mayor a maxValue
              }
            } catch (e) {
              return oldValue;
            }
            return newValue;
          }),
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
      errorText = widget.validator?.call(widget.controller.text) ??
          (widget.maxValue != null &&
                  (double.tryParse(widget.controller.text) ?? 0.0) >
                      widget.maxValue!
              ? "El valor no puede ser mayor a ${widget.maxValue}"
              : null);
    });
  }
}
