import 'package:bonako_demo/core/shared_widgets/button/custom_elevated_button.dart';
import 'package:bonako_demo/core/utils/snackbar.dart';
import 'package:bonako_demo/features/friend_groups/widgets/friend_group_create_or_update/friend_group_create_or_update_card.dart';
import 'package:bonako_demo/features/orders/models/order.dart';
import 'package:bonako_demo/features/orders/widgets/orders_show/friend_group_orders_in_horizontal_list_view_infinite_scroll.dart';
import 'package:bonako_demo/features/search/widgets/search_show/search_modal_bottom_sheet/search_modal_bottom_sheet.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import 'package:bonako_demo/features/stores/providers/store_provider.dart';
import 'package:get/get.dart';
import '../../../friend_groups/widgets/friend_groups_show/friend_groups_modal_bottom_sheet/friend_groups_modal_bottom_sheet.dart';
import '../../../../core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import '../../../../core/shared_widgets/text/custom_title_small_text.dart';
import '../../../friend_groups/repositories/friend_group_repository.dart';
import '../../../friend_groups/providers/friend_group_provider.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../friend_groups/enums/friend_group_enums.dart';
import '../../../stores/widgets/store_cards/store_cards.dart';
import '../../../../features/stores/enums/store_enums.dart';
import '../../../friend_groups/models/friend_group.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class GroupsPageContent extends StatefulWidget {
  const GroupsPageContent({super.key});

  @override
  State<GroupsPageContent> createState() => _GroupsPageContentState();
}

class _GroupsPageContentState extends State<GroupsPageContent> with SingleTickerProviderStateMixin {
  
  bool isLoading = false;
  FriendGroup? friendGroup;
  bool isAddingStore = false;

  late FriendGroupProvider friendGroupProvider;
  bool get hasFriendGroup => friendGroup != null;
  
  final GlobalKey<StoreCardsState> storeCardsState = GlobalKey<StoreCardsState>();
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  FriendGroupRepository get friendGroupRepository => friendGroupProvider.friendGroupRepository;
  final GlobalKey<FriendGroupOrdersInHorizontalListViewInfiniteScrollState> friendGroupOrdersInHorizontalListViewInfiniteScrollState = GlobalKey<FriendGroupOrdersInHorizontalListViewInfiniteScrollState>();

  void _startLoader() => setState(() => isLoading = true);
  void _stopLoader() => setState(() => isLoading = false);

  void _startAddStoreLoader() => setState(() => isAddingStore = true);
  void _stopAddStoreLoader() => setState(() => isAddingStore = false);

  @override
  void initState() {
    super.initState();
    setFriendGroupProvider();
    _requestShowLastSelectedFriendGroup();
  }

  @override
  void dispose() {
    /**
     *  We need to unset the friend group so that when we navigate to a different home tab
     *  e.g "Following", we do not have a reference of this friend group on the menus of 
     *  each store card on the "Following" home tab. Since the friend group was set here,
     *  it makes sense to clean up by unsetting before leaving the groups page content
     *  so that the friendGroupRepository is restored to the way it was before.
     */
    friendGroupProvider.unsetFriendGroup();
    super.dispose();
  }

  void setFriendGroupProvider() {

    /**
     * Note that we are deliberately setting the FriendGroupProvider this way instead of using a getter 
     * as we normally do. This is because we need to use the friendGroupProvider from the dispose() 
     * method to unsetFriendGroup(). This causes an error when the friendGroupProvider is declared 
     * as a getter method. To prevent this we must declare this on the initState() method so that 
     * the friendGroupProvider can then be used at the dispose() method without any errors. The 
     * Flutter error is as follows:
     * 
     * "Looking up a deactivated widget's ancestor is unsafe: At this point the state of the widget's 
     * element tree is no longer stable. To safely refer to a widget's ancestor in its dispose() 
     * method, save a reference to the ancestor by calling dependOnInheritedWidgetOfExactType() 
     * in the widget's didChangeDependencies() method."
     * 
     * Reference of related issue: 
     * 
     * https://stackoverflow.com/questions/69282208/looking-up-a-deactivated-widgets-ancestor-is-unsafe-navigator-ofcontext-push#:~:text=To%20safely%20refer%20to%20a,Navigator.
     */
    friendGroupProvider = Provider.of<FriendGroupProvider>(context, listen: false);
  }

  void _requestShowLastSelectedFriendGroup() async {

    _startLoader();

    friendGroupRepository.showLastSelectedFriendGroup(
      context: context,
    ).then((response) {

      final responseBody = jsonDecode(response.body);

      if(response.statusCode == 200) {

        if(responseBody != null) {

          friendGroup = FriendGroup.fromJson(responseBody);
          friendGroupProvider.setFriendGroup(friendGroup!);

        }

      }

    }).whenComplete(() {
      _stopLoader();
    });

  }

  void _requestAddStoreToFriendGroups(ShoppableStore store) {
    
    _startAddStoreLoader();

    storeProvider.setStore(store).storeRepository.addStoreToFriendGroups(
      friendGroups: [friendGroup!],
    ).then((response) {

      final responseBody = jsonDecode(response.body);

      if(response.statusCode == 200) {

        SnackbarUtility.showSuccessMessage(message: responseBody['message']);
        refreshStores();

      }

    }).catchError((error) {

      SnackbarUtility.showErrorMessage(message: 'Failed to add to group');

    }).whenComplete((){

      _stopAddStoreLoader();

    });
  }

  void refreshStores() {
    if(storeCardsState.currentState != null) {
      storeCardsState.currentState!.refreshStores();
    }
  }

  void refreshOrders() {
    if(friendGroupOrdersInHorizontalListViewInfiniteScrollState.currentState != null) {
      friendGroupOrdersInHorizontalListViewInfiniteScrollState.currentState!.startRequest();
    }
  }

  /// Called when the friend group is selected 
  void onSelectedFriendGroups(List<FriendGroup> friendGroups) {
    if(friendGroups.isNotEmpty) {
      setState(() {
        final FriendGroup friendGroup = friendGroups.first;
        friendGroupProvider.setFriendGroup(friendGroup);
        this.friendGroup = friendGroup;
      });
    }
  }

  void onCreatedFriendGroup() {
    _requestShowLastSelectedFriendGroup();
  }

  void onCreatedOrder(Order order) {
    refreshOrders();
  }

  Widget get storeCards {
    return StoreCards(
      key: storeCardsState,
      friendGroup: friendGroup,
      onCreatedOrder: onCreatedOrder,
      contentBeforeSearchBar: contentBeforeSearchBar,
      userAssociation: UserAssociation.friendGroupMember,
    );
  }

  Widget contentBeforeSearchBar(bool isLoading, int totalStores) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        /// Friend Group Create Card
        FriendGroupCreateOrUpdateCard(
          hasFriendGroup: hasFriendGroup,
          onCreatedFriendGroup: onCreatedFriendGroup,
        ),
        
        /// Instruction
        const CustomBodyText(
          'Get something 👌 for your group',
        ),

        /// Spacer
        const SizedBox(height: 8,),

        /// Group Card
        groupCard,

        /// Spacer
        const SizedBox(height: 8,),

        /// Group Card
        orderCards(totalStores),

        /// Spacer
        const SizedBox(height: 8,),

        /// Add Store Button
        if(totalStores > 0) Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: addStoreButton
        ),
        
        /// No Stores
        if(totalStores == 0) noStores

      ],
    );
  }

  Widget get groupCard {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0)
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          key: ValueKey(friendGroup!.name),
                          friendGroup!.name, margin: const EdgeInsets.only(bottom: 5)
                        )
                      ),
                    ),

                  ],
                ),

                /// Friend Groups Modal Bottom Sheet (Used to change the Friend Group)
                FriendGroupsModalBottomSheet(
                  enableBulkSelection: false,
                  purpose: Purpose.chooseFriendGroups,
                  onSelectedFriendGroups: onSelectedFriendGroups,
                )

              ]
          ),
        ),
      ),
    );
  }
  
  Widget orderCards(int totalStores) {

    /// Don't show the no orders widget when we don't have stores and orders (Only show it when we have stores but not orders)
    final Widget? noContentWidget = totalStores == 0 ? Container() : null;

    return SizedBox(
      width: double.infinity,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 500),
        child: FriendGroupOrdersInHorizontalListViewInfiniteScroll(
          key: friendGroupOrdersInHorizontalListViewInfiniteScrollState,
          noContentWidget: noContentWidget,
          friendGroup: friendGroup!,
        ),
      ),
    );
  }

  Widget get addStoreButton {

    return SearchModalBottomSheet(
      showFilters: false,
      showExpandIconButton: false,
      onSelectedStore: _requestAddStoreToFriendGroups,
      trigger: (openBottomModalSheet) => CustomElevatedButton(
        '+ Add Store',
        disabled: isAddingStore,
        isLoading: isAddingStore,
        alignment: Alignment.center,
        onPressed: () => openBottomModalSheet(),
      ),
    );

  }
  
  Widget get noStores {
      
    return Column(
      children: [

        //  Image
        SizedBox(
          height: 300,
          child: Image.asset('assets/images/groups/4.png'),
        ),

        /// Spacer
        const SizedBox(height: 20,),

        /// Instruction
        const CustomBodyText(
          'Great! Now you and your friends can start adding stores and placing orders here',
          padding: EdgeInsets.symmetric(horizontal: 32),
          textAlign: TextAlign.center,
        ),

        /// Spacer
        const SizedBox(height: 16,),

        /// Add Store Button
        addStoreButton,

        /// Spacer
        const SizedBox(height: 100,),

      ],
    );

  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
    
        /// Loader
        if(isLoading) const Expanded(child: CustomCircularProgressIndicator()),

        /// Friend Group Create Card
        if(!isLoading && !hasFriendGroup) FriendGroupCreateOrUpdateCard(
          hasFriendGroup: hasFriendGroup,
          onCreatedFriendGroup: onCreatedFriendGroup,
        ),

        /// Friend Group Store Cards
        if(!isLoading && hasFriendGroup) Expanded(child: storeCards)

      ],
    );
  }
}
