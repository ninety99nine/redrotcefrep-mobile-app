import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ContactAvatar extends StatelessWidget {

  final Contact contact;

  const ContactAvatar({required this.contact, super.key});

  Uint8List? get photo => contact.photo;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundImage: photo == null ? null : MemoryImage(photo!),
      child: photo == null ? const Icon(Icons.person) : null
    );
  }
}