import 'package:perfect_order/features/user/widgets/user_profile/update_user_profile/update_user_profile_modal_bottom_sheet/update_user_profile_modal_bottom_sheet.dart';
import '../../../../../core/shared_widgets/text/custom_title_medium_text.dart';
import '../../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../../../core/shared_models/user.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';

class UserProfile extends StatefulWidget {

  final User user;
  final Function(User)? onUpdatedUser;

  const UserProfile({
    super.key,
    required this.user,
    this.onUpdatedUser,
  });

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {

  late User user = widget.user;
  String get name => user.attributes.name;
  Function(User)? get onUpdatedUser => widget.onUpdatedUser;
  String get mobileNumber => user.mobileNumber!.withoutExtension;

  @override
  Widget build(BuildContext context) {

    return UpdateUserProfileModalBottomSheet(
      user: user,
      onUpdatedUser: onUpdatedUser,
      trigger: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
      
          /// Profile Information
          Expanded(
            child: Row(
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
    
                    Row(
                      children: [
                  
                        /// Mobile Number
                        CustomBodyText(mobileNumber, lightShade: true,),

                        if(user.createdAt != null) ...[
                  
                          /// Spacer
                          const SizedBox(width: 4),
                        
                          /// Joined Date
                          CustomBodyText('Joined ${timeago.format(user.createdAt!)}', lightShade: true),

                        ]
    
                      ],
                    ),
    
                  ],
                
                ),
              
              ],
            ),
          ),
    
          /// Edit Icon
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(Icons.mode_edit_outlined, size: 20, color: Colors.grey.shade400),
          ),
      
        ],
      ),
    );
  }
}