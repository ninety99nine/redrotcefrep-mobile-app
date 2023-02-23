import '../../../../core/shared_widgets/text/custom_body_text.dart';
import 'package:flutter/material.dart';

class FollowerInvitationStatus extends StatelessWidget {
  
  final String dotPlacement;
  final String followerStatus;

  const FollowerInvitationStatus({
    super.key,
    this.dotPlacement = 'right',
    required this.followerStatus,
  });

  Color get statusColor {

    final String followerStatus = this.followerStatus.toLowerCase();

    /// If this is a user following
    if(followerStatus == 'following') {
      
      return Colors.green;

    /// If this is a user unfollowed
    }else if(followerStatus == 'unfollowed') {
      
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
        CustomBodyText(followerStatus),
        if(dotPlacement == 'right') ...[
          const SizedBox(width: 8,),
          dotWidget,
        ],
      ],
    );
  }
}