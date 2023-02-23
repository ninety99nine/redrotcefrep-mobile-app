import '../../../../core/shared_widgets/text/custom_body_text.dart';
import 'package:flutter/material.dart';

class TeamMemberInvitationStatus extends StatelessWidget {
  
  final String dotPlacement;
  final String teamMemberStatus;

  const TeamMemberInvitationStatus({
    super.key,
    this.dotPlacement = 'right',
    required this.teamMemberStatus,
  });

  Color get statusColor {

    final String teamMemberStatus = this.teamMemberStatus.toLowerCase();

    /// If this is a user joined
    if(teamMemberStatus == 'joined') {
      
      return Colors.green;

    /// If this is a user left
    }else if(teamMemberStatus == 'left') {
      
      return Colors.red;

    /// If this is a user is invited
    }else {
      
      return Colors.orange;

    }

  }

  Widget get dotWidget {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: statusColor,
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
        CustomBodyText(teamMemberStatus),
        if(dotPlacement == 'right') ...[
          const SizedBox(width: 8,),
          dotWidget,
        ],
      ],
    );
  }
}