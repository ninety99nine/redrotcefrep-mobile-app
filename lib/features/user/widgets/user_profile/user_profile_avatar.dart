import '../../../../../core/shared_widgets/text/custom_title_medium_text.dart';
import '../../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../../../core/shared_models/user.dart';
import 'package:flutter/material.dart';

class UserProfile extends StatefulWidget {

  final User user;

  const UserProfile({
    super.key,
    required this.user
  });

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {

  User get user => widget.user;
  String get name => user.attributes.name;
  String get mobileNumber => user.mobileNumber!.withoutExtension;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
    
            /// Avatar
            CircleAvatar(
              backgroundColor: Colors.grey.shade200,
              child: Icon(Icons.person, size: 24, color: Colors.grey.shade400),
            ),
    
            /// Spacer
            const SizedBox(width: 16),
    
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
    
                /// Name
                CustomTitleMediumText(name),
    
                /// Spacer
                const SizedBox(height: 4),
    
                /// Mobile Number
                CustomBodyText(mobileNumber, lightShade: true,),
              ],

            )
    
          ],
        ),
      ],
    );
  }
}