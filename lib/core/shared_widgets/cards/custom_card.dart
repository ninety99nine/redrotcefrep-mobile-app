

import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {

  final EdgeInsets padding;

  const CustomCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: padding,
        child: child
      )
    );
  }
}