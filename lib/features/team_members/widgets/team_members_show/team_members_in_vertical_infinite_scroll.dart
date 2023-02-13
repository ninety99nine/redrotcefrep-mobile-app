import '../../../../core/shared_widgets/infinite_scroll/custom_vertical_infinite_scroll.dart';
import '../../../../core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import '../../../../core/shared_models/user_association_as_team_member.dart';
import '../../../../core/shared_widgets/buttons/custom_elevated_button.dart';
import '../../../../core/shared_widgets/text/custom_title_small_text.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../../core/shared_models/mobile_number.dart';
import '../../../stores/providers/store_provider.dart';
import '../../../stores/services/store_services.dart';
import '../../../stores/models/shoppable_store.dart';
import '../../../../core/shared_models/user.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/utils/snackbar.dart';
import '../../../../core/utils/dialog.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

class TeamMembersInVerticalInfiniteScroll extends StatefulWidget {
  
  final ShoppableStore store;
  final String teamMemberFilter;
  final Function(User) onViewTeamMember;
  final Function() onRemovedTeamMembers;
  final Function(bool) onRemovingTeamMembers;

  const TeamMembersInVerticalInfiniteScroll({
    Key? key,
    required this.store,
    required this.teamMemberFilter,
    required this.onViewTeamMember,
    required this.onRemovedTeamMembers,
    required this.onRemovingTeamMembers,
  }) : super(key: key);

  @override
  State<TeamMembersInVerticalInfiniteScroll> createState() => TeamMembersInVerticalInfiniteScrollState();
}

class TeamMembersInVerticalInfiniteScrollState extends State<TeamMembersInVerticalInfiniteScroll> {

  bool isRemoving = false;

  ShoppableStore get store => widget.store;
  String get teamMemberFilter => widget.teamMemberFilter;
  Function(User) get onViewTeamMember => widget.onViewTeamMember;
  Function get onRemovedTeamMembers => widget.onRemovedTeamMembers;
  Function(bool) get onRemovingTeamMembers => widget.onRemovingTeamMembers;
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  bool get canManageTeamMembers => StoreServices.hasPermissionsToManageTeamMembers(store);

  /// This allows us to access the state of CustomVerticalInfiniteScroll widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomVerticalInfiniteScrollState> _customVerticalInfiniteScrollState = GlobalKey<CustomVerticalInfiniteScrollState>();

  void _startRemoveLoader() => setState(() => isRemoving = true);
  void _stopRemoveLoader() => setState(() => isRemoving = false);

  @override
  void didUpdateWidget(covariant TeamMembersInVerticalInfiniteScroll oldWidget) {
    super.didUpdateWidget(oldWidget);

    /// If the team member filter changed
    if(teamMemberFilter != oldWidget.teamMemberFilter) {

      /// Start a new request
      _customVerticalInfiniteScrollState.currentState!.startRequest();

    }
  }

  /// Render each request item as an TeamMemberItem
  Widget onRenderItem(user, int index, List users, bool isSelected, List selectedItems, bool hasSelectedItems, int totalSelectedItems) => TeamMemberItem(
    customVerticalInfiniteScrollState: _customVerticalInfiniteScrollState,
    canManageTeamMembers: canManageTeamMembers,
    hasSelectedTeamMembers: hasSelectedItems,
    onViewTeamMember: onViewTeamMember,
    isSelected: isSelected,
    isRemoving: isRemoving,
    user: (user as User)
  );

  /// Render each request item as an User
  User onParseItem(user) => User.fromJson(user);
  Future<http.Response> requestStoreTeamMembers(int page, String searchTerm) {
    return storeProvider.setStore(store).storeRepository.showTeamMembers(
      /// Filter by the team member filter specified (teamMemberFilter)
      filter: teamMemberFilter,
      searchTerm: searchTerm,
      context: context,
      page: page
    );
  }

  /// Condition to determine whether to add or remove the specified
  /// team member from the list of selected team members
  bool toggleSelectionCondition(alreadySelectedItem, currSelectedItem) {

    final User alreadySelectedTeamMember = alreadySelectedItem as User;
    final User currSelectedTeamMember = currSelectedItem as User;

    /// We cannot use the User ID because some team members are non-existing
    /// users that are sharing the Guest user account. If we match by User
    /// ID, then every guest will match upon selecting one of the guest
    /// team members (team members still to create user accounts). In
    /// this case we will use the user association pivot id to make
    /// sure that this is an exact match.
    return alreadySelectedTeamMember.attributes.userAssociationAsTeamMember!.id
           == currSelectedTeamMember.attributes.userAssociationAsTeamMember!.id;
  }

  Widget selectedAllAction(isLoading) {
    return CustomElevatedButton(
      'Remove', 
      isError: true, 
      disabled: isRemoving,
      onPressed: _requestRemoveTeamMember
    );
  }

  /// Request to remove the selected team members
  void _requestRemoveTeamMember() async {

    final CustomVerticalInfiniteScrollState customInfiniteScrollCurrentState = _customVerticalInfiniteScrollState.currentState!;
    final List<User> teamMembers = List<User>.from(customInfiniteScrollCurrentState.selectedItems);

    final bool? confirmation = await confirmRemove();

    /// If we can remove
    if(confirmation == true) {

      _startRemoveLoader();

      /// Notify parent that we are starting the removing process
      onRemovingTeamMembers(true);

      storeProvider.setStore(store).storeRepository.removeTeamMembers(
        teamMembers: teamMembers,
        context: context,
      ).then((response) async {

        final responseBody = jsonDecode(response.body);

        if(response.statusCode == 200) {

          SnackbarUtility.showSuccessMessage(message: responseBody['message'], context: context);

          //  Refresh the team members
          customInfiniteScrollCurrentState.startRequest();
          
          //  Notify the parent on team member being removed
          onRemovedTeamMembers();

        }

        customInfiniteScrollCurrentState.unselectSelectedItems();

      }).catchError((error) {

        SnackbarUtility.showErrorMessage(message: 'Failed to remove team members', context: context);

      }).whenComplete((){

        _stopRemoveLoader();

        /// Notify parent that we are ending the removing process
        onRemovingTeamMembers(false);

      });

    }

  }

  /// Confirm remove the selected team members
  Future<bool?> confirmRemove() {

    final CustomVerticalInfiniteScrollState customInfiniteScrollCurrentState = _customVerticalInfiniteScrollState.currentState!;
    final int totalSelectedItems = customInfiniteScrollCurrentState.totalSelectedItems;

    return DialogUtility.showConfirmDialog(
      content: 'Are you sure you want to remove $totalSelectedItems ${totalSelectedItems == 1 ? 'team member': 'team members'}?',
      context: context
    );

  }
  
  @override
  Widget build(BuildContext context) {
    return CustomVerticalInfiniteScroll(
      disabled: isRemoving,
      debounceSearch: true,
      onParseItem: onParseItem, 
      onRenderItem: onRenderItem,
      selectedAllAction: selectedAllAction,
      key: _customVerticalInfiniteScrollState,
      catchErrorMessage: 'Can\'t show team members',
      toggleSelectionCondition: toggleSelectionCondition,
      onRequest: (page, searchTerm) => requestStoreTeamMembers(page, searchTerm),
      headerPadding: EdgeInsets.only(top: canManageTeamMembers ? 40 : 16, bottom: 0, left: 16, right: 16),
    );
  }
}

class TeamMemberItem extends StatelessWidget {
  
  final User user;
  final bool isSelected;
  final bool isRemoving;
  final bool canManageTeamMembers;
  final bool hasSelectedTeamMembers;
  final Function(User) onViewTeamMember;
  final GlobalKey<CustomVerticalInfiniteScrollState> customVerticalInfiniteScrollState;

  const TeamMemberItem({
    super.key, 
    required this.user, 
    required this.isSelected,
    required this.isRemoving,
    required this.onViewTeamMember,
    required this.canManageTeamMembers,
    required this.hasSelectedTeamMembers,
    required this.customVerticalInfiniteScrollState,
  });

  String get role => userAssociationAsTeamMember.role;
  String get dateType => invited ? 'invited' : 'last seen';
  DateTime get createdAt => userAssociationAsTeamMember.createdAt;
  DateTime? get lastSeenAt => userAssociationAsTeamMember.lastSeenAt;
  MobileNumber? get mobileNumber => userAssociationAsTeamMember.mobileNumber;
  String get date => invited ? timeago.format(createdAt) : timeago.format(lastSeenAt!);
  String get title => mobileNumber == null ? user.attributes.name : mobileNumber!.withoutExtension;
  bool get invited => userAssociationAsTeamMember.acceptedInvitation.name.toLowerCase() == 'not specified';
  UserAssociationAsTeamMember get userAssociationAsTeamMember => user.attributes.userAssociationAsTeamMember!;
  CustomVerticalInfiniteScrollState get customInfiniteScrollCurrentState => customVerticalInfiniteScrollState.currentState!;

  bool get canPerformActions {

    /// If we are loading data (then stop) 
    if(customInfiniteScrollCurrentState.isLoading == true) {
      return false;
    }
    
    /// If we are removing team members (then stop)
    if(isRemoving) {

      return false;
      
    }

    /// Otherwise continue
    return true;
    
  }

  @override
  Widget build(BuildContext context) {

    return Dismissible(
      key: ValueKey<int>(userAssociationAsTeamMember.id),
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
          onLongPress: () {
      
            if(canPerformActions == false) return;
            customInfiniteScrollCurrentState.toggleSelection(user);
      
          },
          onTap: () {
      
            if(canPerformActions == false) return;
      
            /// If we are selecting multiple team member
            if(canManageTeamMembers && hasSelectedTeamMembers) {
              
              /// Select this team member
              customInfiniteScrollCurrentState.toggleSelection(user);
      
            /// If we can manage team members
            }else if(canManageTeamMembers) {
      
              //  View this team member
              onViewTeamMember(user);
      
            }
          },
          title: AnimatedPadding(
            duration: const Duration(milliseconds: 500),
            padding: EdgeInsets.only(left: isSelected ? 16 : 0),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
          
                /// Team Member
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
          
                        /// Name / Mobile Number
                        CustomTitleSmallText(title),
          
                        /// Spacer
                        const SizedBox(height: 4,),
          
                        /// Role
                        CustomBodyText('@${role.toLowerCase()}', lightShade: true),
                        
                      ],
                    ),
                    
                    /// Datetime & Arrow Icon
                    if(!isSelected) Row(
                      children: [
          
                        /// Datetime (Created At / Last Seen)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
          
                            /// Date Type (last seen / invited)
                            CustomBodyText(dateType, lightShade: true,),
          
                            /// Spacer
                            const SizedBox(height: 4,),
          
                            /// Date (10 days ago)
                            CustomBodyText(date)
                            
                          ],
                        ),
          
                        /// Arrow Icon (Show if we can manage team members)
                        if(canManageTeamMembers) ...[
                          const SizedBox(width: 4,),
                          const Icon(Icons.arrow_forward, size: 16)
                        ]
                        
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
                  right: 0,
                  child: IconButton(
                    icon: Icon(Icons.cancel, size: 20, color: Colors.green.shade500,),
                    onPressed: () {
                      if(canPerformActions == false) return;
                      customInfiniteScrollCurrentState.toggleSelection(user);
                    }
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