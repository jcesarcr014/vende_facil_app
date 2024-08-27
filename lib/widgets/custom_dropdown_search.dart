import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

class CustomDropdownSearch<T> extends StatelessWidget {
  final List<T> items;
  final T? selectedItem;
  final String labelText;
  final ValueChanged<T?> onChanged;
  final String Function(T) itemAsString;

  const CustomDropdownSearch({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.onChanged,
    required this.labelText,
    required this.itemAsString,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<T>(
      items: items,
      selectedItem: selectedItem,
      onChanged: onChanged,
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
        ),
      ),
      dropdownBuilder: (context, selectedItem) {
        return Text(
          selectedItem != null ? itemAsString(selectedItem) : "Seleccionar $labelText",
          style: const TextStyle(fontSize: 16),
        );
      },
      popupProps: PopupProps.menu(
        //constraints: const BoxConstraints(maxHeight: 30),
        fit: FlexFit.loose,
        itemBuilder: (context, item, isSelected) {
          return ListTile(
            title: Text(itemAsString(item)),
          );
        },
      ),
    );
  }
}