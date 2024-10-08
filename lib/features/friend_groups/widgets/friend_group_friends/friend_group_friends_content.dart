import 'package:perfect_order/features/friend_groups/widgets/friend_group_friends/friend_group_friends_page/friend_group_friends_page.dart';
import 'package:perfect_order/features/friend_groups/widgets/friend_group_friends/friend_group_member_filters.dart';
import '../../../../core/shared_widgets/button/custom_elevated_button.dart';
import '../../../../core/shared_widgets/text/custom_title_medium_text.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import 'friend_group_friends_in_vertical_infinite_scroll.dart';
import '../../models/friend_group.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FriendGroupFriendsContent extends StatefulWidget {
  
  final bool showingFullPage;
  final FriendGroup friendGroup;
  final Function()? onInvitedMembers;
  final Function()? onRemovedMembers;
  final String? friendGroupMemberFilter;

  const FriendGroupFriendsContent({
    super.key,
    this.onInvitedMembers,
    this.onRemovedMembers,
    required this.friendGroup,
    this.friendGroupMemberFilter,
    this.showingFullPage = false
  });

  @override
  State<FriendGroupFriendsContent> createState() => _FriendGroupFriendsContentState();
}

class _FriendGroupFriendsContentState extends State<FriendGroupFriendsContent> {

  String friendGroupMemberFilter = 'All';
  double get topPadding => showingFullPage ? 32 : 0;
  FriendGroup get friendGroup => widget.friendGroup;
  bool get showingFullPage => widget.showingFullPage;
  Function()? get onInvitedMembers => widget.onInvitedMembers;
  Function()? get onRemovedMembers => widget.onRemovedMembers;
  
  /// This allows us to access the state of FriendGroupMemberFilters widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  late GlobalKey<FriendGroupMemberFiltersState>? _friendGroupMemberFiltersState;

  String get title {
    return 'Group Friends';
  }

  String get subtitle {
    return 'See friends added to this group';
  }

  @override
  void initState() {

    super.initState();

    /// If the review filter is provided
    if(widget.friendGroupMemberFilter != null) {
      
      /// Set the provided review filter
      friendGroupMemberFilter = widget.friendGroupMemberFilter!;

    }

    /// Set the "_friendGroupMemberFiltersState" so that we can access the ReviewFilters widget state
    _friendGroupMemberFiltersState = GlobalKey<FriendGroupMemberFiltersState>();

  }

  /// Content to show based on the specified view
  Widget get content {

    /// Show friends view
    return FriendGroupFriendsInVerticalListViewInfiniteScroll(
      friendGroup: friendGroup,
      onRemovedMembers: onRemovedMembers,
      onInvitedMembers: onInvitedMembers,
      friendGroupMemberFilter: friendGroupMemberFilter,
    );

  }

  /// Floating action button widget
  Widget get floatingActionButton {

    return CustomElevatedButton(
      'Add Friends',
      onPressed: floatingActionButtonOnPressed,
    );

  }

  /// Action to be called when the floating action button is pressed
  void floatingActionButtonOnPressed() {

  }

  /// Called when the friend group member filter has been changed,
  /// such as changing from "All" to "Admins"
  void onSelectedFriendGroupMemberFilter(String friendGroupMemberFilter) {
    setState(() => this.friendGroupMemberFilter = friendGroupMemberFilter);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              
              /// Wrap Padding around the following:
              /// Title, Subtitle
              Padding(
                padding: EdgeInsets.only(top: 20 + topPadding, left: 32, bottom: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              
                    /// Title
                    CustomTitleMediumText(title, padding: const EdgeInsets.only(bottom: 8),),
                    
                    /// Subtitle
                    Align(
                      key: ValueKey(subtitle),
                      alignment: Alignment.centerLeft,
                      child: CustomBodyText(subtitle),
                    ),

                    //  Filters
                    FriendGroupMemberFilters(
                      friendGroup: friendGroup,
                      key: _friendGroupMemberFiltersState,
                      friendGroupMemberFilter: friendGroupMemberFilter,
                      onSelectedFriendGroupMemberFilter: onSelectedFriendGroupMemberFilter
                    ),
                    
                  ],
                ),
              ),
          
              /// Content
              Expanded(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  alignment: Alignment.topCenter,
                  width: double.infinity,
                  color: Colors.white,
                  child: content,
                ),
              )
          
            ],
          ),
  
          /// Expand Icon
          if(!showingFullPage) Positioned(
            top: 8,
            right: 50,
            child: IconButton(
              icon: const Icon(Icons.open_in_full_rounded, size: 24, color: Colors.grey),
              onPressed: () {
                
                /// Close the Modal Bottom Sheet
                Get.back();
                
                /// Navigate to the page
                Get.toNamed(FriendGroupFriendsPage.routeName);
              
              }
            ),
          ),
  
          /// Cancel Icon
          Positioned(
            right: 10,
            top: 8 + topPadding,
            child: IconButton(
              icon: Icon(Icons.cancel, size: 28, color: Theme.of(context).primaryColor,),
              onPressed: () => Get.back()
            ),
          ),
  
          /// Floating Button (show if provided)
          /*
          AnimatedPositioned(
            right: 10,
            top: 112 + topPadding,
            duration: const Duration(milliseconds: 500),
            child: floatingActionButton,
          )
          */
        ],
      ),
    );
  }
}