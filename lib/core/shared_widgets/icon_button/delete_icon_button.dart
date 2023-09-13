import 'package:flutter/material.dart';

class DeleteIconButton extends StatelessWidget {
  
  final double? size;
  final Function()? onTap;

  const DeleteIconButton({
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
            child: Icon(Icons.delete_outline_rounded, size: size, color: Colors.red.shade400,),
          ),
        ),
      ),
    );
  }
}