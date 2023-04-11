import 'package:flutter/material.dart';

class CustomSwitch extends StatelessWidget {
  
  final bool value;
  final void Function(bool)? onChanged;

  const CustomSwitch({
    super.key,
    this.onChanged,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeColor: Colors.green,
    );
  }
}