// ignore_for_file: file_names
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';

// class InputFieldMoney extends StatefulWidget {
//   final TextEditingController? controller;
//   final String labelText;
//   final void Function(dynamic value)? onChanged; // Cambio aquí

//   // ignore: use_super_parameters
//   const InputFieldMoney(
//       {Key? key,
//       this.controller,
//       this.labelText = 'Monto',
//       this.onChanged}) // Cambio aquí
//       : super(key: key); // Cambio aquí

//   @override
//   State<InputFieldMoney> createState() => _InputFieldMoneyState();
// }

// class _InputFieldMoneyState extends State<InputFieldMoney> {
//   late TextEditingController _controller;
//   late NumberFormat _currencyFormat;

//   @override
//   void initState() {
//     super.initState();
//     _controller = widget.controller ?? TextEditingController(text: '0.00');
//     _currencyFormat = NumberFormat.currency(decimalDigits: 2, symbol: '');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       controller: _controller,
//       keyboardType: const TextInputType.numberWithOptions(decimal: true),
//       decoration: InputDecoration(
//         border: const OutlineInputBorder(
//           borderRadius: BorderRadius.all(Radius.circular(10)),
//         ),
//         hintText: '0.00',
//         labelText: widget.labelText,
//         prefixIcon: const Icon(Icons.attach_money),
//       ),
//       onChanged: (value) {
//         setState(() {
//           if (widget.onChanged != null) {
//             widget.onChanged!(value); // Cambio aquí
//           }
//           if (value.isEmpty) return;
//           final numericValue = value.replaceAll(RegExp(r'[^\d.]'), '');

//           try {
//             final double parsedValue = double.parse(numericValue);
//             _controller.value = TextEditingValue(
//               text: _currencyFormat.format(parsedValue),
//               selection: TextSelection.collapsed(
//                   offset: _controller.value.selection.baseOffset),
//             );
//           } catch (e) {
//             // Handle parsing errors if necessary
//           }
//         });
//       },
//       validator: (value) {
//         if (value == null || value.isEmpty) {
//           return 'Este campo es obligatorio';
//         }
//         final numericValue = value.replaceAll(RegExp(r'[^\d.]'), '');
//         try {
//           final double parsedValue = double.parse(numericValue);
//           if (parsedValue < 0) {
//             return 'No se permiten valores negativos';
//           }
//         } catch (e) {
//           return 'Valor no válido';
//         }
//         return null;
//       },
//     );
//   }
// }
