import 'package:flutter/material.dart';

class EditIconButton extends StatelessWidget {
  
  final double? size;
  final Function()? onTap;

  const EditIconButton({
    Key? key,
    this.size,
    required this.onTap
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.transparent),
      ),
      child: InkWell(
        highlightColor: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(50),
        onTap: onTap,
        child: Material(
          color: const Color.fromARGB(0, 15, 10, 10),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Icon(Icons.mode_edit_outline_outlined, size: size, color: Colors.grey.shade400,),
          ),
        ),
      ),
    );
  }
}