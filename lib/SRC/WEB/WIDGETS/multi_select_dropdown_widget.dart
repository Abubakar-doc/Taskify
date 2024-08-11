import 'package:flutter/material.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';

class GenericMultiSelectDropdown<T> extends StatelessWidget {
  final MultiSelectController<T> controller;
  final List<ValueItem<T>> options;
  final void Function(List<ValueItem<T>> options)? onOptionSelected;
  final void Function(int index, ValueItem<T> option)? onOptionRemoved;
  final TextStyle? optionTextStyle;
  final Color? selectedOptionColor;
  final Color? unselectedOptionColor;
  final TextStyle? selectedOptionStyle;
  final TextStyle? unselectedOptionStyle;
  final Color? dropdownBackgroundColor;
  final double dropdownMargin;
  final double dropdownBorderRadius;
  final bool searchEnabled;
  final String hintText;

  const GenericMultiSelectDropdown({
    super.key,
    required this.controller,
    required this.options,
    this.onOptionSelected,
    this.onOptionRemoved,
    this.optionTextStyle,
    this.selectedOptionColor,
    this.unselectedOptionColor,
    this.selectedOptionStyle,
    this.unselectedOptionStyle,
    this.dropdownBackgroundColor,
    this.dropdownMargin = 2,
    this.dropdownBorderRadius = 10,
    this.searchEnabled = true,
    required this.hintText
  });


  @override
  Widget build(BuildContext context) {
    return MultiSelectDropDown<T>(
      controller: controller,
      clearIcon: const Icon(Icons.clear),
      onOptionSelected: onOptionSelected,
      hint: hintText,
      hintStyle: const TextStyle(
          fontSize: 17,
          color: Colors.grey
      ),
      options: options,
      searchEnabled: searchEnabled,
      fieldBackgroundColor: const Color(0xFF2F353E),
      borderColor: const Color(0xFF938F99),
      borderWidth: 1,
      dropdownBackgroundColor: dropdownBackgroundColor ?? const Color(0xFF141218),
      singleSelectItemStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      chipConfig: const ChipConfig(
        wrapType: WrapType.wrap,
        backgroundColor: Color(0xFF2F353E),
      ),
      optionTextStyle: optionTextStyle ?? const TextStyle(fontSize: 16),
      selectedOptionIcon: const Icon(Icons.check_circle, color: Color(0xffa9dfd8)),
      dropdownMargin: dropdownMargin,
      dropdownBorderRadius: dropdownBorderRadius,
      onOptionRemoved: onOptionRemoved,
      optionBuilder: (context, valueItem, isSelected) {
        return ListTile(
          tileColor: isSelected ? selectedOptionColor ?? const Color(0xFF282631) : unselectedOptionColor,
          title: Text(
            valueItem.label,
            style: isSelected ? selectedOptionStyle ?? const TextStyle(color: Colors.white) : unselectedOptionStyle,
          ),
          subtitle: Text(
            valueItem.value.toString(),
            style: const TextStyle(color: Colors.white),
          ),
          trailing: isSelected
              ? const Icon(Icons.check_circle, color: Color(0xffa9dfd8))
              : const Icon(Icons.radio_button_unchecked, color: Color(0xffa9dfd8)),
        );
      },
    );
  }
}
