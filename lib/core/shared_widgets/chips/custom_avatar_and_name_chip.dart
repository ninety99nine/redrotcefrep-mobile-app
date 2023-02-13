import 'package:flutter/material.dart';

class CustomAvatarAndNameChip extends StatelessWidget {
  
  final String name;

  const CustomAvatarAndNameChip({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: const CircleAvatar(
        child: Icon(Icons.person, size: 16,),
      ),
      labelStyle: TextStyle(color: Theme.of(context).primaryColor),
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
      label: Text(name)
    );
  }
}
