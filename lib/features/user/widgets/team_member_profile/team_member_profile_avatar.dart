import '../../../team_members/widgets/team_member_invitations_show/team_member_invitation_status.dart';
import '../../../../../core/shared_widgets/text/custom_title_medium_text.dart';
import '../../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../../../core/shared_models/user.dart';
import 'package:flutter/material.dart';

class TeamMemberProfileAvatar extends StatefulWidget {

  final User user;

  const TeamMemberProfileAvatar({
    super.key,
    required this.user
  });

  @override
  State<TeamMemberProfileAvatar> createState() => _TeamMemberProfileAvatarState();
}

class _TeamMemberProfileAvatarState extends State<TeamMemberProfileAvatar> {

  User get user => widget.user;
  String get name => user.attributes.name;
  String get mobileNumber {
    if(user.mobileNumber != null) {
      
      return user.mobileNumber!.withoutExtension;
    
    }else{

      /// Get the mobile number through the user and store association attribute.
      /// This occurs if this is a Guest user (non-existing user) who was invited 
      /// to join a store as a team member.
      if(user.attributes.userStoreAssociation != null) {
        if(user.attributes.userStoreAssociation!.mobileNumber != null) {
          return user.attributes.userStoreAssociation!.mobileNumber!.withoutExtension;
        }
      }

      return '';
      
    }
  }

  String get teamMemberStatus {
    return user.attributes.userStoreAssociation!.teamMemberStatus!;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
    
            /// Avatar
            const CircleAvatar(
              child: Icon(Icons.person),
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
                
                /// Accepted Invitation Status
                TeamMemberInvitationStatus(
                  teamMemberStatus: teamMemberStatus,
                  dotPlacement: 'left'
                ),
    
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