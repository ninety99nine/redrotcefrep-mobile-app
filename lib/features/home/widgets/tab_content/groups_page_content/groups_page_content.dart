import 'package:bonako_demo/features/friend_groups/widgets/create_or_update_friend_group/create_or_update_friend_group_modal_bottom_sheet/create_or_update_friend_group_modal_bottom_sheet.dart';
import 'package:bonako_demo/features/friend_groups/widgets/friend_group_friends/friend_group_friends_modal_bottom_sheet/friend_group_friends_modal_bottom_sheet.dart';
import 'package:bonako_demo/features/friend_groups/widgets/friend_group_stores/friend_group_stores_modal_bottom_sheet/friend_group_stores_modal_bottom_sheet.dart';
import 'package:bonako_demo/features/friend_groups/widgets/friend_groups_show/friend_groups_modal_bottom_sheet/friend_groups_modal_bottom_sheet.dart';
import 'package:bonako_demo/features/orders/widgets/orders_show/friend_group_orders_in_horizontal_list_view_infinite_scroll.dart';
import 'package:bonako_demo/core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import 'package:bonako_demo/core/shared_widgets/cards/custom_title_and_number_card.dart';
import 'package:bonako_demo/features/friend_groups/providers/friend_group_provider.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_medium_text.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:bonako_demo/features/stores/widgets/store_cards/store_cards.dart';
import 'package:bonako_demo/features/authentication/providers/auth_provider.dart';
import 'package:bonako_demo/features/friend_groups/enums/friend_group_enums.dart';
import 'package:bonako_demo/features/friend_groups/models/friend_group.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import 'package:bonako_demo/features/user/models/resource_totals.dart';
import 'package:bonako_demo/features/orders/enums/order_enums.dart';
import 'package:bonako_demo/features/stores/enums/store_enums.dart';
import 'package:bonako_demo/features/orders/models/order.dart';
import 'package:bonako_demo/core/shared_models/user.dart';
import 'package:bonako_demo/core/utils/snackbar.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';

class GroupsPageContent extends StatefulWidget {

  final Function(int) onChangeNavigationTab;
  final Future<dio.Response?> Function() onRequestShowResourceTotals;

  const GroupsPageContent({
    super.key,
    required this.onChangeNavigationTab,
    required this.onRequestShowResourceTotals
  });

  @override
  State<GroupsPageContent> createState() => _GroupsPageContentState();
}

class _GroupsPageContentState extends State<GroupsPageContent> with WidgetsBindingObserver{

  late User authUser;
  ResourceTotals? resourceTotals;
  bool isLoadingResourceTotals = false;
  FriendGroup? lastSelectedFriendGroup;
  late FriendGroupProvider friendGroupProvider;
  bool isLoadingLastSelectedFriendGroup = false;
  bool? isLoadingLastSelectedFriendGroupForTheFirstTime;

  bool get hasResourceTotals => resourceTotals != null;
  bool get doesNotHaveResourceTotals => resourceTotals == null;
  bool get hasSelectedAFriendGroup => lastSelectedFriendGroup != null;
  Function(int) get onChangeNavigationTab => widget.onChangeNavigationTab;
  
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
  int get totalGroupsJoined => hasResourceTotals ? resourceTotals!.totalGroupsJoined : 0;
    bool get hasGroupsJoined => hasResourceTotals ? resourceTotals!.totalGroupsJoined > 0 : false;
  bool get hasNoGroupsJoined => hasResourceTotals ? resourceTotals!.totalGroupsJoined == 0 : false;
  bool get hasOneGroupJoined => hasResourceTotals ? resourceTotals!.totalGroupsJoined == 1 : false;
  bool get hasManyGroupsJoined => hasResourceTotals ? resourceTotals!.totalGroupsJoined > 1 : false;
  bool get hasGroupsJoinedAsCreator => hasResourceTotals ? resourceTotals!.totalGroupsJoinedAsCreator > 0 : false;
  bool get hasGroupsJoinedAsNonCreator => hasResourceTotals ? resourceTotals!.totalGroupsJoinedAsNonCreator > 0 : false;
  bool get hasGroupsInvitedToJoinAsGroupMember => hasResourceTotals ? resourceTotals!.totalGroupsInvitedToJoinAsGroupMember > 0 : false;

  bool get hasAddedStoresOnLastSelectedFriendGroup => totalAddedStoresOnLastSelectedFriendGroup > 0;
  bool get hasAddedFriendsOnLastSelectedFriendGroup => totalAddedFriendsOnLastSelectedFriendGroup > 0;
  bool get hasPlacedAnOrderOnLastSelectedFriendGroup => totalPlacedOrdersOnLastSelectedFriendGroup > 0;
  bool get lastSelectedFriendGroupHasDescription => hasSelectedAFriendGroup ? lastSelectedFriendGroup!.emoji != null : false;
  int get totalAddedStoresOnLastSelectedFriendGroup => hasSelectedAFriendGroup ? lastSelectedFriendGroup!.storesCount ?? 0 : 0;
  int get totalPlacedOrdersOnLastSelectedFriendGroup => hasSelectedAFriendGroup ? lastSelectedFriendGroup!.ordersCount ?? 0 : 0;
  int get totalAddedFriendsOnLastSelectedFriendGroup => hasSelectedAFriendGroup ? lastSelectedFriendGroup!.friendsCount ?? 0 : 0;
  bool get isCreatorOfLastSelectedFriendGroup => hasSelectedAFriendGroup ? lastSelectedFriendGroup!.attributes.userFriendGroupAssociation!.isCreator : false;
  bool get hasCompletedMilestones => isCreatorOfLastSelectedFriendGroup && hasAddedFriendsOnLastSelectedFriendGroup && hasAddedStoresOnLastSelectedFriendGroup;
  bool get isCreatorOrAdminOfLastSelectedFriendGroup => hasSelectedAFriendGroup ? lastSelectedFriendGroup!.attributes.userFriendGroupAssociation!.isCreatorOrAdmin : false;
  bool get hasJoinedLastSelectedFriendGroupLessThan24HoursAgo => hasSelectedAFriendGroup ? lastSelectedFriendGroup!.attributes.userFriendGroupAssociation!.createdAt.isAfter(DateTime.now().subtract(const Duration(days: 1))) : false;

  Future<dio.Response?> Function() get onRequestShowResourceTotals => widget.onRequestShowResourceTotals;

  final GlobalKey<StoreCardsState> _storeCardsState = GlobalKey<StoreCardsState>();
  final GlobalKey<FriendGroupsModalBottomSheetState> _friendGroupsModalBottomSheetState = GlobalKey<FriendGroupsModalBottomSheetState>();
  final GlobalKey<FriendGroupStoresModalBottomSheetState> _friendGroupStoresModalBottomSheetState = GlobalKey<FriendGroupStoresModalBottomSheetState>();
  final GlobalKey<FriendGroupFriendsModalBottomSheetState> _friendGroupFriendsModalBottomSheetState = GlobalKey<FriendGroupFriendsModalBottomSheetState>();
  final GlobalKey<CreateOrUpdateFriendGroupModalBottomSheetState> _createOrUpdateFriendGroupModalBottomSheetState = GlobalKey<CreateOrUpdateFriendGroupModalBottomSheetState>();
  final GlobalKey<FriendGroupOrdersInHorizontalListViewInfiniteScrollState> _friendGroupOrdersInHorizontalListViewInfiniteScrollState = GlobalKey<FriendGroupOrdersInHorizontalListViewInfiniteScrollState>();


  void _startRequestResourceTotalsLoader() { if(mounted) setState(() => isLoadingResourceTotals = true); }
  void _stopRequestResourceTotalsLoader() { if(mounted) setState(() => isLoadingResourceTotals = false); }
  void _startLastSelectedFriendGroupLoader() { if(mounted) setState(() => isLoadingLastSelectedFriendGroup = true); }
  void _stopLastSelectedFriendGroupLoader() { if(mounted) setState(() => isLoadingLastSelectedFriendGroup = false); }

  @override
  void initState() {
    super.initState();
    authUser = authProvider.user!;
    friendGroupProvider = Provider.of<FriendGroupProvider>(context, listen: false);

    // Register the observer to detect app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
    
  }

  @override
  void dispose() {
    super.dispose();

    /**
     *  We need to unset the friend group so that when we navigate to a different home tab
     *  e.g "Following", we do not have a reference of this friend group on the menus of 
     *  each store card on the "Following" home tab. Since the friend group was set here,
     *  it makes sense to clean up by unsetting before leaving the groups page content
     *  so that the friendGroupRepository is restored to the way it was before.
     */
    friendGroupProvider.unsetFriendGroup();

    // Remove the observer to detect app lifecycle changes
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {

    /**
     *  Once the user returns we want to refresh the state of the friend group incase
     *  anything has changed e.g The group has members or stores
     */
    if (state == AppLifecycleState.resumed) {

      _onRequestShowResourceTotals();
      _showLastSelectedFriendGroup();

    }

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    print('stage 1');
    
    /// Get the authenticated user's resource totals
    final ResourceTotals? updateResourceTotals = Provider.of<AuthProvider>(context, listen: false).resourceTotals;

    if(mounted && resourceTotals == null && updateResourceTotals != null) {

      setState(() {

        /// Update the local resourceTotals
        resourceTotals = updateResourceTotals;

        /// If we have one or more groups joined
        if(hasOneGroupJoined || hasManyGroupsJoined) {

          /// Get the last selected friend group
          _showLastSelectedFriendGroup();

        }else{
            
          /// Set the "isLoadingLastSelectedFriendGroupForTheFirstTime = false",
          /// so that we don't cause the ready loaded UI to disapper when
          /// loading the last selected group for the first time.
          isLoadingLastSelectedFriendGroupForTheFirstTime = false;

        }

      });
      
    }
    
  }

  void _showLastSelectedFriendGroup() {

    _startLastSelectedFriendGroupLoader();

    if(isLoadingLastSelectedFriendGroupForTheFirstTime == null) {

      if(mounted) setState(() => isLoadingLastSelectedFriendGroupForTheFirstTime = true);

    }

    friendGroupProvider.friendGroupRepository.showLastSelectedFriendGroup(
      withCountFriends: true,
      withCountStores: true,
      withCountOrders: true,
      withCountUsers: false
    ).then((response) {

      if(mounted) {
        
        setState(() {

          if(isLoadingLastSelectedFriendGroupForTheFirstTime != false) {

            isLoadingLastSelectedFriendGroupForTheFirstTime = false;

          }

          if(response.statusCode == 200) {

            final bool friendGroupExists = response.data['exists'];

            if(friendGroupExists) {
                
              final FriendGroup lastSelectedFriendGroup = FriendGroup.fromJson(response.data['friendGroup']);

              _onSelectedFriendGroup(lastSelectedFriendGroup);

            }

          }

        });

      }

    }).catchError((error) {

      printError(info: error.toString());

      SnackbarUtility.showErrorMessage(message: 'Failed to show group');

    }).whenComplete(() {

      _stopLastSelectedFriendGroupLoader();

    });

  }

  Widget get _hasCompletedMilestones {
    return Column(
      children: [

        /// If Created This Last Selected Friend Group Less Than 24 Hours Ago
        if(/* isCreatorOfLastSelectedFriendGroup && hasJoinedLastSelectedFriendGroupLessThan24HoursAgo */ true) ...[

          /// Instruction Note
          Container(
            margin: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              children: [
          
                /// Title
                CustomTitleMediumText('Perfect, ${authUser.firstName} 👌', margin: const EdgeInsets.only(bottom: 8),),
          
                /// Congratulations Note
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'Congratulations 👏 your group is ready 🎉 You and friends can start placing orders. Add more ', 
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(height: 1.4),
                    children: [
                      TextSpan(
                        text: 'stores',
                        recognizer: TapGestureRecognizer()..onTap = () {
                          openStoresModalBottomSheet();
                        },
                        style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline, color: Colors.green)
                      ),
                      const TextSpan(text: ' and invite more '),
                      TextSpan(
                        text: 'friends',
                        recognizer: TapGestureRecognizer()..onTap = () {
                          openFriendsModalBottomSheet();
                        },
                        style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline, color: Colors.green)
                      ),
                    ]
                  )
                ),
          
              ],
            )
          ),

          /// Spacer
          const SizedBox(height: 16),

        ],

        /// If Created This Last Selected Friend Group More Than 24 Hours Ago
        if(/* isCreatorOfLastSelectedFriendGroup && !hasJoinedLastSelectedFriendGroupLessThan24HoursAgo */true) ...[

          /// Instruction Note
          GestureDetector(
            onTap: () {
              openFriendGroupsModalBottomSheet();
            },
            child: Container(
              margin: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: RichText(
                textAlign: TextAlign.left,
                text: TextSpan(
                  text: 'Hey ${authUser.firstName}, you have ',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(height: 1.4),
                  children: [
                    TextSpan(
                      text: '$totalGroupsJoined ${totalGroupsJoined == 1 ? 'group' : 'groups'}',
                      style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline, color: Colors.green)
                    ),
                  ]
                )
              ),
            ),
          ),

          /// Spacer
          const SizedBox(height: 16),

        ],

        /// If Has Not Created A Friend Group
        if(/* !hasGroupsJoinedAsCreator */true) ...[

          /// Instruction Note
          CreateOrUpdateFriendGroupModalBottomSheet(
            onCreatedFriendGroup: _onCreatedFriendGroup,
            trigger: (openBottomModalSheet) => Container(
              margin: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: RichText(
                textAlign: TextAlign.left,
                text: TextSpan(
                  text: 'Hey ${authUser.firstName}, create your ',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(height: 1.4),
                  children: const [
                    TextSpan(
                      text: 'first group',
                      style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline, color: Colors.green)
                    ),
                    TextSpan(text: ' and start supporting your favourite sellers with your friends 😎 It\'s so easy'),
                  ]
                )
              ),
            ),
          ),

          /// Spacer
          const SizedBox(height: 16),

        ],

        /// Selected Friend Group Card
        selectedFriendGroupCard,
                          
        /// Spacer
        const SizedBox(height: 4),
            
        if(lastSelectedFriendGroupHasDescription) ...[
            
          /// Friend Group Description
          CustomBodyText(
            lightShade: true,
            textAlign: TextAlign.center,
            lastSelectedFriendGroup!.description,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          ),
            
        ],

        /// Friend Group Statistics
        friendGroupStatistics,

        if(hasPlacedAnOrderOnLastSelectedFriendGroup) ...[

          /// Spacer
          const SizedBox(height: 16),

          /// Friend Group Orders In Horizontal List View Infinite Scroll
          friendGroupOrdersInHorizontalListViewInfiniteScroll,

        ],

        if(hasAddedStoresOnLastSelectedFriendGroup) ...[

          /// Spacer
          const SizedBox(height: 16),

          /// Friend Group Stores In Vertical List View Infinite Scroll
          friendGroupStoreCards,


        ],

        if(!hasAddedFriendsOnLastSelectedFriendGroup) ...[

          /// Spacer
          const SizedBox(height: 16),

          _noFriendGroupFriendsFound,

        ],

        if(!hasAddedStoresOnLastSelectedFriendGroup) ...[

          /// Spacer
          const SizedBox(height: 16),

          _noFriendGroupStoresFound,

        ],

        /// Spacer
        const SizedBox(height: 16),

      ]
    );
  }

  Widget get _noFriendGroupFriendsFound {
    return GestureDetector(
      onTap: openFriendsModalBottomSheet,
      child: RichText(
        text: TextSpan(
          text: 'No friends invited - ',
          style: Theme.of(context).textTheme.bodyMedium,
          children: const [
            TextSpan(
              text: 'add friends',
              style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)
            ),
          ]
        )
      ),
    );
  }

  Widget get _noFriendGroupStoresFound {
    return GestureDetector(
      onTap: openStoresModalBottomSheet,
      child: RichText(
        text: TextSpan(
          text: 'No stores added - ',
          style: Theme.of(context).textTheme.bodyMedium,
          children: const [
            TextSpan(
              text: 'add stores',
              style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)
            ),
          ]
        )
      ),
    );
  }

  Widget get _hasNotCompletedMilestones {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
      child: Column(
        children: [
    
          /// Title
          const CustomTitleMediumText('How Groups Work', margin: EdgeInsets.only(top: 32),),
    
          Stack(
            children: [
              
              _milestones,
    
            ],
          ),

          /// NOTE THAT THE INVITAITONS WILL GO HERE
          /// NOTE THAT THE INVITAITONS WILL GO HERE
          /// NOTE THAT THE INVITAITONS WILL GO HERE

          /// Group Image
          _groupImage,

          /// Spacer
          const SizedBox(height: 100),

        ]
      )
    );
  }

  Widget get selectedFriendGroupCard {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [

          /// Friend Group Emoji
          CreateOrUpdateFriendGroupModalBottomSheet(
            friendGroup: lastSelectedFriendGroup,
            onUpdatedFriendGroup: _onUpdatedFriendGroup,
            onDeletedFriendGroup: _onDeletedFriendGroup,
            trigger: (openBottomModalSheet) => GestureDetector(
              onTap: openBottomModalSheet,
              child: CustomBodyText(lastSelectedFriendGroup!.emoji, fontSize: 32),
            )
          ),
    
          /// Spacer
          const SizedBox(width: 8),
    
          Expanded(
            child: FriendGroupsModalBottomSheet(
              enableBulkSelection: false,
              purpose: Purpose.chooseFriendGroups,
              key: _friendGroupsModalBottomSheetState,
              onCreatedFriendGroup: (friendGroup) => _onCreatedFriendGroup(friendGroup, canClose: false),
              onUpdatedFriendGroup: (friendGroup) => _onUpdatedFriendGroup(friendGroup, canClose: false),
              onDeletedFriendGroup: (friendGroup) => _onDeletedFriendGroup(friendGroup, canClose: false),
              onSelectedFriendGroups: _onSelectedFriendGroups,
              trigger: (openBottomModalSheet) => Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      
                        AnimatedSize(
                          duration: const Duration(milliseconds: 500),
                          child: AnimatedSwitcher(
                            switchInCurve: Curves.easeIn,
                            switchOutCurve: Curves.easeOut,
                            duration: const Duration(milliseconds: 500),
                            child: CustomTitleSmallText(
                              key: ValueKey(lastSelectedFriendGroup!.name),
                              lastSelectedFriendGroup!.name
                            )
                          ),
                        ),
                      
                      
                        if(isLoadingLastSelectedFriendGroup) ...[

                          /// Loader
                          const CustomCircularProgressIndicator(size: 8, strokeWidth: 1),

                        ],
                      
                        if(!isLoadingLastSelectedFriendGroup) ...[

                          /// Arrow Icon
                          const Icon(Icons.arrow_drop_down_rounded, color: Colors.black),

                        ]
                      
                      ]
                  ),
                ),
              ),
            ),
          ),
    
          /// Spacer
          const SizedBox(width: 4),

          Row(
            children: [

              /// Edit Button - Create Or Update Friend Group Modal Bottom Sheet
              CreateOrUpdateFriendGroupModalBottomSheet(
                friendGroup: lastSelectedFriendGroup,
                onUpdatedFriendGroup: _onUpdatedFriendGroup,
                onDeletedFriendGroup: _onDeletedFriendGroup,
                trigger: (openBottomModalSheet) => GestureDetector(
                  onTap: openBottomModalSheet,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const  Icon(Icons.mode_edit_outlined, color: Colors.white, size: 16),
                  ),
                )
              ),
    
              /// Spacer
              const SizedBox(width: 4),

              /// Add Button - Create Or Update Friend Group Modal Bottom Sheet
              CreateOrUpdateFriendGroupModalBottomSheet(
                key: _createOrUpdateFriendGroupModalBottomSheetState,
                onCreatedFriendGroup: _onCreatedFriendGroup,
                trigger: (openBottomModalSheet) => CircleAvatar(
                  radius: 16,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const  Icon(Icons.add, color: Colors.white, size: 16),
                ),
              )

            ],
          )

        ],
      ),
    );
  }

  Widget get friendGroupStatistics {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Wrap(          
          children: [

            FriendGroupFriendsModalBottomSheet(
              onInvitedMembers: _onInvitedMembers,
              onRemovedMembers: _onRemovedMembers,
              friendGroup: lastSelectedFriendGroup!,
              key: _friendGroupFriendsModalBottomSheetState,
              trigger: (openBottomModalSheet) => CustomTitleAndNumberCard(
                title: totalAddedFriendsOnLastSelectedFriendGroup == 1 ? 'Friend' : 'Friends',
                number: totalAddedFriendsOnLastSelectedFriendGroup,
                isLoading: isLoadingLastSelectedFriendGroup,
                onTap: openBottomModalSheet,
              )
            ),

            FriendGroupStoresModalBottomSheet(
              onAddedStore: _onAddedStore,
              onRemovedStores: _onRemovedStores,
              friendGroup: lastSelectedFriendGroup!,
              key: _friendGroupStoresModalBottomSheetState,
              trigger: (openBottomModalSheet) => CustomTitleAndNumberCard(
                title: totalAddedStoresOnLastSelectedFriendGroup == 1 ? 'Store' : 'Stores',
                number: totalAddedStoresOnLastSelectedFriendGroup,
                isLoading: isLoadingLastSelectedFriendGroup,
                onTap: openBottomModalSheet,
              )
            ),

            /*
            OrdersModalBottomSheet(
              userOrderAssociation: UserOrderAssociation.customer,
              trigger: (openBottomModalSheet) => CustomTitleAndNumberCard(
                title: totalOrders == 1 ? 'Order' : 'Orders', 
                onTap: openBottomModalSheet,
                number: totalOrders,
              )
            ),

            ReviewsModalBottomSheet(
              userReviewAssociation: UserReviewAssociation.teamMember,
              trigger: (openBottomModalSheet) => CustomTitleAndNumberCard(
                title: totalReviews == 1 ? 'Review' : 'Reviews', 
                onTap: openBottomModalSheet,
                number: totalReviews,
              )
            ), 

            TeamMemberInvitationsModalBottomSheet(
              trigger: (openBottomModalSheet) => CustomTitleAndNumberCard(
                title: totalStoresInvitedToJoinAsTeamMember == 1 ? 'Invite' : 'Invites', 
                number: totalStoresInvitedToJoinAsTeamMember,
                onTap: openBottomModalSheet,
              )
            ), 

            SmsAlertModalBottomSheet(
              key: _smsAlertModalBottomSheetState,
              trigger: (openBottomModalSheet) => CustomTitleAndNumberCard(
                title: totalSmsAlertCredits == 1 ? 'SMS Alert' : 'SMS Alerts', 
                number: totalSmsAlertCredits,
                onTap: openBottomModalSheet,
              )
            ), 
            */

          ],
        ),
      ),
    );
  }

  Widget get friendGroupOrdersInHorizontalListViewInfiniteScroll {

    return SizedBox(
      width: double.infinity,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 500),
        child: FriendGroupOrdersInHorizontalListViewInfiniteScroll(
          friendGroup: lastSelectedFriendGroup!,
          orderContentType: OrderContentType.orderFullContent,
          userOrderAssociation: UserOrderAssociation.customerOrFriend,
          key: _friendGroupOrdersInHorizontalListViewInfiniteScrollState,
        ),
      ),
    );
  }

  Widget get friendGroupStoreCards {

    return StoreCards(
      key: _storeCardsState,
      showFirstRequestLoader: false,
      onCreatedOrder: _onCreatedOrder,
      friendGroup: lastSelectedFriendGroup,
      contentBeforeSearchBar: contentBeforeSearchBar,
      userAssociation: UserAssociation.friendGroupMember
    );
  }

  Widget contentBeforeSearchBar(bool isLoading, int totalStores) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: const [
          
          CustomBodyText(
            lightShade: true,
            'Local sellers we are following 💕',
            margin: EdgeInsets.only(bottom: 16.0),
          ),

        ]
      ),
    );
  }

  Widget get _milestones {
    return  Container(
      padding: const EdgeInsets.only(top: 16),
      child: Stack(
        children: [

          Column(
            children: [
    
              /// Create Group Milestone
              _addMilestone(
                number: 1,
                checked: hasSelectedAFriendGroup,
                content: createFriendGroupInstruction,
              ),
    
              /// Add Friends Milestone
              _addMilestone(
                number: 2,
                content: addFriendsInstruction,
                checked: hasAddedFriendsOnLastSelectedFriendGroup,
              ),
    
              /// Add Stores Milestone
              _addMilestone(
                number: 3,
                content: addStoresInstruction,
                checked: hasAddedStoresOnLastSelectedFriendGroup,
              ),
              
            ],
          ),

          if(isLoadingLastSelectedFriendGroup || isLoadingResourceTotals) Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: const BorderRadius.all(Radius.circular(16))
              ),
              child: const CustomCircularProgressIndicator(
                strokeWidth: 2,
                size: 16
              ),
            ),
          )
          
        ],
      ),
    );
  }

  Widget _addMilestone({ required bool checked, required int number, required dynamic content }) {

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.all(Radius.circular(16))
            ),
            child: checked 
            ? Icon(Icons.check_circle_sharp, size: 32, color: Colors.white.withOpacity(0.8))
            : Center(child: CustomTitleSmallText('$number', color: Colors.white,))
          ),
          const SizedBox(width: 16),
          content.runtimeType == String
            ? CustomBodyText(content)
            : content
        ],
      ),
    );

  }

  Widget get _groupImage {
    return Container(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20)
      ),
      alignment: Alignment.center,
      child: SizedBox(
        width: double.infinity,
        child: Image.asset('assets/images/friends_walking.jpeg')
      ),
    );
  }

  Widget get createFriendGroupInstruction {

    if(hasSelectedAFriendGroup) {

      return CreateOrUpdateFriendGroupModalBottomSheet(
        friendGroup: lastSelectedFriendGroup,
        onUpdatedFriendGroup: _onUpdatedFriendGroup,
        onDeletedFriendGroup: _onDeletedFriendGroup,
        trigger: (openBottomModalSheet) => GestureDetector(
          onTap: openBottomModalSheet,
          child: RichText(
            text: TextSpan(
              text: 'Created ',
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                TextSpan(
                  /// Show the group name with or without the group emoji
                  text: '${lastSelectedFriendGroup!.emoji == null ? '' : '${lastSelectedFriendGroup!.emoji}'}${lastSelectedFriendGroup!.name}',
                  style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline, color: Colors.green)
                ),
              ]
            )
          ),
        ),
      );

    }else{

      return CreateOrUpdateFriendGroupModalBottomSheet(
        onCreatedFriendGroup: _onCreatedFriendGroup,
        onDeletedFriendGroup: _onDeletedFriendGroup,
        trigger: (openBottomModalSheet) => GestureDetector(
          onTap: openBottomModalSheet,
          child: RichText(
            text: TextSpan(
              text: 'First ', 
              style: Theme.of(context).textTheme.bodyMedium,
              children: const [
                TextSpan(
                  text: 'create group',
                  style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)
                ),
              ]
            )
          ),
        ),
      );

    }

  }

  Widget get addFriendsInstruction {

    if(hasAddedFriendsOnLastSelectedFriendGroup) {

      return FriendGroupFriendsModalBottomSheet(
        onInvitedMembers: _onInvitedMembers,
        onRemovedMembers: _onRemovedMembers,
        friendGroup: lastSelectedFriendGroup!,
        trigger: (openBottomModalSheet) => GestureDetector(
          onTap: openBottomModalSheet,
          child: RichText(
            text: TextSpan(
              text: 'Added ', 
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                TextSpan(
                  text: '$totalAddedFriendsOnLastSelectedFriendGroup ${totalAddedFriendsOnLastSelectedFriendGroup == 1 ? 'friend' : 'friends'}',
                  style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline, color: Colors.green)
                ),
              ]
            )
          ),
        )
      );

    }else{

      final Widget instruction = RichText(
        text: TextSpan(
          text: 'Then ',
          style: Theme.of(context).textTheme.bodyMedium,
          children: const [
            TextSpan(
              text: 'add friends',
              style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)
            ),
          ]
        )
      );

      if(hasSelectedAFriendGroup) {

        return FriendGroupFriendsModalBottomSheet(
          onInvitedMembers: _onInvitedMembers,
          onRemovedMembers: _onRemovedMembers,
          friendGroup: lastSelectedFriendGroup!,
          trigger: (openBottomModalSheet) => GestureDetector(
            onTap: openBottomModalSheet,
            child: instruction,
          ),
        );

      }else{

        return GestureDetector(
          onTap: () {
            SnackbarUtility.showInfoMessage(message: 'Create your group first');
          },
          child: instruction,
        );

      }

    }

  }

  Widget get addStoresInstruction {

    if(hasAddedStoresOnLastSelectedFriendGroup) {

      return FriendGroupStoresModalBottomSheet(
        onAddedStore: _onAddedStore,
        onRemovedStores: _onRemovedStores,
        friendGroup: lastSelectedFriendGroup!,
        trigger: (openBottomModalSheet) => GestureDetector(
          onTap: openBottomModalSheet,
          child: RichText(
            text: TextSpan(
              text: 'Added ', 
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                TextSpan(
                  text: '$totalAddedStoresOnLastSelectedFriendGroup ${totalAddedStoresOnLastSelectedFriendGroup == 1 ? 'store' : 'stores'}',
                  style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline, color: Colors.green)
                ),
              ]
            )
          ),
        ),
      );

    }else{

      final Widget instruction = RichText(
        text: TextSpan(
          text: 'Now ',
          style: Theme.of(context).textTheme.bodyMedium,
          children: const [
            TextSpan(
              text: 'add stores',
              style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)
            ),
          ]
        )
      );

      if(hasSelectedAFriendGroup) {

        return FriendGroupStoresModalBottomSheet(
          onAddedStore: _onAddedStore,
          onRemovedStores: _onRemovedStores,
          friendGroup: lastSelectedFriendGroup!,
          trigger: (openBottomModalSheet) => GestureDetector(
            onTap: openBottomModalSheet,
            child: instruction,
          ),
        );

      }else{

        return GestureDetector(
          onTap: () {
            SnackbarUtility.showInfoMessage(message: 'Create your group first');
          },
          child: instruction,
        );

      }

    }

  }


  void openFriendGroupsModalBottomSheet() {
    _friendGroupsModalBottomSheetState.currentState?.openBottomModalSheet();
  }

  void openFriendsModalBottomSheet() {
    _friendGroupFriendsModalBottomSheetState.currentState?.openBottomModalSheet();
  }

  void openStoresModalBottomSheet() {
    _friendGroupStoresModalBottomSheetState.currentState?.openBottomModalSheet();
  }

  /// Called when the friend group is selected 
  void _onSelectedFriendGroups(List<FriendGroup> friendGroups) {
    if(friendGroups.isNotEmpty) {
      _onSelectedFriendGroup(friendGroups.first);
    }
  }

  /// Called when the friend group is selected 
  void _onSelectedFriendGroup(FriendGroup? friendGroup) {

    if(!mounted) return;

    setState(() {

      lastSelectedFriendGroup = friendGroup;
      friendGroup == null ? friendGroupProvider.unsetFriendGroup() : friendGroupProvider.setFriendGroup(friendGroup);

    });

  }

  void _onCreatedFriendGroup(FriendGroup createdFriendGroup, { canClose = true }) {

    if(canClose) Get.back();

    if(!mounted) return;

    _onSelectedFriendGroup(createdFriendGroup);
    _onRequestShowResourceTotals();
    _showLastSelectedFriendGroup();
  }

  void _onUpdatedFriendGroup(FriendGroup updatedFriendGroup, { canClose = true }) {

    if(canClose) Get.back();

    if(!mounted) return;

    setState(() {

      /// Update the original count of the friend group relationships
      /// since they are not provided on this updatedFriendGroup.
      updatedFriendGroup
        ..friendsCount = lastSelectedFriendGroup!.friendsCount
        ..storesCount = lastSelectedFriendGroup!.storesCount
        ..ordersCount = lastSelectedFriendGroup!.ordersCount;

      // Update last selected friend group
      _onSelectedFriendGroup(updatedFriendGroup);

      _onRequestShowResourceTotals();
      _showLastSelectedFriendGroup();

    });

  }

  void _onDeletedFriendGroup(FriendGroup deletedFriendGroup, { canClose = true }) {

    if(canClose) Get.back();

    if(!mounted) return;

    setState(() {

      _onRequestShowResourceTotals();
      _showLastSelectedFriendGroup();

    });

  }

  void _onInvitedMembers() {
    _showLastSelectedFriendGroup();
  }

  void _onRemovedMembers() {
    _showLastSelectedFriendGroup();
  }

  void _onAddedStore(ShoppableStore store) {
    _showLastSelectedFriendGroup();
    _refreshStores();
  }

  void _onRemovedStores(List<ShoppableStore> stores) {
    _showLastSelectedFriendGroup();
    _refreshStores();
  }

  void _onCreatedOrder(Order createdOrder) {
    _refreshOrders();
    _onRequestShowResourceTotals();
    _showLastSelectedFriendGroup();
  }

  void _refreshStores() {
    if(_storeCardsState.currentState != null) {
      _storeCardsState.currentState!.refreshStores();
    }
  }

  void _refreshOrders() {
    if(_friendGroupOrdersInHorizontalListViewInfiniteScrollState.currentState != null) {
      _friendGroupOrdersInHorizontalListViewInfiniteScrollState.currentState!.startRequest();
    }
  }

  void _onRequestShowResourceTotals() async {
    _startRequestResourceTotalsLoader();
    await onRequestShowResourceTotals();
    _stopRequestResourceTotalsLoader();
  }

  void _listenForAuthProviderChanges(BuildContext context) {

    /// Listen for changes on the AuthProvider so that we can know when the authProvider.resourceTotals have
    /// been updated. Once the authProvider.resourceTotals have been updated by the OrderPageContent Widget, 
    /// we can then use getter such as authProvider.hasStoresAsFollower to know whether this authenticated 
    /// user has stores that they are following.
    /// 
    /// Once these changes occur, we can use the didChangeDependencies() 
    /// to capture these changes and response accordingly
    Provider.of<AuthProvider>(context, listen: true);

  }

  @override
  Widget build(BuildContext context) {

    _listenForAuthProviderChanges(context);

    return SingleChildScrollView(
      child: SizedBox(
        width: double.infinity,
        child: AnimatedSize(
          duration: const Duration(milliseconds: 500),
          child: AnimatedSwitcher(
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            duration: const Duration(milliseconds: 500),
            child: doesNotHaveResourceTotals || isLoadingLastSelectedFriendGroupForTheFirstTime == true
              ? const CustomCircularProgressIndicator(
                  margin: EdgeInsets.symmetric(vertical: 100),
                  strokeWidth: 2,
                  size: 16
                )
              : Column(
                  children: [

                    /// Group Creation Milestones
                    if((hasOneGroupJoined && isCreatorOfLastSelectedFriendGroup && hasCompletedMilestones) || hasManyGroupsJoined) _hasCompletedMilestones,

                    /// Has Not Completed Everything Content 
                    if(hasNoGroupsJoined || (hasOneGroupJoined && isCreatorOfLastSelectedFriendGroup && !hasCompletedMilestones)) _hasNotCompletedMilestones

                  ]
                )
          )
        )
      ),
    );
  }
}