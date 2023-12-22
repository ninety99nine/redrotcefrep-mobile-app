import 'package:bonako_demo/features/friend_groups/widgets/create_or_update_friend_group/create_or_update_friend_group_modal_bottom_sheet/create_or_update_friend_group_modal_bottom_sheet.dart';
import 'package:bonako_demo/features/friend_groups/widgets/friend_group_friends/friend_group_friends_modal_bottom_sheet/friend_group_friends_modal_bottom_sheet.dart';
import 'package:bonako_demo/features/friend_groups/widgets/friend_group_stores/friend_group_stores_modal_bottom_sheet/friend_group_stores_modal_bottom_sheet.dart';
import 'package:bonako_demo/features/friend_groups/widgets/friend_groups_show/friend_groups_modal_bottom_sheet/friend_groups_modal_bottom_sheet.dart';
import 'package:bonako_demo/features/chat/widgets/ai_chat_modal_bottom_sheet/ai_chat_modal_bottom_sheet.dart';
import 'package:bonako_demo/core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import 'package:bonako_demo/core/shared_widgets/cards/custom_title_and_number_card.dart';
import 'package:bonako_demo/features/friend_groups/providers/friend_group_provider.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_medium_text.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:bonako_demo/features/authentication/providers/auth_provider.dart';
import 'package:bonako_demo/features/friend_groups/enums/friend_group_enums.dart';
import 'package:bonako_demo/features/friend_groups/models/friend_group.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import 'package:bonako_demo/features/user/models/resource_totals.dart';
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
  FriendGroup? firstCreatedFriendGroup;
  FriendGroup? lastSelectedFriendGroup;
  bool isLoadingFirstCreatedFriendGroup = false;
  bool isLoadingLastSelectedFriendGroup = false;
  bool? isLoadingLastSelectedFriendGroupForTheFirstTime;
  bool? isLoadingFirstCreatedFriendGroupForTheFirstTime;

  bool get hasResourceTotals => resourceTotals != null;
  bool get doesNotHaveResourceTotals => resourceTotals == null;
  bool get hasCreatedAFriendGroup => firstCreatedFriendGroup != null;
  bool get hasSelectedAFriendGroup => lastSelectedFriendGroup != null;
  Function(int) get onChangeNavigationTab => widget.onChangeNavigationTab;
  
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
  int get totalGroupsJoined => hasResourceTotals ? resourceTotals!.totalGroupsJoined : 0;
  bool get hasCompletedEverything => hasCreatedAFriendGroup && hasAddedFriendsOnFirstCreatedFriendGroup && hasAddedStoresOnFirstCreatedFriendGroup;

  bool get hasAddedStoresOnFirstCreatedFriendGroup => totalAddedStoresOnFirstCreatedFriendGroup > 0;
  bool get hasAddedFriendsOnFirstCreatedFriendGroup => totalAddedFriendsOnFirstCreatedFriendGroup > 0;
  bool get hasPlacedAnOrderOnFirstCreatedFriendGroup => totalPlacedOrdersOnFirstCreatedFriendGroup > 0;
  int get totalAddedStoresOnFirstCreatedFriendGroup => hasCreatedAFriendGroup ? firstCreatedFriendGroup!.storesCount ?? 0 : 0;
  int get totalPlacedOrdersOnFirstCreatedFriendGroup => hasCreatedAFriendGroup ? firstCreatedFriendGroup!.ordersCount ?? 0 : 0;
  int get totalAddedFriendsOnFirstCreatedFriendGroup => hasCreatedAFriendGroup ? firstCreatedFriendGroup!.friendsCount ?? 0 : 0;

  bool get hasAddedStoresOnLastSelectedFriendGroup => totalAddedStoresOnLastSelectedFriendGroup > 0;
  bool get hasAddedFriendsOnLastSelectedFriendGroup => totalAddedFriendsOnLastSelectedFriendGroup > 0;
  bool get hasPlacedAnOrderOnLastSelectedFriendGroup => totalPlacedOrdersOnLastSelectedFriendGroup > 0;
  int get totalAddedStoresOnLastSelectedFriendGroup => hasSelectedAFriendGroup ? lastSelectedFriendGroup!.storesCount ?? 0 : 0;
  int get totalPlacedOrdersOnLastSelectedFriendGroup => hasSelectedAFriendGroup ? lastSelectedFriendGroup!.ordersCount ?? 0 : 0;
  int get totalAddedFriendsOnLastSelectedFriendGroup => hasSelectedAFriendGroup ? lastSelectedFriendGroup!.friendsCount ?? 0 : 0;

  Future<dio.Response?> Function() get onRequestShowResourceTotals => widget.onRequestShowResourceTotals;
  FriendGroupProvider get friendGroupProvider => Provider.of<FriendGroupProvider>(context, listen: false);
  
  bool get hasGroupsJoined => hasResourceTotals ? resourceTotals!.totalGroupsJoined > 0 : false;
  bool get hasGroupsJoinedManyGroups => hasResourceTotals ? resourceTotals!.totalGroupsJoined > 1 : false;
  bool get hasGroupsJoinedAsCreator => hasResourceTotals ? resourceTotals!.totalGroupsJoinedAsCreator > 0 : false;
  bool get hasGroupsJoinedAsNonCreator => hasResourceTotals ? resourceTotals!.totalGroupsJoinedAsNonCreator > 0 : false;
  bool get hasGroupsInvitedToJoinAsGroupMember => hasResourceTotals ? resourceTotals!.totalGroupsInvitedToJoinAsGroupMember > 0 : false;
  bool get hasJoinedFirstCreatedFriendGroupLessThan24HoursAgo => hasCreatedAFriendGroup ? firstCreatedFriendGroup!.attributes.userFriendGroupAssociation!.createdAt.isAfter(DateTime.now().subtract(const Duration(days: 1))) : false;

  final GlobalKey<CreateOrUpdateFriendGroupModalBottomSheetState> _createOrUpdateFriendGroupModalBottomSheetState = GlobalKey<CreateOrUpdateFriendGroupModalBottomSheetState>();

  void _startRequestResourceTotalsLoader() => setState(() => isLoadingResourceTotals = true);
  void _stopRequestResourceTotalsLoader() => setState(() => isLoadingResourceTotals = false);
  void _startFirstCreatedFriendGroupLoader() => setState(() => isLoadingFirstCreatedFriendGroup = true);
  void _stopFirstCreatedFriendGroupLoader() => setState(() => isLoadingFirstCreatedFriendGroup = false);
  void _startLastSelectedFriendGroupLoader() => setState(() => isLoadingLastSelectedFriendGroup = true);
  void _stopLastSelectedFriendGroupLoader() => setState(() => isLoadingLastSelectedFriendGroup = false);

  @override
  void initState() {
    super.initState();
    authUser = authProvider.user!;

    // Register the observer to detect app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
    
  }

  @override
  void dispose() {
    super.dispose();

    // Remove the observer to detect app lifecycle changes
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {

    /**
     *  Once the user returns we want to refresh the state of the friend group incase
     *  anything has changed e.g The group has members
     */
    if (state == AppLifecycleState.resumed) {

      _showFirstCreatedFriendGroup();
      _showLastSelectedFriendGroup();

    }

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    /// Get the authenticated user's resource totals
    final ResourceTotals? updateResourceTotals = Provider.of<AuthProvider>(context, listen: false).resourceTotals;

    if(updateResourceTotals != null) {

      setState(() {

        /// Update the local resourceTotals
        resourceTotals = updateResourceTotals;

        /// If we have joined a group as a creator and that is the only group we have
        if(hasGroupsJoinedAsCreator && totalGroupsJoined == 1) {

          /// Get the first created friend group
          _showFirstCreatedFriendGroup();

        /// If we have joined more than one group
        }else if(totalGroupsJoined > 1) {

          /// Get the last selected friend group
          _showLastSelectedFriendGroup();

        }else{

          setState(() {
            
            /// Set these to true so that we don't cause the ready loaded UI to
            /// disapper when loading the first created or last selected group.
            isLoadingLastSelectedFriendGroupForTheFirstTime = false;
            isLoadingFirstCreatedFriendGroupForTheFirstTime = false;

          });

        }

      });
      
    }
    
  }

  void _showFirstCreatedFriendGroup() {

    _startFirstCreatedFriendGroupLoader();

    if(isLoadingFirstCreatedFriendGroupForTheFirstTime == null) {
      setState(() => isLoadingFirstCreatedFriendGroupForTheFirstTime = true);
    }

    authProvider.userRepository.showFirstCreatedFriendGroup(
      withCountFriends: true,
      withCountStores: true,
      withCountOrders: true,
      withCountUsers: false
    ).then((response) {

      setState(() {

        isLoadingFirstCreatedFriendGroupForTheFirstTime = false;

        if(response.statusCode == 200) {

          final bool friendGroupExists = response.data['exists'];

          if(friendGroupExists) {
              
            /// Set the this response data as the first created friend group
            firstCreatedFriendGroup = FriendGroup.fromJson(response.data['friendGroup']);

            /// Set this first created friend group to also be the last selected friend group
            lastSelectedFriendGroup = firstCreatedFriendGroup;

          }

        }

      });

    }).catchError((error) {

      printError(info: error.toString());

      SnackbarUtility.showErrorMessage(message: 'Failed to show your first group');

    }).whenComplete(() {

      _stopFirstCreatedFriendGroupLoader();

    });

  }

  void _showLastSelectedFriendGroup() {

    _startLastSelectedFriendGroupLoader();

    if(isLoadingLastSelectedFriendGroupForTheFirstTime == null) {
      setState(() => isLoadingLastSelectedFriendGroupForTheFirstTime = true);
    }

    friendGroupProvider.friendGroupRepository.showLastSelectedFriendGroup(
      withCountFriends: true,
      withCountStores: true,
      withCountOrders: true,
      withCountUsers: false
    ).then((response) {

      setState(() {

        isLoadingLastSelectedFriendGroupForTheFirstTime = false;

        if(response.statusCode == 200) {

          final bool friendGroupExists = response.data['exists'];

          if(friendGroupExists) {
              
            lastSelectedFriendGroup = FriendGroup.fromJson(response.data['friendGroup']);

          }

        }

      });

    }).catchError((error) {

      printError(info: error.toString());

      SnackbarUtility.showErrorMessage(message: 'Failed to show your first group');

    }).whenComplete(() {

      _stopLastSelectedFriendGroupLoader();

    });

  }

  Widget get _completedEverythingContent {
    return Column(
      children: [

        /// If Created A Friend Group Less Than 24 Hours Ago
        if(/*hasCreatedAFriendGroup && hasJoinedFirstCreatedFriendGroupLessThan24HoursAgo*/ true) ...[

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
                          /// DialerUtility.dial(number: mobileNumberShortcode);
                        },
                        style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline, color: Colors.green)
                      ),
                      const TextSpan(text: ' and invite more '),
                      TextSpan(
                        text: 'friends',
                        recognizer: TapGestureRecognizer()..onTap = () {
                          /// DialerUtility.dial(number: mobileNumberShortcode);
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

        /// If Created A Friend Group More Than 24 Hours Ago
        if(/*hasCreatedAFriendGroup && !hasJoinedFirstCreatedFriendGroupLessThan24HoursAgo*/true) ...[

          /// Instruction Note
          Container(
            margin: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: GestureDetector(
              onTap: () {
                /// DialerUtility.dial(number: mobileNumberShortcode);
              },
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
        if(/*!hasCreatedAFriendGroup*/true) ...[

          /// Instruction Note
          GestureDetector(
            onTap: () {
              /// DialerUtility.dial(number: mobileNumberShortcode);
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
                  text: 'Hey ${authUser.firstName}, create your ',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(height: 1.4),
                  children: [
                    TextSpan(
                      text: 'first group',
                      recognizer: TapGestureRecognizer()..onTap = () {
                        /// openCreateStoreModalBottomSheet();
                      },
                      style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline, color: Colors.green)
                    ),
                    const TextSpan(text: ' and start supporting your favourite sellers with your friends 😎 It\'s so easy'),
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

        /// Order And Review Statistics
        orderAndReviewStatistics,

        /// Spacer
        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            /// AI Chat Button (Need Advice?) 
            const AiChatModalBottomSheet(),

            /// Spacer
            const SizedBox(width: 8),

            /// Create Or Update Friend Group Modal Bottom Sheet
            CreateOrUpdateFriendGroupModalBottomSheet(
              key: _createOrUpdateFriendGroupModalBottomSheetState,
              onCreatedFriendGroup: _onCreatedFriendGroup,
              trigger: (openBottomModalSheet) =>  IconButton(
                icon: const Icon(Icons.add_circle_rounded), 
                onPressed: openBottomModalSheet,
                iconSize: 40
              )
            )

          ],
        ),

        /// Spacer
        const SizedBox(height: 16),

      ]
    );
  }

  Widget get _hasNotCompletedEverythingContent {
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
            onUpdatedFriendGroup: _onUpdateFriendGroup,
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
              onSelectedFriendGroups: onSelectedFriendGroups,
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
                      
                        Row(
                          children: [
                      
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                
                                /// Friend Group Name
                                AnimatedSize(
                                  duration: const Duration(milliseconds: 500),
                                  child: AnimatedSwitcher(
                                    switchInCurve: Curves.easeIn,
                                    switchOutCurve: Curves.easeOut,
                                    duration: const Duration(milliseconds: 500),
                                    child: CustomTitleSmallText(
                                      key: ValueKey(lastSelectedFriendGroup!.name),
                                      lastSelectedFriendGroup!.name, margin: const EdgeInsets.only(bottom: 5)
                                    )
                                  ),
                                ),
                      
                              ],
                            ),
                          ],
                        ),
                      
                        /// Friend Groups Modal Bottom Sheet (Used to change the Friend Group)
                        const Icon(Icons.arrow_drop_down_rounded, color: Colors.black),
                      
                      ]
                  ),
                ),
              ),
            ),
          ),
    
          /// Spacer
          const SizedBox(width: 8),

          /// Edit Button
          CreateOrUpdateFriendGroupModalBottomSheet(
            friendGroup: lastSelectedFriendGroup,
            onUpdatedFriendGroup: _onUpdateFriendGroup,
            trigger: (openBottomModalSheet) => GestureDetector(
              onTap: openBottomModalSheet,
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).primaryColor,
                child: const  Icon(Icons.mode_edit_outlined, color: Colors.white, size: 16),
              ),
            )
          )

        ],
      ),
    );
  }

  /// Called when the friend group is selected 
  void onSelectedFriendGroups(List<FriendGroup> friendGroups) {
    if(friendGroups.isNotEmpty) {
      setState(() {
        final FriendGroup friendGroup = friendGroups.first;
        friendGroupProvider.setFriendGroup(friendGroup);
        lastSelectedFriendGroup = friendGroup;
      });
    }
  }

  Widget get orderAndReviewStatistics {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Wrap(          
          children: [

            FriendGroupFriendsModalBottomSheet(
              friendGroup: lastSelectedFriendGroup!,
              trigger: (openBottomModalSheet) => CustomTitleAndNumberCard(
                title: totalAddedFriendsOnLastSelectedFriendGroup == 1 ? 'Friend' : 'Friends',
                number: totalAddedFriendsOnLastSelectedFriendGroup,
                onTap: openBottomModalSheet,
              )
            ),

            FriendGroupStoresModalBottomSheet(
              friendGroup: lastSelectedFriendGroup!,
              trigger: (openBottomModalSheet) => CustomTitleAndNumberCard(
                title: totalAddedStoresOnLastSelectedFriendGroup == 1 ? 'Store' : 'Stores',
                number: totalAddedStoresOnLastSelectedFriendGroup,
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
                checked: hasCreatedAFriendGroup,
                content: createFriendGroupInstruction,
              ),
    
              /// Add Friends Milestone
              _addMilestone(
                number: 2,
                content: addFriendsInstruction,
                checked: hasAddedFriendsOnFirstCreatedFriendGroup,
              ),
    
              /// Add Stores Milestone
              _addMilestone(
                number: 3,
                content: addStoresInstruction,
                checked: hasAddedStoresOnFirstCreatedFriendGroup,
              ),
              
            ],
          ),

          if(isLoadingFirstCreatedFriendGroup || isLoadingResourceTotals) Positioned(
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

    if(hasCreatedAFriendGroup) {

      return CreateOrUpdateFriendGroupModalBottomSheet(
        friendGroup: firstCreatedFriendGroup,
        onUpdatedFriendGroup: _onUpdateFriendGroup,
        trigger: (openBottomModalSheet) => GestureDetector(
          onTap: openBottomModalSheet,
          child: RichText(
            text: TextSpan(
              text: 'Created ',
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                TextSpan(
                  /// Show the group name with or without the group emoji
                  text: '${firstCreatedFriendGroup!.emoji == null ? '' : '${firstCreatedFriendGroup!.emoji}'}${firstCreatedFriendGroup!.name}',
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

  void _onCreatedFriendGroup(FriendGroup createdFriendGroup) {
    Get.back();
    _showFirstCreatedFriendGroup();
    _onRequestShowResourceTotals();
    setState(() => firstCreatedFriendGroup = createdFriendGroup);
  }

  void _onUpdateFriendGroup(FriendGroup updatedFriendGroup) {
    Get.back();
    _showFirstCreatedFriendGroup();
    _onRequestShowResourceTotals();
    setState(() => firstCreatedFriendGroup = updatedFriendGroup);
  }

  void _onRequestShowResourceTotals() async {
    _startRequestResourceTotalsLoader();
    await onRequestShowResourceTotals();
    _stopRequestResourceTotalsLoader();
  }

  Widget get addFriendsInstruction {

    if(hasAddedFriendsOnFirstCreatedFriendGroup) {

      return FriendGroupFriendsModalBottomSheet(
        onInvitedMembers: _onInvitedMembers,
        onRemovedMembers: _onRemovedMembers,
        friendGroup: firstCreatedFriendGroup!,
        trigger: (openBottomModalSheet) => GestureDetector(
          onTap: openBottomModalSheet,
          child: RichText(
            text: TextSpan(
              text: 'Added ', 
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                TextSpan(
                  text: '$totalAddedFriendsOnFirstCreatedFriendGroup ${totalAddedFriendsOnFirstCreatedFriendGroup == 1 ? 'friend' : 'friends'}',
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

      if(hasCreatedAFriendGroup) {

        /// FriendGroupFriendsModalBottomSheet
        return FriendGroupFriendsModalBottomSheet(
          onInvitedMembers: _onInvitedMembers,
          onRemovedMembers: _onRemovedMembers,
          friendGroup: firstCreatedFriendGroup!,
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

  void _onInvitedMembers() {
    _showFirstCreatedFriendGroup();
  }

  void _onRemovedMembers() {
    _showFirstCreatedFriendGroup();
  }

  Widget get addStoresInstruction {

    if(hasAddedStoresOnFirstCreatedFriendGroup) {

      return FriendGroupStoresModalBottomSheet(
        onAddedStore: _onAddedStore,
        onRemovedStores: _onRemovedStores,
        friendGroup: firstCreatedFriendGroup!,
        trigger: (openBottomModalSheet) => GestureDetector(
          onTap: openBottomModalSheet,
          child: RichText(
            text: TextSpan(
              text: 'Added ', 
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                TextSpan(
                  text: '$totalAddedStoresOnFirstCreatedFriendGroup ${totalAddedStoresOnFirstCreatedFriendGroup == 1 ? 'store' : 'stores'}',
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

      if(hasCreatedAFriendGroup) {

        /// FriendGroupStoresModalBottomSheet
        return FriendGroupStoresModalBottomSheet(
          onAddedStore: _onAddedStore,
          onRemovedStores: _onRemovedStores,
          friendGroup: firstCreatedFriendGroup!,
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

  void _onAddedStore(ShoppableStore store) {
    _showFirstCreatedFriendGroup();
  }

  void _onRemovedStores(List<ShoppableStore> stores) {
    _showFirstCreatedFriendGroup();
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
            child: doesNotHaveResourceTotals || isLoadingFirstCreatedFriendGroupForTheFirstTime == true || isLoadingLastSelectedFriendGroupForTheFirstTime == true
              ? const CustomCircularProgressIndicator(
                  margin: EdgeInsets.symmetric(vertical: 100),
                  strokeWidth: 2,
                  size: 16
                )
              : Column(
                  children: [

                    /// Completed Everything Content
                    if(hasCompletedEverything || hasGroupsJoinedAsNonCreator || hasGroupsJoinedManyGroups) _completedEverythingContent,

                    /// Has Not Completed Everything Content
                    if(!hasCompletedEverything && !hasGroupsJoinedAsNonCreator && !hasGroupsJoinedManyGroups) _hasNotCompletedEverythingContent

                  ]
                )
          )
        )
      ),
    );
  }
}