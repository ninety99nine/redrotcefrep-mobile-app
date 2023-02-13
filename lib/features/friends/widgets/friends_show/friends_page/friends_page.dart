import '../../../../friend_groups/models/friend_group.dart';
import '../../../../../core/shared_models/user.dart';
import '../../../enums/friend_enums.dart';
import 'package:flutter/material.dart';
import '../friends_content.dart';

class FriendsPage extends StatefulWidget {

  static const routeName = 'FriendsPage';

  final Purpose purpose;
  final Function(List<User>)? onSelectedFriends;
  final Function(List<User>)? onDoneSelectingFriends;
  final Function(List<FriendGroup>)? onSelectedFriendGroups;

  const FriendsPage({
    super.key,
    required this.purpose,
    this.onSelectedFriends,
    this.onDoneSelectingFriends,
    this.onSelectedFriendGroups,
  });

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {

  Purpose get purpose => widget.purpose;

  /// Called when the friends are selected on each interaction
  void onSelectedFriends(List<User> friends) {

    if(widget.onSelectedFriends != null) {

      /// Notify parent on selected friends
      widget.onSelectedFriends!(friends);

    }

  }

  /// Called when the user is done selecting friends
  void onDoneSelectingFriends(List<User> friends) {

    if(widget.onDoneSelectingFriends != null) {

      /// Notify parent on selected friends
      widget.onDoneSelectingFriends!(friends);

    }

  }

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
      body: FriendsContent(
        purpose: purpose,
        showingFullPage: true,
        onSelectedFriends: onSelectedFriends,
        onDoneSelectingFriends: onDoneSelectingFriends,
        onSelectedFriendGroups: onSelectedFriendGroups,
      ),
    );
  }
}