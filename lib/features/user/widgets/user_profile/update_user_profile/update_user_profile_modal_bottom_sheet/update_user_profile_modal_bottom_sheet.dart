import 'package:bonako_demo/core/shared_models/user.dart';
import 'package:bonako_demo/core/shared_widgets/bottom_modal_sheet/custom_bottom_modal_sheet.dart';
import 'package:bonako_demo/features/user/widgets/user_profile/update_user_profile/update_user_profile_content.dart';
import 'package:flutter/material.dart';

class UpdateUserProfileModalBottomSheet extends StatefulWidget {

  final User user;
  final Widget? trigger;
  final Function(User)? onUpdatedUser;

  const UpdateUserProfileModalBottomSheet({
    super.key,
    this.trigger,
    this.onUpdatedUser,
    required this.user,
  });

  @override
  State<UpdateUserProfileModalBottomSheet> createState() => UpdateUserProfileModalBottomSheetState();
}

class UpdateUserProfileModalBottomSheetState extends State<UpdateUserProfileModalBottomSheet> {

  User get user => widget.user;
  Widget? get trigger => widget.trigger;
  Function(User)? get onUpdatedUser => widget.onUpdatedUser;

  Widget get _trigger {

    Widget defaultTrigger = Icon(Icons.mode_edit_outlined, size: 20, color: Colors.grey.shade400);

    return trigger == null ? defaultTrigger : trigger!;

  }

  @override
  Widget build(BuildContext context) {
    return CustomBottomModalSheet(
      /// Trigger to open the bottom modal sheet
      trigger: _trigger,
      /// Content of the bottom modal sheet
      content: UpdateUserProfileContent(
        user: user,
        onUpdatedUser: onUpdatedUser
      ),
    );
  }
}