import '../../../../friend_groups/models/friend_group.dart';
import '../../../enums/friend_group_enums.dart';
import 'package:flutter/material.dart';
import '../friend_groups_content.dart';

class FriendGroupsPage extends StatefulWidget {

  static const routeName = 'FriendGroupsPage';

  final Purpose purpose;
  final bool enableBulkSelection;
  final Function(List<FriendGroup>)? onSelectedFriendGroups;

  const FriendGroupsPage({
    super.key,
    required this.purpose,
    this.onSelectedFriendGroups,
    required this.enableBulkSelection,
  });

  @override
  State<FriendGroupsPage> createState() => _FriendGroupsPageState();
}

class _FriendGroupsPageState extends State<FriendGroupsPage> {

  Purpose get purpose => widget.purpose;
  bool get enableBulkSelection => widget.enableBulkSelection;

  /// Called when the friend groups are selected 
  void onSelectedFriendGroups(List<FriendGroup> friendGroups) {

    if(widget.onSelectedFriendGroups != null) {
        
      /// Notify parent on selected friends
      widget.onSelectedFriendGroups!(friendGroups);

    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FriendGroupsContent(
        purpose: purpose,
        showingFullPage: true,
        enableBulkSelection: enableBulkSelection,
        onSelectedFriendGroups: onSelectedFriendGroups,
      ),
    );
  }
}