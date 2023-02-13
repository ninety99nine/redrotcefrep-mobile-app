import 'package:bonako_demo/core/shared_models/mobile_number.dart';
import 'package:bonako_demo/core/shared_models/user.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:flutter/material.dart';

class FriendItem extends StatelessWidget {
  
  final User user;
  final Function(User) onRemoveFriends;

  const FriendItem({
    super.key, 
    required this.user,
    required this.onRemoveFriends,
  });

  int get id => user.id;
  String get name => user.attributes.name;
  MobileNumber get mobileNumber => user.mobileNumber!;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
      
              /// Name
              CustomTitleSmallText(name),
      
              /// Spacer
              const SizedBox(height: 4,),
      
              /// Mobile Number
              CustomBodyText(mobileNumber.withoutExtension, lightShade: true),
              
            ],
          ),
      
          /// Remove Icon
          IconButton(
            icon: Icon(Icons.delete_rounded, size: 28, color: Colors.red.shade500,),
            onPressed: () => onRemoveFriends(user)
          )
      
        ],
      ),
    );
  }
}