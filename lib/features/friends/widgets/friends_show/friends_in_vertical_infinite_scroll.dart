import 'package:get/get.dart';

import '../../../../core/shared_widgets/infinite_scroll/custom_vertical_list_view_infinite_scroll.dart';
import '../../../../core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import '../../../../core/shared_models/user_friend_group_association.dart';
import '../../../../core/shared_widgets/text/custom_title_small_text.dart';
import '../../../friend_groups/providers/friend_group_provider.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../authentication/providers/auth_provider.dart';
import '../../../../core/shared_models/mobile_number.dart';
import '../../../friend_groups/models/friend_group.dart';
import '../../../../core/shared_models/user.dart';
import '../../../../core/utils/snackbar.dart';
import '../../../../core/utils/dialog.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'dart:convert';

class FriendsInVerticalListViewInfiniteScroll extends StatefulWidget {

  final bool canSelect;
  final bool canShowRemoveIcon;
  final FriendGroup? friendGroup;
  final EdgeInsets headerPadding;
  final Function(bool)? onRemovingFriends;
  final Function(List<User>)? onSelectedFriends;

  const FriendsInVerticalListViewInfiniteScroll({
    super.key,
    this.friendGroup,
    this.canSelect = true,
    this.onSelectedFriends,
    this.onRemovingFriends,
    this.canShowRemoveIcon = false,
    this.headerPadding = const EdgeInsets.only(top: 40, bottom: 0, left: 16, right: 16)
  });

  @override
  State<FriendsInVerticalListViewInfiniteScroll> createState() => _FriendsInVerticalListViewInfiniteScrollState();
}

class _FriendsInVerticalListViewInfiniteScrollState extends State<FriendsInVerticalListViewInfiniteScroll> {

  bool isRemoving = false;

  bool get canSelect => widget.canSelect;
  User get authUser => authProvider.user!;
  bool get hasFriendGroup => friendGroup != null;
  FriendGroup? get friendGroup => widget.friendGroup;
  EdgeInsets get headerPadding => widget.headerPadding;
  bool get canShowRemoveIcon => widget.canShowRemoveIcon;
  Function(bool)? get onRemovingFriends => widget.onRemovingFriends;
  Function(List<User>)? get onSelectedFriends => widget.onSelectedFriends;
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
  FriendGroupProvider get friendGroupProvider => Provider.of<FriendGroupProvider>(context, listen: false);

  void _startRemoveLoader() => setState(() => isRemoving = true);
  void _stopRemoveLoader() => setState(() => isRemoving = false);

  /// This allows us to access the state of CustomVerticalListViewInfiniteScroll widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomVerticalInfiniteScrollState> _customVerticalListViewInfiniteScrollState = GlobalKey<CustomVerticalInfiniteScrollState>();

  /// Render each request item as an FriendItem
  Widget onRenderItem(user, int index, List users, bool isSelected, List selectedItems, bool hasSelectedItems, int totalSelectedItems) => FriendItem(
    customVerticalListViewInfiniteScrollState: _customVerticalListViewInfiniteScrollState,
    canShowRemoveIcon: canShowRemoveIcon,
    hasSelectedItems: hasSelectedItems,
    isSelected: isSelected,
    isRemoving: isRemoving,
    user: (user as User),
    canSelect: canSelect
  );
  
  /// Render each request item as an User
  User onParseItem(user) => User.fromJson(user);
  Future<dio.Response> requestFriends(int page, String searchWord) {

    Future<dio.Response> request;

    if(friendGroup == null) {
      request = authProvider.authRepository.showFriends();
    }else{

      request = friendGroupProvider.setFriendGroup(friendGroup!).friendGroupRepository.showFriendGroupMembers(
        exceptUserId: authUser.id,
        context: context,
        page: page
      );
    }

    return request;

  }

  /// Condition to determine whether to add or remove the specified
  /// friend from the list of selected friends
  bool toggleSelectionCondition(alreadySelectedItem, currSelectedItem) {

    final User alreadySelectedFriend = alreadySelectedItem as User;
    final User currSelectedFriend = currSelectedItem as User;

    return alreadySelectedFriend.id == currSelectedFriend.id;

  }

  void onSelectedItems(List items) {
    final friends = List<User>.from(items);
    if(onSelectedFriends != null) onSelectedFriends!(friends);
  }

  Widget selectedAllAction(isLoading) {

    const Widget removeIcon = Icon(Icons.delete_rounded, color: Colors.red);
    const Widget loader = CustomCircularProgressIndicator(
      size: 16,
      strokeWidth: 2,
      margin: EdgeInsets.only(top: 12),
    );

    /// Remove Icon
    return GestureDetector(
      onTap: _requestRemoveFriends,
      child: isLoading ? loader : removeIcon
    );

  }

  /// Request to remove the selected friends
  void _requestRemoveFriends() async {

    if(isRemoving) return;

    final CustomVerticalInfiniteScrollState customInfiniteScrollCurrentState = _customVerticalListViewInfiniteScrollState.currentState!;
    final List<User> selectedFriends = List<User>.from(customInfiniteScrollCurrentState.selectedItems);

    final bool? confirmation = await confirmRemove();

    /// If we can remove
    if(confirmation == true) {

      _startRemoveLoader();

      /// Notify parent that we are starting the removing process
      if(onRemovingFriends != null) onRemovingFriends!(true);

      Future<dio.Response> request;

      if(friendGroup == null) {
        request = authProvider.authRepository.removeFriends(
          friends: selectedFriends
        );
      }else{
        request = friendGroupProvider.setFriendGroup(friendGroup!).friendGroupRepository.removeFriendGroupMembers(
          friends: selectedFriends,
        );
      }

      request.then((response) async {

        if(response.statusCode == 200) {

          SnackbarUtility.showSuccessMessage(message: response.data['message']);

          //  Refresh the friends
          customInfiniteScrollCurrentState.startRequest();

        }

        customInfiniteScrollCurrentState.unselectSelectedItems();

      }).catchError((error) {

        printError(info: error.toString());

        SnackbarUtility.showErrorMessage(message: 'Failed to remove friends');

      }).whenComplete(() {

        _stopRemoveLoader();

        /// Notify parent that we are ending the removing process
        if(onRemovingFriends != null) onRemovingFriends!(false);

      });

    }

  }

  /// Confirm remove the selected friends
  Future<bool?> confirmRemove() {

    final CustomVerticalInfiniteScrollState customInfiniteScrollCurrentState = _customVerticalListViewInfiniteScrollState.currentState!;
    final int totalSelectedItems = customInfiniteScrollCurrentState.totalSelectedItems;

    return DialogUtility.showConfirmDialog(
      content: 'Are you sure you want to remove $totalSelectedItems ${totalSelectedItems == 1 ? 'friend': 'friends'}?',
      context: context
    );

  }
  
  @override
  Widget build(BuildContext context) {
    return CustomVerticalListViewInfiniteScroll(
      disabled: isRemoving,
      debounceSearch: true,
      showNoContent: false,
      onParseItem: onParseItem, 
      showNoMoreContent: false,
      onRenderItem: onRenderItem,
      headerPadding: headerPadding,
      onSelectedItems: onSelectedItems,
      selectedAllAction: selectedAllAction,
      key: _customVerticalListViewInfiniteScrollState,
      catchErrorMessage: 'Can\'t show friends',
      loaderMargin: const EdgeInsets.only(top: 40),
      toggleSelectionCondition: toggleSelectionCondition,
      showFirstRequestLoader: hasFriendGroup ? false : true,
      onRequest: (page, searchWord) => requestFriends(page, searchWord),
    );
  }
}

class FriendItem extends StatelessWidget {
  
  final User user;
  final bool canSelect;
  final bool isSelected;
  final bool isRemoving;
  final bool hasSelectedItems;
  final bool canShowRemoveIcon;
  final GlobalKey<CustomVerticalInfiniteScrollState> customVerticalListViewInfiniteScrollState;

  const FriendItem({
    super.key, 
    required this.user,
    required this.canSelect,
    required this.isSelected,
    required this.isRemoving,
    required this.hasSelectedItems,
    required this.canShowRemoveIcon,
    required this.customVerticalListViewInfiniteScrollState,
  });

  int get id => user.id;
  bool get hasRole => role != null;
  String get name => user.attributes.name;
  MobileNumber get mobileNumber => user.mobileNumber!; 
  String? get role => userFriendGroupAssociation?.role;
  bool get isCreator => hasRole ? role!.toLowerCase() == 'creator' : false;
  CustomVerticalInfiniteScrollState get customInfiniteScrollCurrentState => customVerticalListViewInfiniteScrollState.currentState!;
  UserFriendGroupAssociation? get userFriendGroupAssociation => user.attributes.userFriendGroupAssociation;

  bool get canPerformActions {

    /// If we are loading data (then stop) 
    if(customInfiniteScrollCurrentState.isLoading == true) {
      return false;
    }
    
    /// If we are removing friends (then stop)
    if(isRemoving) {

      return false;
      
    }

    /// Otherwise continue
    return true;
    
  }

  void toggleSelection(BuildContext context) {
    if(canPerformActions == false || canSelect == false) return;
    customInfiniteScrollCurrentState.toggleSelection(user);
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey<int>(id),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (DismissDirection direction) {
        
        if(canPerformActions) customInfiniteScrollCurrentState.toggleSelection(user);

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
          onLongPress: () => toggleSelection(context),
          onTap: () => toggleSelection(context),
          /// Name & Mobile Number
          title: AnimatedPadding(
            duration: const Duration(milliseconds: 500),
            padding: EdgeInsets.only(left: isSelected ? 16 : 0, right: 16),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
          
                /// Friend
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
          
                        /// Name
                        CustomTitleSmallText(name),
          
                        /// Spacer
                        const SizedBox(height: 4,),

                        Row(
                          children: [
              
                            /// Role
                            if(hasRole) CustomBodyText(role, color: isCreator ? Colors.green.shade500 : null, lightShade: !isCreator),
              
                            /// Spacer
                            if(hasRole) const SizedBox(width: 8,),

                            /// Mobile Number
                            CustomBodyText(mobileNumber.withoutExtension, lightShade: true),

                          ],
                        )
                        
                      ],
                    ),

                    /// Removing Loader
                    if(isRemoving && isSelected) const CustomCircularProgressIndicator(
                      size: 16,
                      strokeWidth: 2,
                      margin: EdgeInsets.only(top: 12),
                    )
          
                  ],
                ),
          
                /// Cancel Icon
                if(!isRemoving && isSelected) Positioned(
                  top: -5,
                  right: -20,
                  child: IconButton(
                    icon: Icon(Icons.cancel, size: 20, color: Colors.green.shade500,),
                    onPressed: () => toggleSelection(context)
                  ),
                ),
          
                /// Remove Icon
                if(canShowRemoveIcon && canSelect && !isRemoving && !hasSelectedItems) Positioned(
                  top: -5,
                  right: -20,
                  child: IconButton(
                    padding: const EdgeInsets.only(left: 24, right: 16),
                    icon: Icon(Icons.delete_rounded, size: 20, color: Colors.red.shade500,),
                    onPressed: () => toggleSelection(context)
                  ),
                ),
          
              ],
            ),
          ),
          
        ),
      ),
    );
  }
}