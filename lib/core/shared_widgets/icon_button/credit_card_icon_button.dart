import 'package:flutter/material.dart';

class CreditCardIconButton extends StatelessWidget {
  
  final Function()? onTap;

  const CreditCardIconButton({
    Key? key,
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
        highlightColor: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(50),
        onTap: onTap,
        child: Material(
          color: const Color.fromARGB(0, 15, 10, 10),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Icon(Icons.credit_card_rounded, color: Colors.teal),
          ),
        ),
      ),
    );
  }
}