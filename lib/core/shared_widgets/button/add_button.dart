import 'package:perfect_order/core/shared_widgets/chips/custom_choice_chip.dart';
import 'package:perfect_order/core/shared_widgets/text/custom_body_text.dart';
import 'package:flutter/material.dart';

class AddButton extends StatefulWidget {
  
  final bool visible;
  final Function onTap;

  const AddButton({
    super.key,
    required this.onTap,
    this.visible = true,
  });

  @override
  State<AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<AddButton> {

  bool get visible => widget.visible;
  Function get onTap => widget.onTap;
  
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      duration: const Duration(milliseconds: 500),
      child: widget.visible ? CustomChoiceChip(
      onSelected: (_) => onTap(),
      selected: false,
      labelWidget: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_circle, color: Colors.grey.shade400,),
            const SizedBox(width: 4,),
            const CustomBodyText('Add'),
          ],
        ),
      ) : null,
    );
  }
}