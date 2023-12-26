import 'package:bonako_demo/features/friend_groups/widgets/create_or_update_friend_group/create_or_update_friend_group_form.dart';

import '../friend_group_create_or_update/friend_group_create_or_update.dart';
import '../../../../core/shared_widgets/button/custom_elevated_button.dart';
import '../../../../core/shared_widgets/text/custom_title_medium_text.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import 'friend_groups_in_vertical_list_view_infinite_scroll.dart';
import '../../repositories/friend_group_repository.dart';
import '../friend_groups_show/friend_group_filters.dart';
import '../../providers/friend_group_provider.dart';
import 'friend_groups_page/friend_groups_page.dart';
import '../../enums/friend_group_enums.dart';
import 'package:provider/provider.dart';
import '../../models/friend_group.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FriendGroupsContent extends StatefulWidget {
  
  final Purpose purpose;
  final bool showingFullPage;
  final bool enableBulkSelection;
  final void Function(FriendGroup)? onCreatedFriendGroup;
  final void Function(FriendGroup)? onUpdatedFriendGroup;
  final void Function(FriendGroup)? onDeletedFriendGroup;
  final Function(List<FriendGroup>)? onSelectedFriendGroups;
  final Function(List<FriendGroup>)? onDoneSelectingFriendGroups;
  

  const FriendGroupsContent({
    super.key,
    required this.purpose,
    this.onCreatedFriendGroup,
    this.onUpdatedFriendGroup,
    this.onDeletedFriendGroup,
    this.onSelectedFriendGroups,
    this.showingFullPage = false,
    this.onDoneSelectingFriendGroups,
    required this.enableBulkSelection,
  });

  @override
  State<FriendGroupsContent> createState() => _FriendGroupsContentState();
}

class _FriendGroupsContentState extends State<FriendGroupsContent> {

  FriendGroup? friendGroup;
  List<FriendGroup> friendGroups = [];
  bool disableFloatingActionButton = false;
  FriendGroupFilter selectedFilter = FriendGroupFilter.groups;
  FriendGroupContentView friendGroupContentView = FriendGroupContentView.viewingFriendGroups;

  Purpose get purpose => widget.purpose;

  double get topPadding => showingFullPage ? 32 : 0;
  bool get showingFullPage => widget.showingFullPage;
  bool get enableBulkSelection => widget.enableBulkSelection;
  bool get hasSelectedFriendGroups => friendGroups.isNotEmpty;
  bool get isViewingAnyGroups => isViewingGroups || isViewingSharedGroups;
  bool get wantsToChooseFriendGroups => purpose == Purpose.chooseFriendGroups;
  bool get hasSelectedGroupsFilter => selectedFilter == FriendGroupFilter.groups;
  bool get wantsToAddStoreToFriendGroups => purpose == Purpose.addStoreToFriendGroups;
  void Function(FriendGroup)? get onCreatedFriendGroup => widget.onCreatedFriendGroup;
  void Function(FriendGroup)? get onUpdatedFriendGroup => widget.onUpdatedFriendGroup;
  void Function(FriendGroup)? get onDeletedFriendGroup => widget.onDeletedFriendGroup;
  bool get hasSelectedSharedGroupsFilter => selectedFilter == FriendGroupFilter.sharedGroups;
  FriendGroupRepository get friendGroupRepository => friendGroupProvider.friendGroupRepository;
  FriendGroupProvider get friendGroupProvider => Provider.of<FriendGroupProvider>(context, listen: false);
  bool get isViewingGroup => hasSelectedGroupsFilter && friendGroupContentView == FriendGroupContentView.viewingFriendGroup;
  bool get isViewingGroups => hasSelectedGroupsFilter && friendGroupContentView == FriendGroupContentView.viewingFriendGroups;
  bool get isViewingSharedGroups => hasSelectedSharedGroupsFilter && friendGroupContentView == FriendGroupContentView.viewingFriendGroups;

  String get title {

    if(isViewingAnyGroups && wantsToAddStoreToFriendGroups) {
      return 'Add To Groups';
    }else if(isViewingGroup && wantsToAddStoreToFriendGroups) {
      return friendGroup!.name;
    }else{
      return 'Groups';
    }

  }

  String get subtitle {

    if(isViewingAnyGroups && wantsToAddStoreToFriendGroups) {
      return 'Select groups to add store';
    }else if(isViewingAnyGroups && wantsToChooseFriendGroups) {
      return 'Select your group';
    }else if(isViewingGroup) {
      return 'Make changes to your group';
    }else{
      return 'Add a new group';
    }

  }

  /// Content to show based on the specified view
  Widget get content {

    /// If we want to view the friend groups content
    if(isViewingAnyGroups) {

      /// Set the filter for the groups that we want to show
      final filter = selectedFilter == FriendGroupFilter.groups ? 'Created' : 'Shared';

      /// Show friend groups view
      return FriendGroupsInVerticalListViewInfiniteScroll(
        filter: filter,
        key: ValueKey(filter),
        onViewFriendGroup: onViewFriendGroup,
        onSelectedFriendGroups: onSelectedFriendGroups,
        onDeletingFriendGroups: onDisableFloatingActionButton,
      );

    /// If we want to view the friend group content
    }else if(isViewingGroup) {

      /// Show friend groups view
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
          child: CreateOrUpdateFriendGroupForm(
            friendGroup: friendGroup!,
            onUpdating: onDisableFloatingActionButton,
            onUpdatedFriendGroup: _onUpdatedFriendGroup,
            onDeletedFriendGroup: _onDeletedFriendGroup,
          ),
        ),
      );

    /// If we want to view the friend group create content
    }else{

      /// Show the friend group create content
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
          child: CreateOrUpdateFriendGroupForm(
            onCreating: onDisableFloatingActionButton,
            onCreatedFriendGroup: _onCreatedFriendGroup
          ),
        ),
      );

    }
    
  }

  /// Floating action button widget
  Widget get floatingActionButton {

    String text = 'Back';
    IconData? prefixIcon = Icons.keyboard_double_arrow_left;

    if(isViewingAnyGroups) {

      prefixIcon = Icons.add;

      if(hasSelectedFriendGroups) {

        text = 'Done';
        prefixIcon = null;

      }else {
        text = 'Add Group';
      }

    }

    return CustomElevatedButton(
      text,
      width: 120,
      prefixIcon: prefixIcon,
      onPressed: floatingActionButtonOnPressed,
    );

  }

  /// Action to be called when the floating action button is pressed
  void floatingActionButtonOnPressed() {

    /// If we should disable the floating action button, then do nothing
    if(disableFloatingActionButton) return; 

    /// If we are done selecting friend groups
    if(hasSelectedFriendGroups) {
              
      /// Close the Modal Bottom Sheet
      onDoneSelectingFriendGroups();

    /// If we are viewing the friend groups content
    }else if(isViewingAnyGroups) {

      /// Change to the friend group create view
      changeGroupContentView(FriendGroupContentView.creatingFriendGroup);

    }else{

      /// Change to show friend groups view
      changeGroupContentView(FriendGroupContentView.viewingFriendGroups);

    }

  }

  /// Close the Modal Bottom Sheet since we are done
  void onDoneSelectingFriendGroups() {

    if(widget.onDoneSelectingFriendGroups != null) {

      /// Notify parent on selected friend groups
      widget.onDoneSelectingFriendGroups!(friendGroups);

    }

    requestUpdateLastSelectedFriendGroups();
    
    Get.back();

  }

  /// Update the date and time of these selected friend groups
  void requestUpdateLastSelectedFriendGroups() {

    if(hasSelectedFriendGroups) {
      friendGroupRepository.updateLastSelectedFriendGroups(
        friendGroups: friendGroups
      );
    }

  }

  /// While waiting for an operation to complete disable the 
  /// floating action button so that it is no longer 
  /// performs any actions when clicked
  void onDisableFloatingActionButton(bool status) => disableFloatingActionButton = status;

  /// Called so that we can show the friend groups
  /// view after creating a friend group
  void _onCreatedFriendGroup(FriendGroup createdFriendGroup) {
    if(onCreatedFriendGroup != null) onCreatedFriendGroup!(createdFriendGroup);
    changeGroupContentView(FriendGroupContentView.viewingFriendGroups);
  }

  /// Called so that we can show the friend groups
  /// view after updating a friend group
  void _onUpdatedFriendGroup(FriendGroup updatedFriendGroup) {
    if(onUpdatedFriendGroup != null) onUpdatedFriendGroup!(updatedFriendGroup);
    changeGroupContentView(FriendGroupContentView.viewingFriendGroups);
  }

  /// Called so that we can show the friend groups
  /// view after deleting a friend group
  void _onDeletedFriendGroup(FriendGroup deletedFriendGroup) {
    if(onDeletedFriendGroup != null) onDeletedFriendGroup!(deletedFriendGroup);
    changeGroupContentView(FriendGroupContentView.viewingFriendGroups);
  }

  /// Called when the friend groups are selected 
  void onSelectedFriendGroups(List<FriendGroup> friendGroups) {
    setState(() => this.friendGroups = friendGroups);

    if(widget.onSelectedFriendGroups != null) {

      /// Notify parent on selected friend groups
      widget.onSelectedFriendGroups!(friendGroups);

    }

    if(enableBulkSelection == false && friendGroups.isNotEmpty) onDoneSelectingFriendGroups();
  }

  /// Called to change the view from viewing multiple friend groups
  /// to viewing one specific friend group
  void onViewFriendGroup(FriendGroup friendGroup) {
    this.friendGroup = friendGroup;
    changeGroupContentView(FriendGroupContentView.viewingFriendGroup);
  }

  /// Called when the primary content view has been changed,
  /// such as changing from "Groups" to "Shared Groups"
  void onSelectedFilter(FriendGroupFilter selectedFilter) {

    /// Reset the selected friends and friend groups
    friendGroups = [];
    friendGroup = null;
      
    /// Reset the initial friend and friend group views
    friendGroupContentView = FriendGroupContentView.viewingFriendGroups;
    
    setState(() => this.selectedFilter = selectedFilter);
  }

  /// Called to change the view to the specified view
  void changeGroupContentView(FriendGroupContentView friendGroupContentView) {
    setState(() => this.friendGroupContentView = friendGroupContentView);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Stack(
        children: [
          AnimatedSwitcher(
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            duration: const Duration(milliseconds: 500),
            child: Column(
              key: ValueKey(friendGroupContentView.name),
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                
                /// Wrap Padding around the following:
                /// Title, Subtitle, Filters
                Padding(
                  padding: EdgeInsets.only(top: 20 + topPadding, left: 32, bottom: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                
                      /// Title
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: CustomTitleMediumText(
                          title, 
                          overflow: TextOverflow.ellipsis, 
                          padding: const EdgeInsets.only(bottom: 8),
                        ),
                      ),
                      
                      /// Subtitle
                      AnimatedSwitcher(
                        switchInCurve: Curves.easeIn,
                        switchOutCurve: Curves.easeOut,
                        duration: const Duration(milliseconds: 500),
                        child: Align(
                          key: ValueKey(subtitle),
                          alignment: Alignment.centerLeft,
                          child: CustomBodyText(subtitle),
                        )
                      ),
                  
                      //  Filter
                      if(isViewingAnyGroups) FriendGroupFilters(
                        selectedFilter: selectedFilter,
                        onSelectedFilter: onSelectedFilter,
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
                Get.toNamed(FriendGroupsPage.routeName);
              
              }
            ),
          ),
  
          /// Cancel Icon
          Positioned(
            right: 10,
            top: 8 + topPadding,
            child: IconButton(
              icon: Icon(Icons.cancel, size: 28, color: Theme.of(context).primaryColor,),
              onPressed: () => Get.back(),
            ),
          ),
  
          /// Floating Button (show if provided)
          AnimatedPositioned(
            right: 10,
            top: (isViewingAnyGroups ? 112 : 56) + topPadding,
            duration: const Duration(milliseconds: 500),
            child: floatingActionButton,
          )
        ],
      ),
    );
  }
}