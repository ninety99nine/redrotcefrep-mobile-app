import 'package:bonako_demo/core/utils/dialer.dart';
import 'package:flutter/material.dart';

class PhoneIconButton extends StatelessWidget {
  
  final String number;

  const PhoneIconButton({
    Key? key,
    required this.number
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
        onTap: () {
          DialerUtility.dial(number: number);
        },
        child: const Material(
          color: Color.fromARGB(0, 15, 10, 10),
          child: Padding(
            padding: EdgeInsets.all(4.0),
            child: Icon(Icons.phone, color: Colors.teal),
          ),
        ),
      ),
    );
  }
}