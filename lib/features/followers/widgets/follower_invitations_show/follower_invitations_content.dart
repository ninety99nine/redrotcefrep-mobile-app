import '../../../../core/shared_widgets/text/custom_title_small_text.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../models/followers_invitations.dart';
import 'package:flutter/material.dart';

class FollowerInvitationsContent extends StatefulWidget {
  
  final FollowersInvitations followersInvitations;

  const FollowerInvitationsContent({
    super.key,
    required this.followersInvitations,
  });

  @override
  State<FollowerInvitationsContent> createState() => _FollowerInvitationsContentState();
}

class _FollowerInvitationsContentState extends State<FollowerInvitationsContent> {

  FollowersInvitations get followersInvitations => widget.followersInvitations;
  ExistingUsers get existingUsersInvited => followersInvitations.existingUsersInvited;
  NonExistingUsers get nonExistingUsersInvited => followersInvitations.nonExistingUsersInvited;
  ExistingUsers get existingUsersAlreadyInvited => followersInvitations.existingUsersAlreadyInvited;
  NonExistingUsers get nonExistingUsersAlreadyInvited => followersInvitations.nonExistingUsersAlreadyInvited;
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 8.0,),
        child: Column(
          children: [

            /// List the existing users we just invited
            ...existingUsersInvited.existingUsers.map((existingUser) {
              return ExistingUserItem(
                existingUser: existingUser,
                alreadyInvited: false
              );
            }).toList(),

            /// List the existing users already invited
            ...existingUsersAlreadyInvited.existingUsers.map((existingUser) {
              return ExistingUserItem(
                existingUser: existingUser,
                alreadyInvited: true
              );
            }).toList(),

            /// List the non-existing users we just invited
            ...nonExistingUsersInvited.nonExistingUsers.map((nonExistingUser) {
              return NonExistingUserItem(
                nonExistingUser: nonExistingUser,
                alreadyInvited: false
              );
            }).toList(),

            /// List the non-existing users already invited
            ...nonExistingUsersAlreadyInvited.nonExistingUsers.map((nonExistingUser) {
              return NonExistingUserItem(
                nonExistingUser: nonExistingUser,
                alreadyInvited: true
              );
            }).toList(),

            const SizedBox(height: 100,)

          ],
        ),
      ),
    );
  }
}

class ExistingUserItem extends StatelessWidget {
  
  final bool alreadyInvited;
  final ExistingUser existingUser;

  const ExistingUserItem({
    super.key,
    required this.existingUser,
    required this.alreadyInvited
  });

  String get acceptedInvitation => existingUser.acceptedInvitation.toLowerCase();

  String get invitationStatus {

    /// If this is a user who is already following
    if(alreadyInvited == true && acceptedInvitation == 'yes') {
      
      return 'Already Following';

    /// If this is a user who was once following but now stopped following
    }else if(alreadyInvited == true && acceptedInvitation == 'no') {
      
      return 'Stopped Following';

    /// If this is a user who has already been invited but hasn't yet accepted or declined
    }else {
      
      return 'Waiting response';

    }

  }

  Color get invitationColor {

    /// If this is a user who is already following
    if(alreadyInvited == true && acceptedInvitation == 'yes') {
      
      return Colors.green;

    /// If this is a user who was once following but now stopped following
    }else if(alreadyInvited == true && acceptedInvitation == 'no') {
      
      return Colors.red;

    /// If this is a user who has already been invited but hasn't yet accepted or declined
    }else {
      
      return Colors.orange;

    }

  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTitleSmallText(existingUser.name),
              const SizedBox(height: 4,),
              CustomBodyText(existingUser.mobileNumber.withoutExtension, lightShade: true)
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomBodyText(invitationStatus),
              const SizedBox(width: 4,),
              Text('•', style: TextStyle(color: invitationColor, fontSize: 40, height: 1)),
            ],
          ),
        ],
      ),
    );
  }
}

class NonExistingUserItem extends StatelessWidget {
  
  final bool alreadyInvited;
  final NonExistingUser nonExistingUser;

  const NonExistingUserItem({
    super.key,
    required this.alreadyInvited,
    required this.nonExistingUser,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTitleSmallText(nonExistingUser.mobileNumber.withoutExtension),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              CustomBodyText('Waiting response'),
              SizedBox(width: 4,),
              Text('•', style: TextStyle(color: Colors.orange, fontSize: 40, height: 1)),
            ],
          ), 
        ],
      ),
    );
  }
}