import 'package:bonako_demo/core/shared_widgets/text_form_field/custom_mobile_number_text_form_field.dart';
import '../../../../core/shared_widgets/infinite_scroll/custom_vertical_list_view_infinite_scroll.dart';
import 'package:bonako_demo/features/user/widgets/user_profile_photo/user_profile_photo.dart';
import '../../../../core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import 'package:bonako_demo/features/authentication/repositories/auth_repository.dart';
import 'package:bonako_demo/core/shared_widgets/button/custom_elevated_button.dart';
import 'package:bonako_demo/features/contacts/widgets/contacts_modal_popup.dart';
import '../../../../core/shared_models/user_friend_group_association.dart';
import '../../../../core/shared_widgets/text/custom_title_small_text.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../authentication/providers/auth_provider.dart';
import 'package:bonako_demo/core/utils/error_utility.dart';
import '../../../../core/shared_models/mobile_number.dart';
import 'package:bonako_demo/core/utils/mobile_number.dart';
import '../../providers/friend_group_provider.dart';
import '../../../../core/shared_models/user.dart';
import '../../../../core/utils/snackbar.dart';
import '../../../../core/utils/dialog.dart';
import 'package:provider/provider.dart';
import '../../models/friend_group.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';

class FriendGroupFriendsInVerticalListViewInfiniteScroll extends StatefulWidget {

  final bool canSelect;
  final bool canShowRemoveIcon;
  final FriendGroup friendGroup;
  final Function()? onInvitedMembers;
  final Function()? onRemovedMembers;
  final String friendGroupMemberFilter;
  final Function(bool)? onInvitingMembers;
  final Function(bool)? onRemovingMembers;
  final Function(List<User>)? onSelectedMembers;

  const FriendGroupFriendsInVerticalListViewInfiniteScroll({
    super.key,
    this.onInvitedMembers,
    this.onRemovedMembers,
    this.canSelect = true,
    this.onSelectedMembers,
    this.onInvitingMembers,
    this.onRemovingMembers,
    required this.friendGroup,
    this.canShowRemoveIcon = true,
    required this.friendGroupMemberFilter,
  });

  @override
  State<FriendGroupFriendsInVerticalListViewInfiniteScroll> createState() => _FriendGroupFriendsInVerticalListViewInfiniteScrollState();
}

class _FriendGroupFriendsInVerticalListViewInfiniteScrollState extends State<FriendGroupFriendsInVerticalListViewInfiniteScroll> {

  Map serverErrors = {};
  String role = 'Member';
  bool isRemoving = false;
  bool isInviting = false;
  List<String> inviteMobileNumbers = [];
  TextEditingController inviteMobileNumberController = TextEditingController();

  bool get canSelect => widget.canSelect;
  User get authUser => authProvider.user!;
  final FocusNode _focusNode = FocusNode();
  GlobalKey<FormState> formKey = GlobalKey();
  FriendGroup get friendGroup => widget.friendGroup;
  bool get canShowRemoveIcon => widget.canShowRemoveIcon;
  Function()? get onInvitedMembers => widget.onInvitedMembers;
  Function()? get onRemovedMembers => widget.onRemovedMembers;
  int get totalInviteMobileNumbers => inviteMobileNumbers.length;
  AuthRepository get authRepository => authProvider.authRepository;
  bool get hasInviteMobileNumbers => inviteMobileNumbers.isNotEmpty;
  Function(bool)? get onInvitingMembers => widget.onInvitingMembers;
  Function(bool)? get onRemovingMembers => widget.onRemovingMembers;
  bool get hasCompleteMobileNumber => inviteMobileNumber.length == 8;
  String get inviteMobileNumber => inviteMobileNumberController.text;
  String get friendGroupMemberFilter => widget.friendGroupMemberFilter;
  bool get hasManyInviteMobileNumbers => totalInviteMobileNumbers >= 2;
  Function(List<User>)? get onSelectedMembers => widget.onSelectedMembers;
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
  bool get authIsCreatorOrAdmin => friendGroup.attributes.userFriendGroupAssociation!.isCreatorOrAdmin;
  FriendGroupProvider get friendGroupProvider => Provider.of<FriendGroupProvider>(context, listen: false);

  void _startRemoveLoader() => setState(() => isRemoving = true);
  void _stopRemoveLoader() => setState(() => isRemoving = false);
  void _startInvitingLoader() => setState(() => isInviting = true);
  void _stopInvitingLoader() => setState(() => isInviting = false);

  /// Reset the server errors
  void _resetServerErrors() => setState(() => serverErrors = {});

  @override
  void didUpdateWidget(covariant FriendGroupFriendsInVerticalListViewInfiniteScroll oldWidget) {
    super.didUpdateWidget(oldWidget);

    /// If the review subject changed
    if(friendGroupMemberFilter != oldWidget.friendGroupMemberFilter) {

      //  Refresh the members list
      refreshMembers();

    }
  }

  @override
  void dispose() {
    super.dispose();
    inviteMobileNumberController.dispose();
  }

  /// This allows us to access the state of CustomVerticalListViewInfiniteScroll widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomVerticalListViewInfiniteScrollState> _customVerticalListViewInfiniteScrollState = GlobalKey<CustomVerticalListViewInfiniteScrollState>();

  /// Render each request item as an FriendItem
  Widget onRenderItem(user, int index, List users, bool isSelected, List selectedItems, bool hasSelectedItems, int totalSelectedItems) => FriendItem(
    customVerticalListViewInfiniteScrollState: _customVerticalListViewInfiniteScrollState,
    requestRemoveMembers: requestRemoveMembers,
    authIsCreatorOrAdmin: authIsCreatorOrAdmin,
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

    return friendGroupProvider.setFriendGroup(friendGroup).friendGroupRepository.showFriendGroupMembers(
      filter: friendGroupMemberFilter,
      page: page
    );

  }

  /// Condition to determine whether to add or remove the specified
  /// member from the list of selected members
  bool toggleSelectionCondition(alreadySelectedItem, currSelectedItem) {

    final User alreadySelectedFriend = alreadySelectedItem as User;
    final User currSelectedFriend = currSelectedItem as User;

    return alreadySelectedFriend.attributes.userFriendGroupAssociation!.id == currSelectedFriend.attributes.userFriendGroupAssociation!.id;

  }

  void onSelectedItems(List items) {
    final members = List<User>.from(items);
    if(onSelectedMembers != null) onSelectedMembers!(members);
  }

  Widget selectedAllAction(isLoading) {

    const Widget removeIcon = Icon(Icons.delete_rounded, color: Colors.red);
    const Widget nothing = SizedBox();

    /// Remove Icon
    return GestureDetector(
      onTap: () {
        requestRemoveMembers();
      },
      child: isRemoving ? nothing : removeIcon
    );

  }

  /// Request to invite the selected members
  void _requestInviteMembers() async {

    _resetServerErrors();

    if(isInviting || isRemoving) return;

    await ErrorUtility.validateForm(formKey).then((status) {

      if(status) {

        _startInvitingLoader();

        /// Notify parent that we are starting the inviting process
        if(onInvitingMembers != null) onInvitingMembers!(true);
        
        //  If we have completed the mobile number and have not added to the invite mobile numbers list
        if(hasCompleteMobileNumber && inviteMobileNumbers.contains(inviteMobileNumber) == false) {
          
          /// Add this mobile number to the list of mobile numbers that we would like to invite
          inviteMobileNumbers.add(inviteMobileNumber);

        }

        friendGroupProvider.friendGroupRepository.inviteMembers(
          mobileNumbers: inviteMobileNumbers,
          role: role
        ).then((response) async {

          if(response.statusCode == 200) {

            SnackbarUtility.showSuccessMessage(message: response.data['message']);

            setState(() {
              
              //  Reset the invite mobile number
              inviteMobileNumberController.text = '';
              
              //  Reset the invite mobile numbers
              inviteMobileNumbers = [];

            });

            //  If we have invited new members
            if(response.data['invitations']['totalInvited'] > 0) {

              /// Notify parent widget
              if(onInvitedMembers != null) onInvitedMembers!();

              //  Refresh the members list
              refreshMembers();

            }

          }

        }).catchError((error) {

          printError(info: error.toString());

          SnackbarUtility.showErrorMessage(message: 'Failed to invite members');

        }).whenComplete(() {

          _stopInvitingLoader();

          /// Notify parent that we are ending the inviting process
          if(onInvitingMembers != null) onInvitingMembers!(false);

        });

      }

    });

  }

  /// Request to remove the selected members
  requestRemoveMembers({ User? user, void Function(bool)? onRemovingMember }) async {

    if(isInviting || isRemoving) return;

    final bool? confirmation = await confirmRemove(user: user);

    /// If we can remove
    if(confirmation == true) {

      _startRemoveLoader();

      /// Notify parent that we are starting the removing process
      if(onRemovingMember != null) onRemovingMember(true);

      /// Notify parent that we are starting the removing process
      if(onRemovingMembers != null) onRemovingMembers!(true);

      final CustomVerticalListViewInfiniteScrollState customInfiniteScrollCurrentState = _customVerticalListViewInfiniteScrollState.currentState!;
      List<String> removeMobileNumbers = [];

      if(user == null) {

        final List<User> selectedFriends = List<User>.from(customInfiniteScrollCurrentState.selectedItems);

        /// Capture multiple selected mobile numbers
        removeMobileNumbers.addAll(
          selectedFriends.map((User selectedFriend) { 
            if(selectedFriend.mobileNumber == null) {
              return selectedFriend.attributes.userFriendGroupAssociation!.mobileNumber!.withExtension;
            }else{
              return selectedFriend.mobileNumber!.withExtension;
            }
          }).toList()
        );

      }else{

        /// Capture single selected mobile number
        removeMobileNumbers.add(
          user.mobileNumber == null
            ? user.attributes.userFriendGroupAssociation!.mobileNumber!.withExtension
            : user.mobileNumber!.withExtension
        );

      }

      friendGroupProvider.friendGroupRepository.removeMembers(
        mobileNumbers: removeMobileNumbers
      ).then((response) async {

        if(response.statusCode == 200) {

          SnackbarUtility.showSuccessMessage(message: response.data['message']);

          /// Notify parent widget
          if(onRemovedMembers != null) onRemovedMembers!();

          //  Refresh the members list
          refreshMembers();

        }

        customInfiniteScrollCurrentState.unselectSelectedItems();

      }).catchError((error) {

        printError(info: error.toString());

        SnackbarUtility.showErrorMessage(message: 'Failed to remove members');

      }).whenComplete(() {

        _stopRemoveLoader();

        /// Notify parent that we are starting the removing process
        if(onRemovingMember != null) onRemovingMember(false);

        /// Notify parent that we are ending the removing process
        if(onRemovingMembers != null) onRemovingMembers!(false);

      });

    }

  }

  /// Refresh the members list
  void refreshMembers() {

    final CustomVerticalListViewInfiniteScrollState? customInfiniteScrollCurrentState = _customVerticalListViewInfiniteScrollState.currentState;
    customInfiniteScrollCurrentState?.startRequest();

  }

  /// Confirm remove the selected members
  Future<bool?> confirmRemove({ User? user }) {

    final CustomVerticalListViewInfiniteScrollState customInfiniteScrollCurrentState = _customVerticalListViewInfiniteScrollState.currentState!;
    final int totalSelectedItems = customInfiniteScrollCurrentState.totalSelectedItems;

    /// If we haven't mentioned a specific user, but we have selected one user
    if(user == null && totalSelectedItems == 1) {

      /// Capture that the selected user as our specific user
      user = customInfiniteScrollCurrentState.selectedItems.first;

    }

    if(user == null) {

      return DialogUtility.showConfirmDialog(
        content: 'Are you sure you want to remove $totalSelectedItems friends?',
        context: context
      );

    }else if(user.attributes.userFriendGroupAssociation!.isGuest == false) {

      return DialogUtility.showConfirmDialog(
        content: 'Are you sure you want to remove ${user.attributes.name}?',
        context: context
      );

    }else if(user.attributes.userFriendGroupAssociation!.isGuest == true) {

      return DialogUtility.showConfirmDialog(
        content: 'Are you sure you want to remove this guest friend?',
        context: context
      );

    }else{

      return Future.value(null);

    }

  }

  Widget contentBeforeSearchBar(bool isLoading, int totalCoupons) {
    return _sellerSearchbar;
  }

  Widget get _sellerSearchbar {

    return Form(
      key: formKey,
      child: Container(
        color: Colors.white,  /// The Scaffold background is greyish, we need a white background
        child: SizedBox(
          width: double.infinity,
          child: AnimatedSize(
            duration: const Duration(milliseconds: 500),
            child: AnimatedSwitcher(
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              duration: const Duration(milliseconds: 500),
              child: hasManyInviteMobileNumbers
                ? Column(
                  children: [
            
                    Row(
                      children: [
                        const SizedBox(width: 16),
                        const CustomCircularProgressIndicator(
                          size: 8,
                          strokeWidth: 2,
                        ),
                        const SizedBox(width: 8),
                        CustomBodyText('Inviting $totalInviteMobileNumbers ${totalInviteMobileNumbers == 1 ? 'friend' : 'friends'}')
                      ],
                    ),
                    
                    const SizedBox(height: 24),
            
                    const Divider(height: 0)
            
                  ],
                )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
            
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                    
                          Expanded(
                            child: CustomMobileNumberTextFormField(
                                focusNode: _focusNode,
                                controller: inviteMobileNumberController,
                                supportedMobileNetworkNames: const [
                                  MobileNetworkName.orange
                                ],
                                onChanged: (value) {
                                  
                                  setState(() {
              
                                    /// Automatically invite the specified mobile number
                                    if(hasCompleteMobileNumber) {
                                      _hideKeypad();
                                      _requestInviteMembers();
                                    }
              
                                  });
                            
                                },
                              )
                          ),
            
                          const SizedBox(width: 8,),
                    
                          AnimatedSize(
                            duration: const Duration(milliseconds: 500),
                            child: AnimatedSwitcher(
                              switchInCurve: Curves.easeIn,
                              switchOutCurve: Curves.easeOut,
                              duration: const Duration(milliseconds: 500),
                              child: Column(
                                key: ValueKey(hasCompleteMobileNumber),
                                children: [
                    
                                  /// Add Button
                                  if(hasCompleteMobileNumber) CustomElevatedButton(
                                    '',
                                    width: 20,
                                    isLoading: isInviting,
                                    prefixIcon: Icons.person_add_alt,
                                    onPressed: _requestInviteMembers,
                                  ),
                    
                                  /// Contact Selector
                                  if(!hasCompleteMobileNumber) ContactsModalPopup(
                                    subtitle: 'Search for your friend',
                                    enableBulkSelection: true,
                                    showAddresses: false,
                                    trigger: (openBottomModalSheet) {
                                      return IconButton(onPressed: () => openBottomModalSheet(), icon: const Icon(Icons.person_pin_circle_rounded, color: Colors.green,));
                                    },
                                    onDone: (contacts) {
                                      setState(() {

                                        if(contacts.length == 1) {
                                        
                                          inviteMobileNumberController.text = contacts.first.phones.first.number;

                                        }else if(contacts.length > 1) {

                                          inviteMobileNumbers = contacts.map((contact) => contact.phones.first.number).toList();

                                        }
                    
                                        /// Automatically invite the specified mobile numbers
                                        _requestInviteMembers();
            
                                      });
                                    }, 
                                    supportedMobileNetworkNames: const [
                                      MobileNetworkName.orange
                                    ]
                                  ),
                    
                                ],
                              )
                            )
                          ),
                          
                        ],
                      ),
                    
                      /// Spacer
                      const SizedBox(height: 16),
                  
                      const CustomBodyText('Invite your friends using their mobile numbers', lightShade: true, margin: EdgeInsets.symmetric(horizontal: 8),),
                    
                    ]
                  ),
            ),
          ),
        )
      ),
    );
  }

  void _hideKeypad() {
    _focusNode.unfocus();
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
      showFirstRequestLoader: false,
      onSelectedItems: onSelectedItems,
      selectedAllAction: selectedAllAction,
      catchErrorMessage: 'Can\'t show members',
      loaderMargin: const EdgeInsets.only(top: 40),
      contentBeforeSearchBar: contentBeforeSearchBar,
      key: _customVerticalListViewInfiniteScrollState,
      toggleSelectionCondition: toggleSelectionCondition,
      onRequest: (page, searchWord) => requestFriends(page, searchWord),
      headerPadding: const EdgeInsets.only(top: 20, bottom: 20, left: 16, right: 0),
      multiSelectActionsPadding: const EdgeInsets.only(top: 16, bottom: 0, left: 8, right: 16),
    );
  }
}

class FriendItem extends StatefulWidget {
  
  final User user;
  final bool canSelect;
  final bool isSelected;
  final bool isRemoving;
  final bool hasSelectedItems;
  final bool canShowRemoveIcon;
  final bool authIsCreatorOrAdmin;
  final GlobalKey<CustomVerticalListViewInfiniteScrollState> customVerticalListViewInfiniteScrollState;
  final void Function({ User? user, void Function(bool)? onRemovingMember }) requestRemoveMembers;

  const FriendItem({
    super.key, 
    required this.user,
    required this.canSelect,
    required this.isSelected,
    required this.isRemoving,
    required this.hasSelectedItems,
    required this.canShowRemoveIcon,
    required this.authIsCreatorOrAdmin,
    required this.requestRemoveMembers,
    required this.customVerticalListViewInfiniteScrollState,
  });

  @override
  State<FriendItem> createState() => _FriendItemState();
}

class _FriendItemState extends State<FriendItem> {
  
  bool isRemovingUnselected = false;

  int get id => userFriendGroupAssociation.id;
  String get name => widget.user.attributes.name;
  String get role => userFriendGroupAssociation.role;
  String get status => userFriendGroupAssociation.status;
  bool get userIsCreator => userFriendGroupAssociation.isCreator;
  bool get isRemovingSelected => widget.isSelected && widget.isRemoving;
  bool get userIsCreatorOrAdmin => userFriendGroupAssociation.isCreatorOrAdmin;
  bool get isUserWhoHasJoined => userFriendGroupAssociation.isUserWhoHasJoined;
  UserFriendGroupAssociation get userFriendGroupAssociation => widget.user.attributes.userFriendGroupAssociation!;
  MobileNumber get mobileNumber => widget.user.mobileNumber == null ? userFriendGroupAssociation.mobileNumber! : widget.user.mobileNumber!;
  CustomVerticalListViewInfiniteScrollState get customInfiniteScrollCurrentState => widget.customVerticalListViewInfiniteScrollState.currentState!;

  bool get canPerformActions {

    /// If we are loading data (then stop) 
    if(customInfiniteScrollCurrentState.isLoading == true) {
      return false;
    }
    
    /// If we are removing members (then stop)
    if(isRemovingSelected || isRemovingUnselected) {
      return false;
    }

    /// If we are not a creator or admin (then stop)
    if(widget.authIsCreatorOrAdmin == false) {
      return false;
    }

    /// If the user is a creator (then stop)
    if(userIsCreator) {
      return false;
    }

    /// Otherwise continue
    return true;
    
  }

  void toggleSelection(BuildContext context) {
    if(canPerformActions == false || widget.canSelect == false) return;
    customInfiniteScrollCurrentState.toggleSelection(widget.user);
  }

  void onRemovingMember(bool status) {
    setState(() => isRemovingUnselected = status);
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey<int>(id),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (DismissDirection direction) {
        
        if(canPerformActions) customInfiniteScrollCurrentState.toggleSelection(widget.user);

        return Future.delayed(Duration.zero).then((_) => false);

      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: widget.isSelected ? Colors.green.shade50 : null,
          border: Border.all(color: widget.isSelected ? Colors.green.shade300 : Colors.transparent),
        ),
        child: ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 0),
          onLongPress: () => toggleSelection(context),
          onTap: () => toggleSelection(context),
          /// Name & Mobile Number
          title: AnimatedPadding(
            duration: const Duration(milliseconds: 500),
            padding: EdgeInsets.only(left: widget.isSelected ? 4 : 0, right: 16),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
          
                /// Friend
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [

                    /// Profile Photo
                    UserProfilePhoto(user: widget.user, radius: 20, thickness: 2, canCall: false, placeholderIconSize: 20,),
          
                    /// Spacer
                    const SizedBox(width: 8,),

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
                            CustomBodyText('@${role.toLowerCase()}', color: userIsCreator ? Colors.green.shade500 : null, lightShade: !userIsCreator, fontSize: 12,),
              
                            /// Spacer
                            const SizedBox(width: 8,),
              
                            /// Status
                            CustomBodyText(status.toLowerCase(), color: isUserWhoHasJoined ? Colors.green.shade500 : null, lightShade: !userIsCreator, fontSize: 12,),
              
                            /// Spacer
                            const SizedBox(width: 8,),

                            /// Mobile Number
                            CustomBodyText(mobileNumber.withoutExtension, lightShade: true, fontSize: 12),

                          ],
                        )
                        
                      ],
                    ),
                  ],
                ),
          
                /// Cancel Icon
                if(!widget.isRemoving && widget.isSelected) Positioned(
                  top: -5,
                  right: -20,
                  child: IconButton(
                    icon: Icon(Icons.cancel, size: 20, color: Colors.green.shade500,),
                    onPressed: () => toggleSelection(context)
                  ),
                ),
          
                /// Remove Icon
                if(widget.canShowRemoveIcon && canPerformActions && widget.canSelect && !widget.isSelected && !(isRemovingSelected || isRemovingUnselected)) Positioned(
                  top: -5,
                  right: -20,
                  child: IconButton(
                    padding: const EdgeInsets.only(left: 24, right: 16),
                    icon: Icon(Icons.delete_rounded, size: 20, color: Colors.red.shade500,),
                    onPressed: () => widget.requestRemoveMembers(user: widget.user, onRemovingMember: onRemovingMember)
                  ),
                ),

                /// Removing Loader
                if(isRemovingSelected || isRemovingUnselected) const Positioned(
                  top: 16,
                  right: 4,
                  child: CustomCircularProgressIndicator(
                    strokeWidth: 2,
                    size: 8,
                  ),
                )
          
              ],
            ),
          ),
          
        ),
      ),
    );
  }
}