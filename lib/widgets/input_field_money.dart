import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; // Necesitarás añadir 'intl' a tu pubspec.yaml

class InputFieldMoney extends StatefulWidget {
  final String? hintText;
  final String? labelText;
  final String? helperText;
  final IconData? icon;
  final Widget? suffixIcon;
  final bool readOnly;
  final bool enabled;
  final TextEditingController controller;
  final String? Function(String?)?
      validator; // Lo mantenemos por si lo usas externamente
  final double? fontSize;
  final double? maxValue;
  final FocusNode?
      focusNode; // Opcional: para manejar el foco si es necesario externamente

  const InputFieldMoney({
    super.key,
    this.hintText,
    this.labelText,
    this.helperText,
    this.icon,
    this.suffixIcon,
    this.readOnly = false,
    this.enabled = true,
    required this.controller,
    this.validator,
    this.fontSize,
    this.maxValue,
    this.focusNode,
  });

  @override
  State<InputFieldMoney> createState() => _InputFieldMoneyState();
}

class _InputFieldMoneyState extends State<InputFieldMoney> {
  // Usaremos un FocusNode interno si no se provee uno externo
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);

    // Inicializar el texto del controlador con formato si ya tiene un valor
    // y no es "0.00" por defecto, o si es un valor numérico.
    final initialValue = double.tryParse(widget.controller.text);
    if (initialValue != null && initialValue != 0.0) {
      // No formatear si es 0.00 para permitir al usuario empezar a escribir
      // Pero si es, por ejemplo, un valor cargado (ej. 50), formatearlo.
      if (widget.controller.text != "0.00") {
        widget.controller.text = _formatToCurrency(initialValue);
      }
    } else if (widget.controller.text.isEmpty) {
      widget.controller.text = "0.00"; // Default a 0.00 si está vacío
    }
  }

  @override
  void dispose() {
    // No remover el listener del controller aquí, ya que el MoneyInputFormatter lo maneja.
    _focusNode.removeListener(_onFocusChange);
    // Si creamos el FocusNode internamente, debemos hacer dispose de él.
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    if (!mounted) return;
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    if (_focusNode.hasFocus) {
      // Seleccionar todo el texto al obtener el foco
      widget.controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: widget.controller.text.length,
      );
    } else {
      // Cuando pierde el foco, asegurarse de que el formato final sea correcto.
      // Esto es útil si el usuario deja el campo con algo como "123."
      final currentValue = double.tryParse(
              widget.controller.text.replaceAll(RegExp(r'[^0-9.]'), '')) ??
          0.0;
      widget.controller.text = _formatToCurrency(currentValue);
    }
  }

  String _formatToCurrency(double value) {
    // Usamos NumberFormat para asegurar dos decimales.
    // Puedes quitar el símbolo de moneda si no lo quieres en el campo de edición.
    // final currencyFormatter = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    final numberFormatter =
        NumberFormat("0.00", "es_MX"); // Formato numérico con 2 decimales
    return numberFormatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      textAlign:
          TextAlign.right, // Alinear el texto a la derecha es común para dinero
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(
          fontSize: widget.fontSize ?? 16.0), // Tamaño de fuente por defecto
      inputFormatters: [
        FilteringTextInputFormatter.allow(
            RegExp(r'^\d*\.?\d{0,2}')), // Permite números y hasta 2 decimales
        MoneyInputFormatter(
            maxValue: widget.maxValue), // Formateador personalizado
      ],
      decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        hintText: widget.hintText,
        labelText: widget.labelText,
        // helperText: widget.helperText, // El helper puede interferir con el errorText
        errorText: widget.validator
            ?.call(widget.controller.text), // Usar el validador si se provee
        prefixIcon: widget.icon == null &&
                !_isFocused // Mostrar icono de moneda solo si no hay un icono personalizado y no está enfocado
            ? const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Icon(Icons.attach_money, size: 20),
              )
            : (widget.icon != null ? Icon(widget.icon) : null),
        suffixIcon: widget.suffixIcon,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      validator: widget.validator,
      onTap: () {
        // Al tocar, si ya tiene el foco, no es necesario volver a seleccionar todo,
        // permitir que el usuario coloque el cursor. Si no tiene foco, _onFocusChange lo manejará.
        if (_focusNode.hasFocus) {
          // Si quieres que el segundo toque mueva el cursor, no hagas nada aquí.
          // Si quieres que siempre seleccione todo al tocar (incluso si ya tiene foco):
          // widget.controller.selection = TextSelection(
          //   baseOffset: 0,
          //   extentOffset: widget.controller.text.length,
          // );
        }
      },
    );
  }
}

class MoneyInputFormatter extends TextInputFormatter {
  final double? maxValue;

  MoneyInputFormatter({this.maxValue});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Eliminar cualquier caracter que no sea dígito o punto
    String newText = newValue.text.replaceAll(RegExp(r'[^\d.]'), '');

    // Si hay múltiples puntos, mantener solo el primero
    if (newText.split('.').length > 2) {
      final parts = newText.split('.');
      newText = '${parts[0]}.${parts.sublist(1).join()}';
    }

    // Limitar a dos decimales
    if (newText.contains('.')) {
      final parts = newText.split('.');
      if (parts.length > 1 && parts[1].length > 2) {
        parts[1] = parts[1].substring(0, 2);
        newText = parts.join('.');
      }
    }

    // Validar el valor máximo si se especifica
    double? numericValue = double.tryParse(newText);
    if (maxValue != null && numericValue != null && numericValue > maxValue!) {
      // Si excede el máximo, revertir al valor anterior o al máximo permitido
      // Para una mejor UX, podríamos simplemente limitar al máximo.
      // Por ahora, revertimos al valor antiguo que sí era válido.
      // O podrías formatear el valor máximo y usarlo.
      // Esto evita que el campo se bloquee.
      return oldValue;
    }

    // Al final, el texto en el controlador será este newText.
    // El formateo a "0.00" final se hace en _onFocusChange (al perder foco)
    // o al inicializar. Durante la edición, permitimos que el usuario escriba
    // de forma más natural (ej. "123." o "123.4").

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
