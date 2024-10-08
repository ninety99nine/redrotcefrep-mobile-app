import 'package:perfect_order/core/shared_widgets/chips/custom_choice_chip.dart';
import 'package:perfect_order/core/shared_widgets/text/custom_body_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddOrCloseButton extends StatefulWidget {
  
  final bool isAdding;
  final Function onTap;

  const AddOrCloseButton({
    super.key,
    required this.onTap,
    required this.isAdding,
  });

  @override
  State<AddOrCloseButton> createState() => _AddOrCloseButtonState();
}

class _AddOrCloseButtonState extends State<AddOrCloseButton> {

  bool get isAdding => widget.isAdding;
  Function get onTap => widget.onTap;
  
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      duration: const Duration(milliseconds: 500),
      child: CustomChoiceChip(
        key: ValueKey(widget.isAdding),
        onSelected: (_) => onTap(),
        selected: false,
        labelWidget: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.isAdding ? Icons.add_circle : Icons.remove_circle, color: Colors.grey.shade400,),
              const SizedBox(width: 4,),
              CustomBodyText(widget.isAdding ? 'Add' : 'Close'),
            ],
          ),
        )
    );
  }
}