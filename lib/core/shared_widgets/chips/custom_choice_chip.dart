import 'package:flutter/material.dart';

class CustomChoiceChip extends StatelessWidget {
  
  final String label;
  final bool selected;
  final Widget? labelWidget;
  final Color? selectedColor;
  final Color? disabledColor;
  final Color? backgroundColor;
  final void Function(bool)? onSelected;

  const CustomChoiceChip({
    super.key,
    this.label = '',
    this.onSelected,
    this.labelWidget,
    this.selectedColor,
    this.disabledColor,
    this.backgroundColor,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      labelStyle: TextStyle(color: selected ? Colors.white : null, fontWeight: FontWeight.bold),
      selectedColor: selectedColor ?? Theme.of(context).primaryColor,
      backgroundColor: backgroundColor ?? Colors.grey.shade200,
      label: labelWidget ?? Text(label), 
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      disabledColor: Colors.grey.shade200,
      onSelected: onSelected,
      selected: selected,
    );
  }
}