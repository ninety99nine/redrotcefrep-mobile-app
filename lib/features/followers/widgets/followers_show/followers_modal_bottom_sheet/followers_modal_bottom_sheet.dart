import '../../../../../core/shared_widgets/bottom_modal_sheet/custom_bottom_modal_sheet.dart';
import '../../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../../stores/models/shoppable_store.dart';
import 'package:flutter/material.dart';
import '../followers_content.dart';

class FollowersModalBottomSheet extends StatefulWidget {
  
  final ShoppableStore store;

  const FollowersModalBottomSheet({
    super.key,
    required this.store
  });

  @override
  State<FollowersModalBottomSheet> createState() => _FollowersModalBottomSheetState();
}

class _FollowersModalBottomSheetState extends State<FollowersModalBottomSheet> {

  ShoppableStore get store => widget.store;
  String get totalFollowers => widget.store.followersCount!.toString();
  String get totalFollowersText => widget.store.followersCount == 1 ? 'Follower' : 'Followers';

  @override
  Widget build(BuildContext context) {
    return CustomBottomModalSheet(
      /// Trigger to open the bottom modal sheet
      trigger: CustomBodyText([totalFollowers, totalFollowersText]),
      /// Content of the bottom modal sheet
      content: FollowersContent(
        store: store,
      ),
    );
  }
}