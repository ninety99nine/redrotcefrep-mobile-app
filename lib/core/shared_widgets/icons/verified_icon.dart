import 'package:flutter/material.dart';

class VerifiedIcon extends StatelessWidget {

  final double? size;
  final bool verified;

  const VerifiedIcon({super.key, this.size, required this.verified});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.verified, size: size, color: verified ? Theme.of(context).primaryColor : Colors.grey.shade200)
;
  }
}