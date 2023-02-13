import '../../../../../core/shared_widgets/bottom_modal_sheet/custom_bottom_modal_sheet.dart';
import '../../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../../stores/models/shoppable_store.dart';
import 'package:flutter/material.dart';
import '../team_members_content.dart';

class TeamMembersModalBottomSheet extends StatefulWidget {
  
  final ShoppableStore store;

  const TeamMembersModalBottomSheet({
    super.key,
    required this.store
  });

  @override
  State<TeamMembersModalBottomSheet> createState() => _TeamMembersModalBottomSheetState();
}

class _TeamMembersModalBottomSheetState extends State<TeamMembersModalBottomSheet> {

  ShoppableStore get store => widget.store;
  String get totalTeamMembers => widget.store.teamMembersCount!.toString();
  String get totalTeamMembersText => widget.store.teamMembersCount == 1 ? 'Team Member' : 'Team Members';

  @override
  Widget build(BuildContext context) {
    return CustomBottomModalSheet(
      /// Trigger to open the bottom modal sheet
      trigger: CustomBodyText([totalTeamMembers, totalTeamMembersText]),
      /// Content of the bottom modal sheet
      content: TeamMembersContent(
        store: store
      ),
    );
  }
}