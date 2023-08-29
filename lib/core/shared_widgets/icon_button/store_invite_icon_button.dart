import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';

class StoreInviteIconButton extends StatelessWidget {
  
  final double? size;
  final Function()? onTap;

  const StoreInviteIconButton({
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
        borderRadius: BorderRadius.circular(50),
        onTap: onTap,
        child: Material(
          color: const Color.fromARGB(0, 15, 10, 10),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(FontAwesomeIcons.store, size: size, color: Colors.grey.shade400,),
          ),
        ),
      ),
    );
  }
}