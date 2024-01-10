import 'package:bonako_demo/features/stores/widgets/store_cards/store_card/primary_section_content/store_logo.dart';
import 'package:bonako_demo/core/shared_widgets/text_form_field/custom_mobile_number_text_form_field.dart';
import '../../../../core/shared_widgets/infinite_scroll/custom_vertical_list_view_infinite_scroll.dart';
import 'package:bonako_demo/features/user/widgets/user_profile_photo/user_profile_photo.dart';
import '../../../../core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import 'package:bonako_demo/core/shared_widgets/button/custom_elevated_button.dart';
import 'package:bonako_demo/core/shared_models/friend_group_store_association.dart';
import 'package:bonako_demo/features/rating/widgets/rating_show_using_stars.dart';
import 'package:bonako_demo/features/contacts/widgets/contacts_modal_popup.dart';
import 'package:bonako_demo/features/api/repositories/api_repository.dart';
import '../../../../core/shared_widgets/text/custom_title_small_text.dart';
import 'package:bonako_demo/features/stores/providers/store_provider.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import 'package:bonako_demo/core/constants/constants.dart' as constants;
import 'package:bonako_demo/features/api/providers/api_provider.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/stores/enums/store_enums.dart';
import 'package:bonako_demo/core/utils/api_conflict_resolver.dart';
import '../../../authentication/providers/auth_provider.dart';
import 'package:bonako_demo/core/utils/mobile_number.dart';
import 'package:bonako_demo/core/utils/debouncer.dart';
import '../../providers/friend_group_provider.dart';
import '../../../../core/shared_models/user.dart';
import '../../../../core/utils/snackbar.dart';
import '../../../../core/utils/dialog.dart';
import 'package:provider/provider.dart';
import '../../models/friend_group.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';

class FriendGroupStoresInVerticalListViewInfiniteScroll extends StatefulWidget {

  final FriendGroup friendGroup;
  final String friendGroupStoreFilter;
  final Function(ShoppableStore)? onAddedStore;
  final Function(String) changeFriendGroupStoreFilter;
  final Function(List<ShoppableStore>)? onRemovedStores;

  const FriendGroupStoresInVerticalListViewInfiniteScroll({
    super.key,
    this.onAddedStore,
    this.onRemovedStores,
    required this.friendGroup,
    required this.friendGroupStoreFilter,
    required this.changeFriendGroupStoreFilter,
  });

  @override
  State<FriendGroupStoresInVerticalListViewInfiniteScroll> createState() => _FriendGroupStoresInVerticalListViewInfiniteScrollState();
}

class _FriendGroupStoresInVerticalListViewInfiniteScrollState extends State<FriendGroupStoresInVerticalListViewInfiniteScroll> {
  
  User? searchedUser;
  int? addingStoreId;
  int? lastAddedStoreId;
  bool isAddingStore = false;
  String? selectedContactName;
  bool isLoadingStores = false;
  bool isSearchingUser = false;
  bool isRemovingStores = false;
  int totalAddedSharedStores = 0;
  List<int> removingStoreIds = [];
  int totalUnaddedSharedStores = 0;
  List<int> lastRemovedStoreIds = [];
  bool isLoadingUserSharedStores = false;
  List<ShoppableStore> sharedStores = [];
  final FocusNode _focusNode = FocusNode();
  TextEditingController searchedMobileNumberController = TextEditingController();
  final DebouncerUtility debouncerUtility = DebouncerUtility(milliseconds: 1000);
  final ApiConflictResolverUtility apiConflictResolverUtility = ApiConflictResolverUtility();

  User get authUser => authProvider.user!;
  bool get hasSearchedUser => searchedUser != null;
  FriendGroup get friendGroup => widget.friendGroup;
  bool get hasSharedStores => sharedStores.isNotEmpty;
  ApiRepository get apiRepository => apiProvider.apiRepository;
  Function(ShoppableStore)? get onAddedStore => widget.onAddedStore;
  String get friendGroupStoreFilter => widget.friendGroupStoreFilter;
  bool get hasCompleteMobileNumber => searchedMobileNumber.length == 8;
  String get searchedMobileNumber => searchedMobileNumberController.text;
  Function(List<ShoppableStore>)? get onRemovedStores => widget.onRemovedStores;
  ApiProvider get apiProvider => Provider.of<ApiProvider>(context, listen: false);
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  Function(String) get changeFriendGroupStoreFilter => widget.changeFriendGroupStoreFilter;
  bool get authIsCreatorOrAdmin => friendGroup.attributes.userFriendGroupAssociation!.isCreatorOrAdmin;
  FriendGroupProvider get friendGroupProvider => Provider.of<FriendGroupProvider>(context, listen: false);

  void _startAddStoreLoader() => setState(() => isAddingStore = true);
  void _stopAddStoreLoader() => setState(() => isAddingStore = false);
  void _startSearchUserLoader() => setState(() => isSearchingUser = true);
  void _stopSearchUserLoader() => setState(() => isSearchingUser = false);
  void _startRemoveStoresLoader() => setState(() => isRemovingStores = true);
  void _stopRemoveStoresLoader() => setState(() => isRemovingStores = false);
  void _startUserSharedStoresLoader() => setState(() => isLoadingUserSharedStores = true);
  void _stopUserSharedStoresLoader() => setState(() => isLoadingUserSharedStores = false);

  /// This allows us to access the state of CustomVerticalListViewInfiniteScroll widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomVerticalListViewInfiniteScrollState> _customVerticalListViewInfiniteScrollState = GlobalKey<CustomVerticalListViewInfiniteScrollState>();

  @override
  void didUpdateWidget(covariant FriendGroupStoresInVerticalListViewInfiniteScroll oldWidget) {
    super.didUpdateWidget(oldWidget);

    /// If the friend group store filter changed
    if(friendGroupStoreFilter != oldWidget.friendGroupStoreFilter) {

      //  Refresh the stores list
      refreshStores();

    }
  }

  @override
  void dispose() {
    super.dispose();
    searchedMobileNumberController.dispose();
  }

  /// Render each request item as an StoreItem
  Widget onRenderItem(store, int index, List stores, bool isSelected, List selectedItems, bool hasSelectedItems, int totalSelectedItems) {

    final bool isRemovingStore = removingStoreIds.contains(store.id);

    return StoreItem(
      authIsCreatorOrAdmin: authIsCreatorOrAdmin,
      requestRemoveStores: requestRemoveStores,
      toggleSelection: toggleSelection,
      isRemovingStore: isRemovingStore,
      isLoadingStores: isLoadingStores,
      store: (store as ShoppableStore),
      isSelected: isSelected,
    );

  }
  
  /// Parse each request item as a ShoppableStore
  ShoppableStore onParseItem(store) => ShoppableStore.fromJson(store);

  /// Condition to determine whether to add or remove the
  /// specified store from the list of selected stores
  bool toggleSelectionCondition(alreadySelectedItem, currSelectedItem) {

    final ShoppableStore alreadySelectedStore = alreadySelectedItem as ShoppableStore;
    final ShoppableStore currSelectedFriend = currSelectedItem as ShoppableStore;
    return alreadySelectedStore.id == currSelectedFriend.id;
    
  }

  Widget selectedAllAction(isLoading) {

    const Widget nothing = SizedBox();
    const Widget removeIcon = Icon(Icons.delete_rounded, color: Colors.red);

    /// Remove Icon
    return GestureDetector(
      onTap: () {
        requestRemoveStores();
      },
      child: (isAddingStore || isRemovingStores) ? nothing : removeIcon
    );

  }

  /// Request Friend Group Stores
  Future<dio.Response> requestFriendGroupStores(int page, String searchWord) {
    return friendGroupProvider.setFriendGroup(friendGroup).friendGroupRepository.showFriendGroupStores(
      filter: friendGroupStoreFilter,
      withCountReviews: true,
      withCountOrders: true,
      withRating: true,
      page: page
    );
  }

  /// Update the loading store status
  void onLoading(bool status) {
    /// setState(() => isLoadingStores = status);
  }

  /// Toggle the selection of the specified store
  void toggleSelection(ShoppableStore store) {
    if(!isLoadingStores && !isRemovingStores && authIsCreatorOrAdmin) {
      _customVerticalListViewInfiniteScrollState.currentState?.toggleSelection(store);
    }
  }

  /// Hide the keypad
  void hideKeypad() {
    _focusNode.unfocus();
  }

  /// Refresh the list of stores
  void refreshStores() {
     _customVerticalListViewInfiniteScrollState.currentState?.startRequest();
  }

  /// Reset the searched user
  void resetSearchedUser() {
    setState(() => searchedUser = null);
  }

  /// Reset the search for the user shared stores
  void resetSearchForUserSharedStores() {
    setState(() {
      searchedMobileNumberController.text = '';
      searchedUser = null;
      sharedStores = [];
    });
  }

  /// Request to search user by mobile number
  void requestSearchUserByMobileNumber() {
      
    /**
     *  Using Debouncer to delay the request until user has stopped
     *  interacting with the mobile number text form field for 
     *  one second
     */
    debouncerUtility.run(() async {

      /// The apiConflictResolverUtility resoloves the comflict of 
      /// retrieving data returned by the wrong request. Whenever
      /// we make multiple requests, we only ever want the data 
      /// of the last request and not any other request.
      apiConflictResolverUtility.addRequest(
        
        /// The request we are making
        onRequest: () => apiRepository.post(
          url: apiProvider.apiHome!.links.searchUserByMobileNumber,
          body: {
            'mobile_number': MobileNumberUtility.addMobileNumberExtension(searchedMobileNumber)
          }
        ),
        
        /// The response returned by the last request
        onCompleted: (response) {

          if(!mounted) return;

          if( response.statusCode == 200 ) {

            setState(() {

              if(response.data['exists']) {

                /// Capture the searched user
                searchedUser = User.fromJson(response.data['user']);
                        
                /// Start the loader immediately since the debouncerUtility() of the requestShowUserSharedStores() 
                /// method applies a delay. The delay causes the loader to appear after sometime which is undesirable
                _startUserSharedStoresLoader();
                requestShowUserSharedStores();

              }else{

                resetSearchedUser();

              }

            });

          }

        }, 
        
        /// What to do while the request is loading
        onStartLoader: () {
          /// On the next request continue showing the loader incase the previous request
          /// stopped the loader. This makes sure that the loader stays loading as long
          /// as we have a request executing.
          if(mounted) _startSearchUserLoader();
        },
        
        /// What to do when the request completes
        onStopLoader: () {
          if(mounted) _stopSearchUserLoader();
        }

      /// On Error
      ).catchError((e) {

        if(mounted) {

          SnackbarUtility.showErrorMessage(message: 'Can\'t show seller profile');

        }

        return e;

      });

    });

  }


  /// Request to show user shared stores
  void requestShowUserSharedStores() {
      
    /**
     *  Using Debouncer to delay the request until user has stopped
     *  interacting with the shopping cart for one second
     */
    debouncerUtility.run(() async {

      /// The apiConflictResolverUtility resoloves the comflict of 
      /// retrieving data returned by the wrong request. Whenever
      /// we make multiple requests, we only ever want the data 
      /// of the last request and not any other request.
      apiConflictResolverUtility.addRequest(
        
        /// onRequest(): The request we are making
        /// 
        /// Notice that we have set "withFriendGroupStoreAssociation = true". This will allow the request to return
        /// each store while additionally eager loading the friend group association. This means that each store
        /// will return a friend group association if it exists or null if it does not exist. The friend group
        /// association helps to know if that particular store has been added to the list of the fried group
        /// stores. In order to eager load the friend group association, we also need to specify the exact
        /// friend group that these stores must be associated with by specifying the friendGroup. See
        /// that "friendGroup: friendGroup" has been provided to indicate that exact friend group
        /// that we want to scope the association. When the friend group and store association
        /// exists, then we will know that that store has been added to the friend group.
        onRequest: () => storeProvider.storeRepository.showUserStores(
          userAssociation: UserAssociation.assigned,
          withFriendGroupStoreAssociation: true,
          friendGroup: friendGroup,
          withCountReviews: true,
          withCountOrders: true,
          user: searchedUser!,
          withRating: true,
        ),
        
        /// onCompleted(): The response returned by the last request
        onCompleted: (response) {

          if(!mounted) return;

          if( response.statusCode == 200 ) {

            setState(() {

              sharedStores = (response.data['data'] as List).map((store) {
                return ShoppableStore.fromJson(store);
              }).toList();

              /// Set the total added shared stores
              totalAddedSharedStores = sharedStores.where((sharedStore) => sharedStore.attributes.friendGroupStoreAssociation != null).length;

              /// Set the total unadded shared stores
              totalUnaddedSharedStores = sharedStores.where((sharedStore) => sharedStore.attributes.friendGroupStoreAssociation == null).length;

            });

          }

        }, 
        
        /// What to do while the request is loading
        onStartLoader: () {
          /// On the next request continue showing the loader incase the previous request
          /// stopped the loader. This makes sure that the loader stays loading as long
          /// as we have a request executing.
          if(mounted) _startUserSharedStoresLoader();
        },
        
        /// What to do when the request completes
        onStopLoader: () {
          if(mounted) _stopUserSharedStoresLoader();
        }

      /// On Error
      ).catchError((e) {

        if(mounted) {

          SnackbarUtility.showErrorMessage(message: 'Can\'t show shared stores');

        }

        return e;

      });

    });

  }

  /// Request to add the specified store
  void requestAddStore({ required ShoppableStore store }) async {

    if(isLoadingStores) return;

    _startAddStoreLoader();

    /// Set the store id of the store that we are adding
    setState(() => addingStoreId = store.id);

    friendGroupProvider.friendGroupRepository.addFriendGroupStores(
      stores: [store]
    ).then((response) async {

      if(response.statusCode == 200) {

        /// Notify parent widget
        if(onAddedStore != null) onAddedStore!(store);

        SnackbarUtility.showSuccessMessage(message: response.data['message']);

        /// Increment the number of total added shared stores
        totalAddedSharedStores += 1;

        /// Decrement the number of total added shared stores
        totalUnaddedSharedStores -= 1;

        /// If we have no unadded shared stores
        if(totalUnaddedSharedStores == 0) {
          
          /// Reset the shared stores
          //  resetSearchForUserSharedStores();

        }

        /// Set the store id of the last store to be added
        setState(() => lastAddedStoreId = addingStoreId);

        /// Reset the store id of the store that we are adding
        setState(() => addingStoreId = null);

        if(friendGroupStoreFilter == 'All') {

          /// Refresh the list of stores
          refreshStores();

        }else{
          
          /// Change the friend group store filter to show all stores
          changeFriendGroupStoreFilter('All');

        }

      }

    }).catchError((error) {

      printError(info: error.toString());

      SnackbarUtility.showErrorMessage(message: 'Failed to add store');

    }).whenComplete(() {

      _stopAddStoreLoader();

    });

  }

  /// Request to remove the selected stores / specified store
  void requestRemoveStores({ ShoppableStore? store }) async {

    if(isLoadingStores || isRemovingStores) return;

    final bool? confirmation = await confirmRemoveStore(store: store);

    /// If we can remove
    if(confirmation == true) {

      _startRemoveStoresLoader();

      final CustomVerticalListViewInfiniteScrollState customInfiniteScrollCurrentState = _customVerticalListViewInfiniteScrollState.currentState!;
      List<ShoppableStore> stores = [];

      if(store == null) {

        final List<ShoppableStore> selectedStores = List<ShoppableStore>.from(customInfiniteScrollCurrentState.selectedItems);

        /// Capture single or multiple selected stores
        stores.addAll(selectedStores);

      }else{

        /// Capture specified store
        stores.add(store);

      }

      /// Set the store ids of the stores that we are removing
      setState(() => removingStoreIds = stores.map((store) => store.id).toList());

      friendGroupProvider.friendGroupRepository.removeFriendGroupStores(
        stores: stores
      ).then((response) async {

        if(response.statusCode == 200) {

          /// Notify parent widget
          if(onRemovedStores != null) onRemovedStores!(stores);

          SnackbarUtility.showSuccessMessage(message: response.data['message']);

          /// Refresh the list of stores
          refreshStores();

        }

        /// Set the store ids of the last stores to be removed
        setState(() => lastRemovedStoreIds = removingStoreIds);

        /// Reset the store ids of the stores that we are removing
        setState(() => removingStoreIds = []);

        customInfiniteScrollCurrentState.unselectSelectedItems();

      }).catchError((error) {

        printError(info: error.toString());

        SnackbarUtility.showErrorMessage(message: 'Failed to remove stores');

      }).whenComplete(() {

        _stopRemoveStoresLoader();

      });

    }

  }

  /// Confirm remove the selected stores / specified store
  Future<bool?> confirmRemoveStore({ ShoppableStore? store }) {

    final CustomVerticalListViewInfiniteScrollState customInfiniteScrollCurrentState = _customVerticalListViewInfiniteScrollState.currentState!;
    final int totalSelectedItems = customInfiniteScrollCurrentState.totalSelectedItems;

    /// If we haven't mentioned a specific store, but we have selected one store
    if(store == null && totalSelectedItems == 1) {

      /// Capture that the selected store as our specific store
      store = customInfiniteScrollCurrentState.selectedItems.first;

    }

    if(store == null) {

      return DialogUtility.showConfirmDialog(
        content: 'Are you sure you want to remove these $totalSelectedItems stores?',
        context: context
      );

    }else{

      return DialogUtility.showConfirmDialog(
        content: 'Are you sure you want to remove ${store.name}?',
        context: context
      );

    }

  }

  Widget contentBeforeSearchBar(bool isLoading, int totalCoupons) {
    return Column(
      children: [
        
        if(authIsCreatorOrAdmin) searchUserSharedStores

      ],
    );
  }

  Widget get searchUserSharedStores {

    return Column(
      children: [
    
        Row(
          children: [
      
            /// Spacer
            const SizedBox(width: 16),

            /// Mobile Number Text Form Field (Seearch For A Seller)
            Expanded(child: mobileNumberTextFormField),

            /// Contact Selector (Select A Single Contact)
            contactSelector
            
          ],
        ),
      
        /// Spacer
        const SizedBox(height: 16),

        /// Searched User Profile Photo
        searchedUserProfilePhoto,
      
      ]
    );
  }

  /// Mobile Number Text Form Field
  Widget get mobileNumberTextFormField {
    return CustomMobileNumberTextFormField(
      focusNode: _focusNode,
      controller: searchedMobileNumberController,
      supportedMobileNetworkNames: const [
        MobileNetworkName.orange
      ],
      onChanged: (value) {

        if(selectedContactName != null) {
          setState(() => selectedContactName = null);
        }
    
        if(hasCompleteMobileNumber) {
                        
          hideKeypad();
                        
          /// Start the loader immediately since the debouncerUtility() of the requestSearchUserByMobileNumber() 
          /// method applies a delay. The delay causes the loader to appear after sometime which is undesirable
          _startSearchUserLoader();
          requestSearchUserByMobileNumber();
                        
        }else{
          
          resetSearchedUser();
                        
        }
                        
      },
    );
  }

  /// Contact Selector
  Widget get contactSelector {
    return ContactsModalPopup(
      subtitle: 'Search for your local seller',
      showAddresses: false,
      trigger: (openBottomModalSheet) {
        return IconButton(
          onPressed: () => openBottomModalSheet(), 
          icon: const Icon(
            Icons.person_pin_circle_rounded, 
            color: Colors.green
          )
        );
      },
      onSelection: (contacts) {
        setState(() {

          /**
           *  Just incase we opened the contacts modal bottom sheet 
           *  while the keypad was opened, we should therefore make 
           *  sure that the keypad is closed
           */
          hideKeypad();
          
          searchedMobileNumberController.text = contacts.first.phones.first.number;
          selectedContactName = contacts.first.displayName;

          if(hasCompleteMobileNumber) {

            _startSearchUserLoader();
            requestSearchUserByMobileNumber();

          }

        });
      },
      supportedMobileNetworkNames: const [
        MobileNetworkName.orange
      ]
    );
  }

  /// Searched User Profile Photo
  Widget get searchedUserProfilePhoto {

    final bool canChangePhoto = searchedUser?.id == authUser.id;

    return SizedBox(
      width: double.infinity,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 500),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
        
            if(hasCompleteMobileNumber) ...[
        
              /// User Profile Photo
              UserProfilePhoto(user: searchedUser, isLoading: isSearchingUser, canChangePhoto: canChangePhoto, radius: 60, placeholderIconSize: 80, canCallSize: 40, canCallRightPosition: 0, canCallBottomPosition: 5),
        
            ],
        
            if(hasCompleteMobileNumber && !isSearchingUser && hasSearchedUser) ...[
        
              /// Spacer
              const SizedBox(height: 16),
            
              /// Instruction
              CustomBodyText('Add stores shared by ${searchedUser!.attributes.name}', lightShade: true, margin: const EdgeInsets.symmetric(horizontal: 16),),
        
              /// Shared Stores List
              sharedStoresList,
        
            ],
        
            if(hasCompleteMobileNumber && !isSearchingUser && !hasSearchedUser) ...[
        
              /// Spacer
              const SizedBox(height: 16),
            
              /// Account does not exist desclaimer 
              CustomBodyText('${selectedContactName ?? 'This account'} is not on ${constants.appName} 😊', color: Colors.green, fontWeight: FontWeight.bold, textAlign: TextAlign.center, margin: EdgeInsets.symmetric(horizontal: 16),),
        
            ],
        
            if(!hasCompleteMobileNumber) ...[
            
              /// Instruction
              const CustomBodyText('Add stores using seller\'s mobile number', lightShade: true, margin: EdgeInsets.symmetric(horizontal: 16),),
              
              /// Spacer
              const SizedBox(height: 16),
        
            ],
        
          ],
        ),
      ),
    );
  }

  Widget get sharedStoresList {
    return SizedBox(
      width: double.infinity,
      child: AnimatedSwitcher(
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        duration: const Duration(milliseconds: 500),
        child: Container(
          width: double.infinity,
          key: ValueKey(isLoadingUserSharedStores),
          color: Colors.black.withOpacity(0.05),
          margin: const EdgeInsets.only(top: 16, bottom: 16),
          padding: const EdgeInsets.only(top: 16, bottom: 16, left: 16,),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
      
              if(isLoadingUserSharedStores) ...[
                
                /// Loader
                const CustomCircularProgressIndicator(
                  strokeWidth: 2,
                  size: 16,
                ),
      
              ],
      
              if(!isLoadingUserSharedStores && hasSharedStores) ...[
        
                /// List Of Shared Stores
                ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: sharedStores.length,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (BuildContext context, int index) => const Divider(),
                  itemBuilder: ((context, index) {
    
                    final store = sharedStores[index];
      
                    final bool isAddingStore = store.id == addingStoreId;
                    final bool isRemovingStore = removingStoreIds.contains(store.id);
    
                    return SharedStoreItem(
                      store: store,
                      isAddingStore: isAddingStore,
                      isRemovingStore: isRemovingStore,
                      requestAddStore: requestAddStore,
                      lastAddedStoreId: lastAddedStoreId,
                      lastRemovedStoreIds: lastRemovedStoreIds,
                      requestRemoveStores: requestRemoveStores
                    );
    
                  })
                ),
      
              ],
      
              if(!isLoadingUserSharedStores && !hasSharedStores) ...[
            
                /// Instruction
                CustomBodyText('${searchedUser!.firstName} hasn\'t shared stores 😊'),
      
              ]
        
            ],
          )
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomVerticalListViewInfiniteScroll(
      debounceSearch: true,
      showNoContent: false,
      onLoading: onLoading,
      onParseItem: onParseItem, 
      showNoMoreContent: false,
      onRenderItem: onRenderItem,
      showFirstRequestLoader: false,
      selectedAllAction: selectedAllAction,
      catchErrorMessage: 'Can\'t show stores',
      disabled: isAddingStore || isRemovingStores,
      loaderMargin: const EdgeInsets.only(top: 40),
      contentBeforeSearchBar: contentBeforeSearchBar,
      key: _customVerticalListViewInfiniteScrollState,
      toggleSelectionCondition: toggleSelectionCondition,
      onRequest: (page, searchWord) => requestFriendGroupStores(page, searchWord),
      headerPadding: const EdgeInsets.only(top: 20, bottom: 20, left: 0, right: 0),
      multiSelectActionsPadding: const EdgeInsets.only(top: 16, bottom: 0, left: 8, right: 16),
    );
  }
}

class StoreItem extends StatefulWidget {
  
  final bool isSelected;
  final bool isLoadingStores;
  final bool isRemovingStore;
  final ShoppableStore store;
  final bool authIsCreatorOrAdmin;
  final Function(ShoppableStore) toggleSelection;
  final void Function({ ShoppableStore? store }) requestRemoveStores;

  const StoreItem({
    super.key, 
    required this.store,
    required this.isSelected,
    required this.toggleSelection,
    required this.isLoadingStores,
    required this.isRemovingStore,
    required this.requestRemoveStores,
    required this.authIsCreatorOrAdmin,
  });

  @override
  State<StoreItem> createState() => _StoreItemState();
}

class _StoreItemState extends State<StoreItem> {

  int get id => store.id;
  ShoppableStore get store => widget.store;
  bool get isSelected => widget.isSelected;
  int get totalOrders => store.ordersCount!;
  bool get hasRating => store.rating != null;
  int get totalReviews => store.reviewsCount!;
  bool get isLoadingStores => widget.isLoadingStores;
  bool get isRemovingStore => widget.isRemovingStore;
  bool get hasDescription => store.description != null;
  bool get authIsCreatorOrAdmin => widget.authIsCreatorOrAdmin;
  Function(ShoppableStore) get toggleSelection => widget.toggleSelection;
  String get totalOrdersText => '$totalOrders ${totalOrders == 1 ? 'Order' : 'Orders'}';
  String get totalReviewsText => '$totalReviews ${totalReviews == 1 ? 'Review' : 'Reviews'}';
  void Function({ ShoppableStore? store }) get requestRemoveStores => widget.requestRemoveStores;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey<int>(id),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (DismissDirection direction) {

        /// Toggle selection when swiping left to right
        toggleSelection(store);

        /// Prevent dismissal of this item
        return Future.value(false);

      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: isSelected ? Colors.green.shade50 : null,
          border: Border.all(color: isSelected ? Colors.green.shade300 : Colors.transparent),
        ),
        child: ListTile(
          dense: true,
          onTap: () => toggleSelection(store),
          onLongPress: () => toggleSelection(store),
          contentPadding: const EdgeInsets.symmetric(horizontal: 0),
          title: AnimatedPadding(
            duration: const Duration(milliseconds: 500),
            padding: EdgeInsets.only(left: isSelected ? 4 : 0, right: 16),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                
                /// Store Information
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              
                    //  Store Logo
                    StoreLogo(store: store),

                    /// Spacer
                    const SizedBox(width: 8),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        /// Store Name
                        CustomTitleSmallText(store.name),
                          
                        /// Spacer
                        const SizedBox(height: 4),
                            
                        if(hasDescription) ...[
                            
                          /// Store Description
                          CustomBodyText(store.description, lightShade: true),
                            
                          /// Spacer
                          const SizedBox(height: 4),
                            
                        ],

                        Row(
                          children: [

                            if(hasRating) ...[
                              
                              //  Rating
                              RatingShowUsingStars(rating: store.rating!),

                              /// Spacer
                              const SizedBox(width: 8,),

                            ],
                  
                            //  Total Orders
                            CustomBodyText(totalOrdersText, lightShade: true),

                            /// Spacer
                            const SizedBox(width: 8,),
                  
                            //  Total Orders
                            CustomBodyText(totalReviewsText, lightShade: true),

                          ],
                        ),

                      ],
                    )

                  ],
                ),
          
                /// Cancel Icon
                if(isSelected && !isRemovingStore) Positioned(
                  top: -5,
                  right: -20,
                  child: IconButton(
                    icon: Icon(Icons.cancel, size: 20, color: Colors.green.shade500,),
                    onPressed: () => toggleSelection(store)
                  ),
                ),
          
                /// Remove Icon
                if(!isSelected && !isRemovingStore && authIsCreatorOrAdmin) Positioned(
                  top: -5,
                  right: -20,
                  child: IconButton(
                    onPressed: () => requestRemoveStores(store: store),
                    padding: const EdgeInsets.only(left: 24, right: 16),
                    icon: Icon(Icons.delete_rounded, size: 20, color: Colors.red.shade500,),
                  ),
                ),

                /// Removing Loader
                if(isRemovingStore) const Positioned(
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

class SharedStoreItem extends StatefulWidget {
  
  final bool isAddingStore;
  final bool isRemovingStore;
  final ShoppableStore store;
  final int? lastAddedStoreId;
  final List<int> lastRemovedStoreIds;
  final void Function({ ShoppableStore? store }) requestRemoveStores;
  final void Function({ required ShoppableStore store }) requestAddStore;

  const SharedStoreItem({
    super.key, 
    required this.store,
    required this.isAddingStore,
    required this.isRemovingStore,
    required this.requestAddStore,
    required this.lastAddedStoreId,
    required this.lastRemovedStoreIds,
    required this.requestRemoveStores,
  });

  @override
  State<SharedStoreItem> createState() => _SharedStoreItemState();
}

class _SharedStoreItemState extends State<SharedStoreItem> {

  late bool isAdded;

  ShoppableStore get store => widget.store;
  int get totalOrders => store.ordersCount!;
  bool get hasRating => store.rating != null;
  int get totalReviews => store.reviewsCount!;
  bool get isAddingStore => widget.isAddingStore;
  bool get isRemovingStore => widget.isRemovingStore;
  int? get lastAddedStoreId => widget.lastAddedStoreId;
  bool get hasDescription => store.description != null;
  List<int> get lastRemovedStoreIds => widget.lastRemovedStoreIds;
  String get totalOrdersText => '$totalOrders ${totalOrders == 1 ? 'Order' : 'Orders'}';
  String get totalReviewsText => '$totalReviews ${totalReviews == 1 ? 'Review' : 'Reviews'}';
  void Function({ ShoppableStore? store }) get requestRemoveStores => widget.requestRemoveStores;
  void Function({ required ShoppableStore store }) get requestAddStore => widget.requestAddStore;
  FriendGroupStoreAssociation? get friendGroupStoreAssociation => store.attributes.friendGroupStoreAssociation;

  @override
  void initState() {
    super.initState();
    isAdded = friendGroupStoreAssociation != null;
  }

  @override
  void didUpdateWidget(covariant SharedStoreItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    /// If the last added store id has changed
    if(lastAddedStoreId != oldWidget.lastAddedStoreId) {
      
      /// If the current store matches the last added store id
      if(store.id == lastAddedStoreId) {

        /// Indicate that this store has been added
        setState(() => isAdded = true);

      }

    }

    /// If the last removed store ids have changed
    if(lastRemovedStoreIds != oldWidget.lastRemovedStoreIds) {
      
      /// If the current store is contained within the last removed store ids
      if(lastRemovedStoreIds.contains(store.id)) {

        /// Indicate that this store has been removed
        setState(() => isAdded = false);

      }

    }
  }

  void onRemovedStore() {
    setState(() => isAdded = false);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          
          /// Store Information
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  
                //  Store Logo
                StoreLogo(store: store),
          
                /// Spacer
                const SizedBox(width: 8),
          
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                          
                      /// Store Name
                      CustomTitleSmallText(store.name),
                          
                      /// Spacer
                      const SizedBox(height: 4),
                          
                      if(hasDescription) ...[
                          
                        /// Store Description
                        CustomBodyText(store.description, lightShade: true),
                          
                        /// Spacer
                        const SizedBox(height: 4),
                          
                      ],
                          
                      Row(
                        children: [
                          
                          if(hasRating) ...[
                            
                            //  Rating
                            RatingShowUsingStars(rating: store.rating!),
                          
                            /// Spacer
                            const SizedBox(width: 8,),
                          
                          ],
                              
                          //  Total Orders
                          CustomBodyText(totalOrdersText, lightShade: true),
                          
                          /// Spacer
                          const SizedBox(width: 8,),
                              
                          //  Total Orders
                          CustomBodyText(totalReviewsText, lightShade: true),
                          
                        ],
                      ),
                          
                    ],
                  ),
                )
          
              ],
            ),
          ),

          /// Add / Remove Store
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: CustomElevatedButton(
              fontSize: 12,
              isAdded ? '' : 'Add',
              width: isAdded ? 20 : 50,
              color: isAdded ? Colors.red : null,
              isLoading: isAddingStore || isRemovingStore,
              prefixIcon: isAdded ? Icons.delete : Icons.add,
              onPressed: () {
                if(isAdded) {
                  
                  requestRemoveStores(store: store);

                }else{
                  
                  requestAddStore(store: store);

                }
              }
            ),
          ),
      
        ],
      ),
      
    );
  }
}