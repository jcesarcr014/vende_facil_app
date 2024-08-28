import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

class CustomDropdownSearch extends StatefulWidget {
  final List<String> items;
  final String? selectedItem;
  final String labelText;
  final ValueChanged<String?> onChanged;
  final String? emptyMessage;

  const CustomDropdownSearch({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.onChanged,
    required this.labelText,
    this.emptyMessage,
  });

  @override
  State<CustomDropdownSearch> createState() => _CustomDropdownSearchState();
}

class _CustomDropdownSearchState extends State<CustomDropdownSearch> {

  double getDropDownSize() {
    if (widget.items.isEmpty) return 100;
    return 225;
  }

  @override
  Widget build(BuildContext context) {
    final double dropDownBoxSize = getDropDownSize();

    return DropdownSearch<String>(
      items: widget.items,
      selectedItem: widget.selectedItem,
      onChanged: widget.onChanged,
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: widget.labelText,
          border: const OutlineInputBorder(),
        ),
      ),
      dropdownBuilder: (context, selectedItem) {
        return Text(
          selectedItem ?? "Seleccionar ${widget.labelText}",
          style: const TextStyle(fontSize: 16),
        );
      },
      popupProps: PopupProps.menu(
        constraints: BoxConstraints(
          maxHeight: dropDownBoxSize,
        ),
        fit: FlexFit.loose,
        itemBuilder: (context, item, isSelected) {
          return ListTile(
            title: Text(item),
          );
        },
        emptyBuilder: (context, searchEntry) => Center(
          child: Text(
            widget.emptyMessage ?? 'No se encontraron datos',
            style: const TextStyle(fontSize: 16),
          ),
        ),
        showSearchBox: true,
        isFilterOnline: true, 
      ),
    );
  }
}