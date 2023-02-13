import '../../../../core/shared_widgets/text/custom_body_text.dart';
import 'package:flutter/material.dart';

class TeamMemberInvitationStatus extends StatelessWidget {
  
  final String acceptedInvitation;
  final String dotPlacement;

  const TeamMemberInvitationStatus({
    super.key,
    this.dotPlacement = 'right',
    required this.acceptedInvitation,
  });

  String get invitationStatus {

    final String acceptedInvitation = this.acceptedInvitation.toLowerCase();

    /// If this is a user accepted the invitation
    if(acceptedInvitation == 'yes') {
      
      return 'Joined team';

    /// If this is a user declined the invitation
    }else if(acceptedInvitation == 'no') {
      
      return 'Left team';

    /// If this is a user hasn't yet accepted or declined
    }else {
      
      return 'Waiting response';

    }

  }

  Color get invitationColor {

    final String acceptedInvitation = this.acceptedInvitation.toLowerCase();

    /// If this is a user accepted the invitation
    if(acceptedInvitation == 'yes') {
      
      return Colors.green;

    /// If this is a user declined the invitation
    }else if(acceptedInvitation == 'no') {
      
      return Colors.red;

    /// If this is a user hasn't yet accepted or declined
    }else {
      
      return Colors.orange;

    }

  }

  Widget get dotWidget {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: invitationColor,
        borderRadius: BorderRadius.circular(4)
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if(dotPlacement == 'left') ...[
          dotWidget,
          const SizedBox(width: 8,),
        ],
        CustomBodyText(invitationStatus),
        if(dotPlacement == 'right') ...[
          const SizedBox(width: 8,),
          dotWidget,
        ],
      ],
    );
  }
}