import '../../../../core/shared_widgets/text/custom_title_small_text.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../models/team_members_invitations.dart';
import 'team_member_invitation_status.dart';
import 'package:flutter/material.dart';

class TeamMemberInvitationsContent extends StatefulWidget {
  
  final TeamMembersInvitations teamMembersInvitations;

  const TeamMemberInvitationsContent({
    super.key,
    required this.teamMembersInvitations,
  });

  @override
  State<TeamMemberInvitationsContent> createState() => _TeamMemberInvitationsContentState();
}

class _TeamMemberInvitationsContentState extends State<TeamMemberInvitationsContent> {

  TeamMembersInvitations get teamMembersInvitations => widget.teamMembersInvitations;
  ExistingUsers get existingUsersInvited => teamMembersInvitations.existingUsersInvited;
  NonExistingUsers get nonExistingUsersInvited => teamMembersInvitations.nonExistingUsersInvited;
  ExistingUsers get existingUsersAlreadyInvited => teamMembersInvitations.existingUsersAlreadyInvited;
  NonExistingUsers get nonExistingUsersAlreadyInvited => teamMembersInvitations.nonExistingUsersAlreadyInvited;
  
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
          TeamMemberInvitationStatus(
            acceptedInvitation: existingUser.acceptedInvitation
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
          TeamMemberInvitationStatus(
            acceptedInvitation: nonExistingUser.acceptedInvitation
          )
        ],
      ),
    );
  }
}