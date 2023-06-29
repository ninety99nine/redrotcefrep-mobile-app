import 'package:bonako_demo/core/shared_widgets/button/add_button.dart';
import 'package:bonako_demo/features/order_for/services/order_for_service.dart';

import '../../friends/widgets/friends_show/friends_modal_bottom_sheet/friends_modal_bottom_sheet.dart';
import 'order_for_users/order_for_users_modal_bottom_sheet/order_for_users_modal_bottom_sheet.dart';
import '../../../core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import '../../../core/shared_widgets/text/custom_title_small_text.dart';
import '../../../core/shared_widgets/checkbox/custom_checkbox.dart';
import '../../../core/shared_widgets/chips/custom_choice_chip.dart';
import '../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../core/shared_widgets/chips/custom_chip.dart';
import '../../authentication/providers/auth_provider.dart';
import '../../../core/utils/api_conflict_resolver.dart';
import '../../friend_groups/models/friend_group.dart';
import '../../stores/providers/store_provider.dart';
import '../../stores/models/shoppable_store.dart';
import '../../../core/shared_models/user.dart';
import '../../friends/enums/friend_enums.dart';
import '../../../core/utils/snackbar.dart';
import '../../../core/utils/dialog.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class OrderForDetails extends StatefulWidget {
  const OrderForDetails({super.key});

  @override
  State<OrderForDetails> createState() => _OrderForDetailsState();
}

class _OrderForDetailsState extends State<OrderForDetails> {
  
  ShoppableStore? store;
  bool isLoading = false;
  bool isLoadingTotalPeople = false;
  List<String> orderForOptions = [];
  bool friendsCanCollectOrder = true;
  final ApiConflictResolverUtility apiConflictResolverUtility = ApiConflictResolverUtility();
  
  bool get hasStore => store != null;
  User get user => authProvider.user!;
  
  String? get orderFor => store?.orderFor;
  bool get isOrderingForMe => orderFor == 'Me';
  int get totalPeople => store?.totalPeople ?? 1;
  List<User> get friends => store?.friends ?? [];
  int get totalFriendGroups => friendGroups.length;
  bool get hasSelectedFriends => friends.isNotEmpty;
  bool get hasShoppingCart => store?.hasShoppingCart ?? false;
  bool get hasSelectedFriendGroups => friendGroups.isNotEmpty;
  bool get isOrderingForFriendsOnly => orderFor == 'Friends Only';
  List<FriendGroup> get friendGroups => store?.friendGroups ?? [];
  bool get isOrderingForMeAndFriends => orderFor == 'Me And Friends';
  bool get hasSelectedProducts => store?.hasSelectedProducts ?? false;
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  bool get canCountShoppingCartOrderForUsersFromClientSide {

    final hasSelectedFriendsOnly = hasSelectedFriends && !hasSelectedFriendGroups;
    final hasSelectedFriendGroupsOnly = !hasSelectedFriends && hasSelectedFriendGroups;

    /// If ordering for "Me"
    if(isOrderingForMe) {

      /// Calculate client side
      return true;

    /// If ordering for "Me And Friends" or "Friends Only" and selected friends only
    }else if((isOrderingForMeAndFriends || isOrderingForFriendsOnly) && hasSelectedFriendsOnly) {

      /// Calculate client side
      return true;

    /// If ordering for "Me And Friends" or "Friends Only" and selected 1 friend group only
    }else if((isOrderingForMeAndFriends || isOrderingForFriendsOnly) && hasSelectedFriendGroupsOnly && totalFriendGroups == 1) {

      /// Calculate client side as long as the friend group's friend count is provided
      return friendGroups.where((friendGroup) => friendGroup.friendsCount != null).isNotEmpty;

    /// If ordering for "Me And Friends" or "Friends Only" and we haven't selected any friends or friend groups
    }else if((isOrderingForMeAndFriends || isOrderingForFriendsOnly) && !hasSelectedFriends && !hasSelectedFriendGroups) {
      
      /// Calculate client side
      return true;

    }else{

      /// Calculate server side
      return false;

    }

  }
  
  void _startLoader() => setState(() => isLoading = true);
  void _stopLoader() => setState(() => isLoading = false);
  
  void _startTotalPeopleLoader() => setState(() => isLoadingTotalPeople = true);
  void _stopTotalPeopleLoader() => setState(() => isLoadingTotalPeople = false);

  /// This allows us to access the state of CustomBottomModalSheet widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<FriendsModalBottomSheetState> friendsModalBottomSheetState = GlobalKey<FriendsModalBottomSheetState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    /// Get the updated Shoppable Store Model
    store = Provider.of<ShoppableStore>(context, listen: false);

    /// Get the order for options if not already requested
    if(hasStore && hasSelectedProducts && !isLoading && orderForOptions.isEmpty) _getStoreShoppingCartOrderForOptions();

    /// If the total people that this order is for has not been calculated
    if(hasSelectedProducts && !isLoadingTotalPeople && store!.totalPeople == null) {
      
      /// Calculate the total people that this order is for
      countShoppingCartOrderForUsers(canNotifyListeners: false);

    }

  }

  void _getStoreShoppingCartOrderForOptions() {

    _startLoader();

    /// Get the order for options stored on the device storage (client side)
    OrderForService.getOrderForOptionsFromDeviceStorage().then((savedOrderForOptions) {

      if(savedOrderForOptions.isEmpty) {

        /// Request the order for options (server side)
        storeProvider.setStore(store!).storeRepository.showShoppingCartOrderForOptions()
          .then((response) async {

          final responseBody = jsonDecode(response.body);

          if(response.statusCode == 200) {

            /// Set the order for options
            setState(() => orderForOptions = List.from(responseBody));

            /// Save the order for options on the device storage (client side)
            OrderForService.saveOrderForOptionsOnDeviceStorage(orderForOptions);

          }

        }).whenComplete(() {
          
          _stopLoader();

        });

      }else{

        /// Set the order for options
        setState(() => orderForOptions = savedOrderForOptions);

      }

    });

  }

  /// Count how many people we are ordering for server side
  void _requestCountShoppingCartOrderForUsers() async {

    /// The apiConflictResolverUtility resoloves the comflict of 
    /// retrieving data returned by the wrong request. Whenever
    /// we make multiple requests, we only ever want the data 
    /// of the last request and not any other request.
    apiConflictResolverUtility.addRequest(
      
      /// The request we are making
      onRequest: () => storeProvider.setStore(store!).storeRepository.countShoppingCartOrderForUsers(
        friends: friends,
        orderFor: orderFor!,
        friendGroups: friendGroups,
      ),
      
      /// The response returned by the last request
      onCompleted: (response) {

        if(!mounted) return;

        if(response.statusCode == 200) {

          final responseBody = jsonDecode(response.body);

          /// Set the total people
          setState(() => store!.setTotalPeople(responseBody['total']));

        }

      }, 
      
      /// What to do while the request is loading
      onStartLoader: () {
        /// On the next request continue showing the loader incase the previous request
        /// stopped the loader. This makes sure that the loader stays loading as long
        /// as we have a request executing.
        if(mounted) _startTotalPeopleLoader();
      },
      
      /// What to do when the request completes
      onStopLoader: () {
        if(mounted) _stopTotalPeopleLoader();
      }
      
    /// On Error
    ).catchError((e) {

      if(mounted) {

        SnackbarUtility.showErrorMessage(message: 'Can\'t calculate the total people ordering for');

      }

    });

  }

  /// Count how many people we are ordering for client side
  void countShoppingCartOrderForUsers({ canNotifyListeners = true}) {

    /// Check if we can count how many people we are ordering for from the client side
    if(canCountShoppingCartOrderForUsersFromClientSide) {

      /// Count how many people we are ordering for client side
      setState(() {
        
        if(isOrderingForMeAndFriends || isOrderingForFriendsOnly) {
              
            int totalFriends = friends.length;
            List<int> totalFriendsFromGroupsAsList = friendGroups.map((friendGroup) => friendGroup.friendsCount!).toList();
            int totalFriendsFromGroups = totalFriendsFromGroupsAsList.isEmpty ? 0 : totalFriendsFromGroupsAsList.reduce((int a, int b) => a + b);

            totalFriends = totalFriends + totalFriendsFromGroups;

            int totalPeople = isOrderingForMeAndFriends ? totalFriends + 1 : totalFriends;

            store!.setTotalPeople(totalPeople, canNotifyListeners: canNotifyListeners);

          }else{
            
            store!.setTotalPeople(1, canNotifyListeners: canNotifyListeners);

          }

      });

    /// If we can count how many people we are ordering for from the server side
    }else{

      /// Count how many people we are ordering for from the server side
      _requestCountShoppingCartOrderForUsers();

    }
  }

  /// Called to set the selected order for option
  void selectOrderFor(String orderFor) {

    setState(() => store!.orderFor = orderFor);
    
    /// Count how many people we are ordering for
    countShoppingCartOrderForUsers();

  }

  /// Called to check if we can open the friends modal bottom sheet
  bool canOpenFriendsModalBottomSheet(String option) {
    return ['Me And Friends', 'Friends Only'].contains(option);
  }

  /// Called to open the friends modal bottom sheet
  void openFriendsModalBottomSheet() {
    if(friendsModalBottomSheetState.currentState == null) return;
    friendsModalBottomSheetState.currentState!.openBottomModalSheet();
  }

  void removeFriend(User friend) async {
    
    final bool? confirmation = await confirmAction('Are you sure you want to remove ${friend.attributes.name}?');

    if(confirmation == true) {

      setState(() {
        
        friends.removeWhere((existingFriend) => existingFriend.id == friend.id);

        /// Auto select "Me" option when no friends or friend groups are selected
        autoSelectMeOnNoFriendsOrFriendGroup();
        
        /// Count how many people we are ordering for
        if(isOrderingForMe == false) countShoppingCartOrderForUsers();

      });

    }
    
  }

  void removeFriendGroup(FriendGroup friendGroup) async {
    
    final bool? confirmation = await confirmAction('Are you sure you want to remove ${friendGroup.name}?');

    if(confirmation == true) {

      setState(() {
        
        friendGroups.removeWhere((existingFriendGroup) => existingFriendGroup.id == friendGroup.id);

        /// Auto select "Me" option when no friends or friend groups are selected
        autoSelectMeOnNoFriendsOrFriendGroup();
        
        /// Count how many people we are ordering for
        if(isOrderingForMe == false) countShoppingCartOrderForUsers();

      });

    }
    
  }

  Future<bool?> confirmAction(String message) {
    return DialogUtility.showConfirmDialog(
      content: message,
      context: context
    );
  }
  
  /// Called when the friends are selected
  void onDoneSelectingFriends(List<User> friends) {
    setState(() {

      /// Remove already selected friends
      friends.removeWhere((friend) {
        return this.friends.map((existingFriend) => existingFriend.id).contains(friend.id);
      });

      /// Add friends
      this.friends.addAll(friends);
        
      /// Count how many people we are ordering for
      countShoppingCartOrderForUsers();

    });
  }
  
  /// Called when the friend groups are selected
  void onDoneSelectingFriendGroups(List<FriendGroup> friendGroups) {
    setState(() {

      /// Remove already selected friend groups
      friendGroups.removeWhere((friendGroup) {
        return this.friendGroups.map((existingFriendGroup) => existingFriendGroup.id).contains(friendGroup.id);
      });

      /// Add friend groups
      this.friendGroups.addAll(friendGroups);
        
      /// Count how many people we are ordering for
      countShoppingCartOrderForUsers();

    });
  }

  /// Called to automatically select the "Me" option 
  /// when no friends or friend groups are selected
  void autoSelectMeOnNoFriendsOrFriendGroup() {

    /// If we have not selected any friends or friend groups
    if(!hasSelectedFriends && !hasSelectedFriendGroups) {

      /// Indicate that we want to order for "Me" instead of 
      /// "Me And Friends" or "Friends Only"
      selectOrderFor('Me');

    }

  }

  Widget get orderingForTotalPeopleLoader {
    return const CustomCircularProgressIndicator(
      size: 8, 
      strokeWidth: 1,
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.only(top: 8, bottom: 8, left: 8),
    );
  }

  Widget get orderingForTotalPeople {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [

        /// Ordering for "X" people
        Container(
          margin: const EdgeInsets.only(top: 8, bottom: 8, left: 8),
          child: CustomBodyText('Ordering for $totalPeople ${totalPeople == 1 ? 'person' : 'people'}')
        ),

        /// Spacer
        const SizedBox(width: 4,),

        /// View Users Button
        if(hasStore && (hasSelectedFriends || hasSelectedFriendGroups)) OrderForUsersModalBottomSheet(
          store: store!
        ),

      ],
    );
  }

  Widget get friendsCanCollectCheckbox {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: CustomCheckbox(
        text: 'My friends can collect this order',
        value: friendsCanCollectOrder,
        onChanged: (status) {    
          setState(() => friendsCanCollectOrder = status ?? false);
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    /// Capture the store that was passed on ListenableProvider.value()
    /// of the StoreCard. This store is accessible if the StoreCard is
    /// an ancestor of this ShoppableProductCards. We can use this shoppable 
    /// store instance for shopping purposes e.g selecting this
    /// product so that we can place an order.
    store = Provider.of<ShoppableStore>(context, listen: true);
    
    return AnimatedSize(
      duration: const Duration(milliseconds: 500),
      child: SizedBox(
        width: double.infinity,
        child: AnimatedSwitcher(
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          duration: const Duration(milliseconds: 500),
          child:
            hasSelectedProducts == false
            ? null
            : Column(
              children: [

                /// Spacer
                const SizedBox(height: 8),
                
                /// Title
                const CustomTitleSmallText('Ordering For'),

                /// Spacer
                const SizedBox(height: 8),

                /// Order For Options (Me | Me And Friends | Friends Only | Business)
                ClipRRect(
                  clipBehavior: Clip.antiAlias,
                  borderRadius: BorderRadius.circular(24),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.start,
                      alignment: WrapAlignment.start,
                      spacing: 8,
                      children: [
                        ...orderForOptions.map((option) {
                  
                          final selected = orderFor == option;

                            /// Return this choice chip option
                            return CustomChoiceChip(
                              label: option,
                              selected: selected,
                              selectedColor: Colors.green.shade700,
                              onSelected: (_) {
                                  
                                selectOrderFor(option);

                                /// If we can open the friends modal bottom sheet and 
                                /// we have not selected any friends or friend groups
                                if(canOpenFriendsModalBottomSheet(option) && !(hasSelectedFriends || hasSelectedFriendGroups)) {
                                  
                                  openFriendsModalBottomSheet();
                                
                                }
                                
                              }
                            );
                  
                        })
                      ],
                    ),
                  ),
                ),

                /// Spacer
                const SizedBox(height: 8),

                /// Ordering For "X" People
                if(isOrderingForMe || isOrderingForMeAndFriends || isOrderingForFriendsOnly) ...[

                  AnimatedSize(
                    duration: const Duration(milliseconds: 500),
                    child: SizedBox(
                      width: double.infinity,
                      child: AnimatedSwitcher(
                        switchInCurve: Curves.easeIn,
                        switchOutCurve: Curves.easeOut,
                        duration: const Duration(milliseconds: 500),
                        child: isLoadingTotalPeople ? orderingForTotalPeopleLoader : orderingForTotalPeople
                      )
                    )
                  )

                ],
                
                /// Me | Friends | Friend Groups
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    runAlignment: WrapAlignment.center,
                    spacing: 8,
                    children: [
                      
                      /// Me Chip
                      if(isOrderingForMe || (isOrderingForMeAndFriends && isOrderingForFriendsOnly)) CustomChip(
                        labelWidget: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomBodyText(user.attributes.name, fontWeight: FontWeight.bold),
                          ],
                        ),
                      ),
                
                      /// List Selected Friends Chips
                      if(isOrderingForMeAndFriends || isOrderingForFriendsOnly) ...friends.map((friend) {
                
                        return GestureDetector(
                          onTap: () => removeFriend(friend),
                          child: CustomChip(
                            labelWidget: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomBodyText(friend.attributes.name),
                                const SizedBox(width: 4,),
                                Icon(Icons.cancel, color: Colors.grey.shade400,)
                              ],
                            ),
                          ),
                        );
                
                      }).toList(),
                
                      /// List Selected Friend Groups Chips
                      if(isOrderingForMeAndFriends || isOrderingForFriendsOnly) ...friendGroups.map((friendGroup) {
                
                        return GestureDetector(
                          onTap: () => removeFriendGroup(friendGroup),
                          child: CustomChip(
                            labelWidget: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomBodyText(friendGroup.name),
                                const SizedBox(width: 4,),
                                Icon(Icons.cancel, color: Colors.grey.shade400,)
                              ],
                            ),
                          ),
                        );
                
                      }).toList(),
                
                      /// Button To Add More Friends
                      AddButton(
                        onTap: openFriendsModalBottomSheet,
                        visible: isOrderingForMeAndFriends || isOrderingForFriendsOnly,
                      ),

                      if((isOrderingForMeAndFriends || isOrderingForFriendsOnly) && (hasSelectedFriends || hasSelectedFriendGroups)) ...[


                        /// Message Alert: Friends Can Also Collect This Order
                        friendsCanCollectCheckbox,

                      ],
                
                    ],
                  ),
                ),
                
                /// Friends Modal Bottom Sheet
                FriendsModalBottomSheet(
                  onSelectedFriendGroups: (_) {},
                  key: friendsModalBottomSheetState,
                  purpose: Purpose.addFriendsToOrder,
                  onClose: autoSelectMeOnNoFriendsOrFriendGroup,
                  onDoneSelectingFriends: onDoneSelectingFriends,
                  onDoneSelectingFriendGroups: onDoneSelectingFriendGroups,
                )

              ],
            )
        ),
      ),
    );
  }
}