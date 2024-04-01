import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class InputFieldMoney extends StatefulWidget {
  final TextEditingController? controller;
<<<<<<< HEAD
  final String? labelText;

  const InputFieldMoney({Key? key, this.controller, this.labelText})
      : super(key: key);
=======
  final String labelText;

  const InputFieldMoney({super.key, this.controller, this.labelText = 'Monto'});
>>>>>>> 19a980dbe31c4065349feb9e1a43bd41ef6772d7

  @override
  State<InputFieldMoney> createState() => _InputFieldMoneyState();
}

class _InputFieldMoneyState extends State<InputFieldMoney> {
  late TextEditingController _controller;
  late NumberFormat _currencyFormat;
  late String _labelText;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: '0.00');
    _currencyFormat = NumberFormat.currency(decimalDigits: 2, symbol: '');
    _labelText = widget.labelText ?? 'Monto';
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        border: const OutlineInputBorder(
<<<<<<< HEAD
            borderRadius: BorderRadius.all(Radius.circular(10))),
        hintText: '0.00',
        labelText: _labelText,
=======
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        hintText: '0.00',
        labelText: widget
            .labelText, // Utiliza el valor proporcionado en el constructor
>>>>>>> 19a980dbe31c4065349feb9e1a43bd41ef6772d7
        prefixIcon: const Icon(Icons.attach_money),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?(\d{0,2})?')),
      ],
      onChanged: (value) {
        setState(() {
          if (value.isEmpty) return;

          final numericValue = value.replaceAll(RegExp(r'[^\d.]'), '');

          try {
            final double parsedValue = double.parse(numericValue);
            _controller.value = TextEditingValue(
              text: _currencyFormat.format(parsedValue),
              selection: TextSelection.collapsed(
                  offset: _controller.value.selection.baseOffset),
            );
          } catch (e) {
            // Handle parsing errors if necessary
          }
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Este campo es obligatorio';
        }
        final numericValue = value.replaceAll(RegExp(r'[^\d.]'), '');
        try {
          final double parsedValue = double.parse(numericValue);
          if (parsedValue < 0) {
            return 'No se permiten valores negativos';
          }
        } catch (e) {
          return 'Valor no válido';
        }
        return null;
      },
    );
  }
}
