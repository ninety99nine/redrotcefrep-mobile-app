import 'package:get/get.dart';

import '../../../../core/shared_widgets/infinite_scroll/custom_vertical_list_view_infinite_scroll.dart';
import '../../../../core/shared_widgets/text/custom_title_small_text.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../authentication/providers/auth_provider.dart';
import '../../repositories/friend_group_repository.dart';
import '../../providers/friend_group_provider.dart';
import '../../../../core/utils/snackbar.dart';
import '../../../../core/utils/dialog.dart';
import 'package:provider/provider.dart';
import '../../models/friend_group.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'dart:convert';

class FriendGroupsInVerticalListViewInfiniteScroll extends StatefulWidget {

  final String filter;
  final Function(bool) onDeletingFriendGroups;
  final Function(FriendGroup) onViewFriendGroup;
  final Function(List<FriendGroup>) onSelectedFriendGroups;

  const FriendGroupsInVerticalListViewInfiniteScroll({
    super.key,
    required this.filter,
    required this.onViewFriendGroup,
    required this.onSelectedFriendGroups,
    required this.onDeletingFriendGroups,
  });

  @override
  State<FriendGroupsInVerticalListViewInfiniteScroll> createState() => _FriendGroupsInVerticalListViewInfiniteScrollState();
}

class _FriendGroupsInVerticalListViewInfiniteScrollState extends State<FriendGroupsInVerticalListViewInfiniteScroll> {

  bool isDeleting = false;

  String get filter => widget.filter;
  Function get onSelectedFriendGroups => widget.onSelectedFriendGroups;
  Function(FriendGroup) get onViewFriendGroup => widget.onViewFriendGroup;
  Function(bool) get onDeletingFriendGroups => widget.onDeletingFriendGroups;
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
  FriendGroupRepository get friendGroupRepository => friendGroupProvider.friendGroupRepository;
  FriendGroupProvider get friendGroupProvider => Provider.of<FriendGroupProvider>(context, listen: false);

  void _startDeleteLoader() => setState(() => isDeleting = true);
  void _stopDeleteLoader() => setState(() => isDeleting = false);

  /// This allows us to access the state of CustomVerticalListViewInfiniteScroll widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomVerticalInfiniteScrollState> _customVerticalListViewInfiniteScrollState = GlobalKey<CustomVerticalInfiniteScrollState>();

  /// Render each request item as an GroupItem
  Widget onRenderItem(item, int index, List items, bool isSelected, List selectedItems, bool hasSelectedItems, int totalSelectedItems) => GroupItem(
    customVerticalListViewInfiniteScrollState: _customVerticalListViewInfiniteScrollState,
    hasSelectedFriendGroups: hasSelectedItems,
    onViewFriendGroup: onViewFriendGroup,
    friendGroup: (item as FriendGroup),
    isSelected: isSelected,
    isDeleting: isDeleting,
  );
  
  /// Render each request item as an FriendGroup
  FriendGroup onParseItem(friendGroup) => FriendGroup.fromJson(friendGroup);
  Future<dio.Response> requestFriendGroups(int page, String searchWord) {

    return friendGroupRepository.showFriendGroups(
      withCountFriends: true,
      withCountStores: true,
      withCountOrders: true,
      withCountUsers: false,
      filter: filter,
      page: page
    );
  }

  /// Condition to determine whether to add or delete the specified
  /// friend group from the list of selected friend groups
  bool toggleSelectionCondition(alreadySelectedItem, currSelectedItem) {

    final FriendGroup alreadySelectedFriendGroup = alreadySelectedItem as FriendGroup;
    final FriendGroup currSelectedFriendGroup = currSelectedItem as FriendGroup;

    return alreadySelectedFriendGroup.id == currSelectedFriendGroup.id;

  }

  void onSelectedItems(List items) {
    final friendGroups = List<FriendGroup>.from(items);
    onSelectedFriendGroups(friendGroups);
  }

  Widget selectedAllAction(isLoading) {

    /// Delete Icon
    return GestureDetector(
      onTap: _requestDeleteManyFriendGroups,
      child: const Icon(Icons.delete_rounded, color: Colors.red,)
    );

  }

  /// Request to delete the selected friend groups
  void _requestDeleteManyFriendGroups() async {

    final CustomVerticalInfiniteScrollState customInfiniteScrollCurrentState = _customVerticalListViewInfiniteScrollState.currentState!;
    final List<FriendGroup> selectedFriendGroups = List<FriendGroup>.from(customInfiniteScrollCurrentState.selectedItems);

    final bool? confirmation = await confirmDelete();

    /// If we can delete
    if(confirmation == true) {

      _startDeleteLoader();

      /// Notify parent that we are starting the deleting process
      onDeletingFriendGroups(true);

      friendGroupRepository.deleteManyFriendGroups(
        friendGroups: selectedFriendGroups
      ).then((response) async {

        if(response.statusCode == 200) {

          SnackbarUtility.showSuccessMessage(message: response.data['message']);

          //  Refresh the friend groups
          customInfiniteScrollCurrentState.startRequest();

        }

        customInfiniteScrollCurrentState.unselectSelectedItems();

      }).catchError((error) {

        printError(info: error.toString());

        SnackbarUtility.showErrorMessage(message: 'Failed to delete groups');

      }).whenComplete(() {

        _stopDeleteLoader();

        /// Notify parent that we are ending the deleting process
        onDeletingFriendGroups(false);

      });

    }

  }

  /// Confirm delete the selected friend groups
  Future<bool?> confirmDelete() {

    final CustomVerticalInfiniteScrollState customInfiniteScrollCurrentState = _customVerticalListViewInfiniteScrollState.currentState!;
    final int totalSelectedItems = customInfiniteScrollCurrentState.totalSelectedItems;

    return DialogUtility.showConfirmDialog(
      content: 'Are you sure you want to delete $totalSelectedItems ${totalSelectedItems == 1 ? 'group': 'groups'}?',
      context: context
    );

  }
  
  @override
  Widget build(BuildContext context) {
    return CustomVerticalListViewInfiniteScroll(
      disabled: isDeleting,
      debounceSearch: true,
      onParseItem: onParseItem, 
      showNoMoreContent: false,
      onRenderItem: onRenderItem,
      onSelectedItems: onSelectedItems,
      selectedAllAction: selectedAllAction,
      catchErrorMessage: 'Can\'t show groups',
      key: _customVerticalListViewInfiniteScrollState,
      toggleSelectionCondition: toggleSelectionCondition,
      onRequest: (page, searchWord) => requestFriendGroups(page, searchWord),
      headerPadding: const EdgeInsets.only(top: 40, bottom: 0, left: 16, right: 16)
    );
  }
}

class GroupItem extends StatelessWidget {
  
  final bool isSelected;
  final bool isDeleting;
  final FriendGroup friendGroup;
  final bool hasSelectedFriendGroups;
  final Function(FriendGroup) onViewFriendGroup;
  final GlobalKey<CustomVerticalInfiniteScrollState> customVerticalListViewInfiniteScrollState;

  const GroupItem({
    super.key, 
    required this.isSelected,
    required this.isDeleting,
    required this.friendGroup,
    required this.onViewFriendGroup,
    required this.hasSelectedFriendGroups,
    required this.customVerticalListViewInfiniteScrollState,
  });

  int get id => friendGroup.id;
  String get name => friendGroup.name;
  int get totalFriends => friendGroup.friendsCount!;
  String get totalFriendsText => '$totalFriends ${totalFriends == 1 ? 'Friend' : 'Friends'}';
  int get totalStores => friendGroup.storesCount!;
  String get totalStoresText => '$totalStores ${totalStores == 1 ? 'Store' : 'Stores'}';
  int get totalOrders => friendGroup.ordersCount!;
  String get totalOrdersText => '$totalOrders ${totalOrders == 1 ? 'Order' : 'Orders'}';
  CustomVerticalInfiniteScrollState get customInfiniteScrollCurrentState => customVerticalListViewInfiniteScrollState.currentState!;

  bool get canPerformActions {

    /// If we are loading data (then stop) 
    if(customInfiniteScrollCurrentState.isLoading == true) {
      return false;
    }
    
    /// If we are deleting friend groups (then stop)
    if(isDeleting) {

      return false;
      
    }

    /// Otherwise continue
    return true;
    
  }

  void toggleSelection() {
    if(canPerformActions == false) return;
    customInfiniteScrollCurrentState.toggleSelection(friendGroup);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Dismissible(
            key: ValueKey<int>(id),
            direction: DismissDirection.startToEnd,
            confirmDismiss: (DismissDirection direction) {
              
              if(canPerformActions) customInfiniteScrollCurrentState.toggleSelection(friendGroup);
        
              return Future.delayed(Duration.zero).then((_) => false);
        
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: isSelected ? Colors.green.shade50 : null,
                border: Border.all(color: isSelected ? Colors.green.shade300 : Colors.transparent),
              ),
              child: ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                onLongPress: toggleSelection,
                onTap: toggleSelection,
                title: AnimatedPadding(
                  duration: const Duration(milliseconds: 500),
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
        
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
        
                          /// Name
                          CustomTitleSmallText(name),
                  
                          /// Spacer
                          const SizedBox(height: 4),

                          Row(
                            children: [

                              //  Total Friends
                              CustomBodyText(totalFriendsText, lightShade: true),
                  
                              /// Spacer
                              const SizedBox(width: 8),

                              //  Total Stores
                              CustomBodyText(totalStoresText, lightShade: true),
                  
                              /// Spacer
                              const SizedBox(width: 8),

                              //  Total Orders
                              CustomBodyText(totalOrdersText, lightShade: true),
                              
                            ],
                          )    
        
                        ],
                      ),
                
                      /// Cancel Icon
                      if(!isDeleting && isSelected) Positioned(
                        top: -6,
                        right: -16,
                        child: IconButton(
                          padding: const EdgeInsets.only(left: 24, right: 16),
                          icon: Icon(Icons.cancel, size: 20, color: Colors.green.shade500,),
                          onPressed: () {
                            
                            if(canPerformActions == false) return;
        
                            /// Unselect the selected friend groups
                            customInfiniteScrollCurrentState.unselectSelectedItems();
        
                          }
                        ),
                      ),
        
                    ]
                  )
                )
              ),
            ),
          ),
        ),

        /// Spacer
        SizedBox(width: isSelected ? 8 : 0),

        /// Forward Icon
        if(!isDeleting) CircleAvatar(
          radius: 16,
          backgroundColor: Colors.grey.shade100,
          child: IconButton(
            isSelected: true,
            padding: EdgeInsets.zero,
            icon: Icon(Icons.arrow_forward, size: 16, color: Colors.grey.shade400,),
            onPressed: () {
              
              if(canPerformActions == false) return;
        
              /// Unselect the selected friend groups
              customInfiniteScrollCurrentState.unselectSelectedItems();
        
              //  View this friend group
              onViewFriendGroup(friendGroup);
        
            }
          ),
        ),
      ],
    );
  }
}