import '../../../../core/shared_widgets/text/custom_title_small_text.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../models/followers_invitations.dart';
import 'follower_invitation_status.dart';
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
                existingUser: existingUser
              );
            }).toList(),

            /// List the existing users already invited
            ...existingUsersAlreadyInvited.existingUsers.map((existingUser) {
              return ExistingUserItem(
                existingUser: existingUser
              );
            }).toList(),

            /// List the non-existing users we just invited
            ...nonExistingUsersInvited.nonExistingUsers.map((nonExistingUser) {
              return NonExistingUserItem(
                nonExistingUser: nonExistingUser
              );
            }).toList(),

            /// List the non-existing users already invited
            ...nonExistingUsersAlreadyInvited.nonExistingUsers.map((nonExistingUser) {
              return NonExistingUserItem(
                nonExistingUser: nonExistingUser
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
  
  final ExistingUser existingUser;

  const ExistingUserItem({
    super.key,
    required this.existingUser
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
            children: [
              CustomTitleSmallText(existingUser.name),
              const SizedBox(height: 4,),
              CustomBodyText(existingUser.mobileNumber.withoutExtension, lightShade: true)
            ],
          ),
          FollowerInvitationStatus(
            followerStatus: existingUser.followerStatus
          )
        ],
      ),
    );
  }
}

class NonExistingUserItem extends StatelessWidget {
  
  final NonExistingUser nonExistingUser;

  const NonExistingUserItem({
    super.key,
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
          FollowerInvitationStatus(
            followerStatus: nonExistingUser.followerStatus
          )
        ],
      ),
    );
  }
}