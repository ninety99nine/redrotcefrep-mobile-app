import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ContactAvatar extends StatelessWidget {

  final Contact contact;

  const ContactAvatar({required this.contact, super.key});

  Uint8List? get photo => contact.photo;
  Uint8List? get thumbnail => contact.thumbnail;
  
  Widget? get child {

    if(photo == null && thumbnail == null) {

      return const Icon(Icons.person);
    
    }else{
    
      return null;
    
    }
    
  }
  
  MemoryImage? get backgroundImage {

    if(photo != null) {

      return MemoryImage(photo!);
    
    }else if(thumbnail != null) {
    
      return MemoryImage(thumbnail!);
    
    }else{
    
      return null;
    
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundImage: backgroundImage,
      child: child
    );
  }
}