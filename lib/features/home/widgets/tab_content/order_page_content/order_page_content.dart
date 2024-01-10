import 'package:bonako_demo/features/orders/enums/order_enums.dart';
import 'package:bonako_demo/features/orders/widgets/orders_show/orders_modal_bottom_sheet/orders_modal_bottom_sheet.dart';
import 'package:bonako_demo/core/shared_widgets/multi_circle_avatar_image_fader/multi_circle_avatar_image_fader.dart';
import 'package:bonako_demo/core/shared_widgets/text_form_field/custom_mobile_number_text_form_field.dart';
import 'package:bonako_demo/features/reviews/enums/review_enums.dart';
import 'package:bonako_demo/features/reviews/widgets/reviews_show/reviews_modal_bottom_sheet/reviews_modal_bottom_sheet.dart';
import 'package:bonako_demo/features/user/widgets/user_profile_photo/user_profile_photo.dart';
import 'package:bonako_demo/core/shared_widgets/cards/custom_title_and_number_card.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_large_text.dart';
import 'package:bonako_demo/features/stores/widgets/store_cards/store_cards.dart';
import 'package:bonako_demo/features/authentication/providers/auth_provider.dart';
import 'package:bonako_demo/features/contacts/widgets/contacts_modal_popup.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/api/repositories/api_repository.dart';
import 'package:bonako_demo/core/constants/constants.dart' as constants;
import 'package:bonako_demo/features/user/models/resource_totals.dart';
import 'package:bonako_demo/features/api/providers/api_provider.dart';
import 'package:bonako_demo/features/stores/enums/store_enums.dart';
import 'package:bonako_demo/core/utils/api_conflict_resolver.dart';
import 'package:bonako_demo/core/utils/mobile_number.dart';
import 'package:bonako_demo/core/shared_models/user.dart';
import 'package:bonako_demo/core/utils/debouncer.dart';
import 'package:bonako_demo/core/utils/snackbar.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;

class OrderPageContent extends StatefulWidget {

  final Function(int) onChangeNavigationTab;

  const OrderPageContent({
    super.key,
    required this.onChangeNavigationTab
  });

  @override
  State<OrderPageContent> createState() => _OrderPageContentState();
}

class _OrderPageContentState extends State<OrderPageContent> with SingleTickerProviderStateMixin {

  User? searchedUser;
  Color? rainbowColor;
  String? selectedContactName;
  bool isSearchingUser = false;
  ResourceTotals? resourceTotals;
  bool? authUserHasFollowedStores;
  final FocusNode _focusNode = FocusNode();
  List<Color> rainbowColors = constants.rainbowColors;
  ScrollController scrollController = ScrollController();
  TextEditingController searchedMobileNumberController = TextEditingController();
  final DebouncerUtility debouncerUtility = DebouncerUtility(milliseconds: 1000);
  final ApiConflictResolverUtility apiConflictResolverUtility = ApiConflictResolverUtility();

  User get authUser => authProvider.user!;
  bool get hasSearchedUser => searchedUser != null;
  bool get hasResourceTotals => resourceTotals != null;
  ApiRepository get apiRepository => apiProvider.apiRepository;
  bool get hasCompleteMobileNumber => searchedMobileNumber.length == 8;
  String get searchedMobileNumber => searchedMobileNumberController.text;
  Function(int) get onChangeNavigationTab => widget.onChangeNavigationTab;
  ApiProvider get apiProvider => Provider.of<ApiProvider>(context, listen: false);
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
  bool get hasCreatedAStore => hasResourceTotals ? resourceTotals!.totalStoresJoinedAsCreator > 0 : false;
  bool get searchedMobileNumberUserAccountDoesNotExit => !isSearchingUser && searchedMobileNumber.length == 8 && searchedUser == null;

  void _startSearchUserLoader() => setState(() => isSearchingUser = true);
  void _stopSearchUserLoader() => setState(() => isSearchingUser = false);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    /// Get the authenticated user's resource totals
    final ResourceTotals? updateResourceTotals = Provider.of<AuthProvider>(context, listen: false).resourceTotals;

    if(updateResourceTotals != null) {

      /// Update the local resourceTotals
      setState(() => resourceTotals = updateResourceTotals);
      
    }
    
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
    searchedMobileNumberController.dispose();
  }

  void requestSearchUserByMobileNumber() {
      
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

  Widget get _headline {
    return _addFadedImageBackground(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _supportYourLocalSellerTitle,
          const SizedBox(height: 16.0),
          _supportYourLocalSellerInstruction,
        ],
      ),
    );
  }

  /// Wrap the child widget in a container with a faded image background
  Widget _addFadedImageBackground({ required Widget child }) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bg_4.png'), 
          fit: BoxFit.cover
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            end: Alignment.topCenter,
            begin: Alignment.bottomCenter,
            colors: [Colors.white.withOpacity(1), Colors.white.withOpacity(0.8)],
          ),
        ),
        child: child
      )
    );
  }

  Widget get _supportYourLocalSellerTitle {
    return const CustomTitleLargeText('Support Your Local Seller 🌱');
  }

  Widget get _supportYourLocalSellerInstruction {
    return const CustomBodyText('Search your local seller using their mobile number and start supporting their business by placing your first order towards your community', textAlign: TextAlign.center,);
  }

  Widget get _sellerSearchbar {

    return Container(
      color: Colors.white,  /// The Scaffold background is greyish, we need a white background
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
    
            Row(
              children: [

                Expanded(
                  child: CustomMobileNumberTextFormField(
                    focusNode: _focusNode,
                    controller: searchedMobileNumberController,
                    supportedMobileNetworkNames: const [
                      MobileNetworkName.orange
                    ],
                    onChanged: (value) {
                      
                      resetScrollController();

                      if(selectedContactName != null) {
                        setState(() => selectedContactName = null);
                      }

                      if(hasCompleteMobileNumber) {
                
                        hideKeypad();
                
                        /// Start the loader immediately since the debouncerUtility() of the requestSearchUserByMobileNumber() 
                        /// method applies a delay. The delay causes the "This account does not on Perfect Order" message to 
                        /// show up prematurely since we satisfy the requirements of searchedMobileNumberUserAccountDoesNotExit:
                        /// 
                        /// !isSearchingUser                      //  true
                        /// && searchedUser == null;              //  true
                        /// && hasCompleteMobileNumber            //  true
                        /// 
                        /// To avoid this we need to immediately run _startSearchUserLoader();
                        _startSearchUserLoader();
                        requestSearchUserByMobileNumber();
                
                      }else{
                        
                        resetSearchedUser();
                
                      }
                
                    },
                  ),
                ),

                /// Contact Selector
                ContactsModalPopup(
                  subtitle: 'Search for your local seller',
                  showAddresses: false,
                  trigger: (openBottomModalSheet) {
                    return IconButton(onPressed: () => openBottomModalSheet(), icon: const Icon(Icons.person_pin_circle_rounded, color: Colors.green,));
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
                
                      resetScrollController();

                      if(hasCompleteMobileNumber) {

                        _startSearchUserLoader();
                        requestSearchUserByMobileNumber();

                      }

                    });
                  }, 
                  supportedMobileNetworkNames: const [
                    MobileNetworkName.orange
                  ]
                ),
                
              ],
            ),

            SizedBox(
              width: double.infinity,
              child: AnimatedSize(
                duration: const Duration(milliseconds: 500),
                child: AnimatedSwitcher(
                  switchInCurve: Curves.easeIn,
                  switchOutCurve: Curves.easeOut,
                  duration: const Duration(milliseconds: 500),
                  child: Column(
                    key: ValueKey(isSearchingUser),
                    children: [
                      
                      if(searchedMobileNumberUserAccountDoesNotExit) ...[
                            
                        /// Spacer
                        const SizedBox(height: 16.0,),
                                
                        /// Account does not exist desclaimer 
                        CustomBodyText('${selectedContactName ?? 'This account'} is not on ${constants.appName} 😊', color: Colors.green, fontWeight: FontWeight.bold, textAlign: TextAlign.center,),
                            
                        /// Spacer
                        const SizedBox(height: 16.0,),
                        
                      ],
              
                    ],
                  )
                ),
              ),
            ),
          ]
        )
      )
    );
  }

  Widget get orderAndReviewStatistics {
    return Container(
      color: Colors.white,
      width: double.infinity,
      alignment: Alignment.center,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OrdersModalBottomSheet(
                    userOrderAssociation: UserOrderAssociation.customerOrFriend,
                    trigger: (openBottomModalSheet) => CustomTitleAndNumberCard(
                      number: resourceTotals?.totalOrdersAsCustomerOrFriend,
                      onTap: openBottomModalSheet,
                      title: 'My Orders', 
                    )
                  ),
                  ReviewsModalBottomSheet(
                    userReviewAssociation: UserReviewAssociation.reviewer,
                    trigger: (openBottomModalSheet) => CustomTitleAndNumberCard(
                      number: resourceTotals?.totalReviews,
                      onTap: openBottomModalSheet,
                      title: 'My Reviews', 
                    )
                  ),                
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget get searchedUserProfilePhoto {

    final bool canChangePhoto = searchedUser?.id == authUser.id;

    return  SizedBox(
      width: double.infinity,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 500),
        child: AnimatedSwitcher(
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          duration: const Duration(milliseconds: 500),
          child: isSearchingUser || hasSearchedUser 
            ? Stack(
              children: [
                
                /// User Profile Photo
                UserProfilePhoto(user: searchedUser, isLoading: isSearchingUser, canChangePhoto: canChangePhoto, radius: 80),

              ],
            ) 
            : null
        )
      ),
    );
  }

  Widget get searchedUserStoreCards {
    return  StoreCards(
      /// Show Stores Assigned to User
      showFirstRequestLoader: false,
      scrollController: scrollController,
      userAssociation: UserAssociation.assigned,
      key: const ValueKey('searchedUserStoreCards'),
      storesUrl: searchedUser!.links.showStores.href,
      contentBeforeSearchBar: (isLoading, totalItems) {
      
        String instruction;
        bool hasStores = totalItems > 0;
        bool hasAboutMe = searchedUser!.aboutMe != null;

        if(hasStores) {

          if(hasAboutMe) {

            instruction = searchedUser!.aboutMe!;

          }else{

            instruction = 'Stores by ${searchedUser!.firstName}';

          }

        }else{

          instruction = '${searchedUser!.firstName} hasn\'t shared stores 😊';

        }
      
        return SizedBox(
          width: double.infinity,
          child: AnimatedSize(
            duration: const Duration(milliseconds: 500),
            child: AnimatedSwitcher(
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              duration: const Duration(milliseconds: 500),
              child: Column(
                key: ValueKey(isLoading),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  /// Instruction
                  if(!isLoading) CustomBodyText(
                    instruction,
                    lightShade: true,
                    textAlign: TextAlign.center,
                    margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 40),
                  ),

                  /// Spacer
                  if(isLoading) const SizedBox(height: 8),
    
                ],
              )
            )
          ),
        );
      
      }
    );
  }

  Widget get authUserFollowedStoreCards {
    return StoreCards(
      /// Show Stores Followed By Auth User
      showFirstRequestLoader: false,
      scrollController: scrollController,
      userAssociation: UserAssociation.follower,
      onResponse: onResponseToAuthUserFollowedStores,
      key: const ValueKey('authUserFollowedStoreCards'),
      contentBeforeSearchBar: (isLoading, totalItems) {
      
        bool hasStores = totalItems > 0;
      
        return SizedBox(
          width: double.infinity,
          child: AnimatedSize(
            duration: const Duration(milliseconds: 500),
            child: AnimatedSwitcher(
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              duration: const Duration(milliseconds: 1000),
              child: Column(
                key: ValueKey('$isLoading $isSearchingUser $hasStores'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: isSearchingUser ? [] : [
                  
                  /// Instruction
                  if(!isLoading && hasStores) const CustomBodyText(
                    lightShade: true,
                    'Local sellers you are following 💕',
                    margin: EdgeInsets.symmetric(vertical: 16.0),
                  ),

                  if(!isLoading && !hasStores) Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _notFollowingStoresPlaceholder,
                      _lookingToSellCallToAction,
                    ],
                  ),

                  /// Spacer
                  if(isLoading) const SizedBox(height: 8),
    
                ],
              )
            )
          ),
        );
      
      }
    );
  }

  Widget get _notFollowingStoresPlaceholder {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: CustomMultiCircleAvatarImageFader(
        size: 200,
        imagePaths: const [
          'assets/images/seller_1.jpeg',
          'assets/images/seller_2.jpeg',
          'assets/images/seller_3.jpeg',
          'assets/images/seller_4.jpeg',
          'assets/images/seller_5.jpeg',
          'assets/images/seller_6.jpeg',
          'assets/images/seller_7.jpeg',
        ],
        onSelectedRainbowColor: (updatedRainbowColor) {
          setState(() => rainbowColor = updatedRainbowColor);
        }
      ),
    );
  }



  Widget get _lookingToSellCallToAction {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        if(!hasCreatedAStore) ...[

          /// Divider
          const SizedBox(height: 16,),
          
          /// Looking To Sell Information
          Align(
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () {
                
                /// Navigate to "My Stores" tab
                onChangeNavigationTab(2);

              },
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: 'Looking to sell? ',
                  style: Theme.of(context).textTheme.bodyMedium,
                  children: [
                    TextSpan(text: '🤑\n', style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 32)),
                    const TextSpan(text: 'Let\'s create your first store', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, decoration: TextDecoration.underline))
                  ]
                )
              ),
            ),
          ),

        ]

      ],
    );
  }

  Widget _addRainbowColorBackground({ required Widget child }) {
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      decoration: BoxDecoration(
        color: (hasSearchedUser || authUserHasFollowedStores == true) ? null : rainbowColor
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            end: Alignment.topCenter,
            begin: Alignment.bottomCenter,
            colors: [Colors.white.withOpacity(0.8), Colors.white.withOpacity(1), Colors.white.withOpacity(1)],
          ),
        ),
        child: child
      )
    );
  }

  void hideKeypad() {
    _focusNode.unfocus();
  }

  void resetSearchedUser() {
    setState(() => searchedUser = null);
  }

  void resetScrollController() {
    /**
     *  Reset the scroll controller. Whenever the user enters the mobile number to search for a seller, the UI
     *  changes by hiding the authUserFollowedStoreCards in order to show the searchedUserStoreCards. Since
     *  both of these widgets use the same scrollController, attempting to scroll after the UI changes
     *  causes the following error: 
     * 
     *  ════════ Exception caught by foundation library ════════════════════════════════════════════════════════
     *  This widget has been unmounted, so the State no longer has a context (and should be considered defunct).
     *  ════════════════════════════════════════════════════════════════════════════════════════════════════════
     * 
     *  For instance: At first without entering the mobile number, we are able to scroll without any issues. At
     *  this point the authUserFollowedStoreCards() are being shown. When we enter a mobile number and a user
     *  account is found, the UI changes to hide the authUserFollowedStoreCards() widget in favour of showing
     *  the stores of the searchedUserStoreCards(). Now when attempting to scroll this error will occur.
     * 
     *  To avoid this error, we should dispose the current scrollController and then replace
     *  it with a completely new scrollController. This way we can avoid this conflict.
     */
    setState(() {
      scrollController.dispose();
      scrollController = ScrollController();
    });
  }

  void onResponseToAuthUserFollowedStores(dio.Response response) {
    setState(() {
      authUserHasFollowedStores = response.data['total'] > 0;
      rainbowColor = authUserHasFollowedStores == true ? null : rainbowColors.first;
    });
  }

  @override
  Widget build(BuildContext context) {

    _listenForAuthProviderChanges(context);
  
    return _addRainbowColorBackground(
      child: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: [
    
            /// Headline - Support Seller Title And Instruction
            _headline,
      
            /// Seller Search Bar - Search For Sellers
            _sellerSearchbar,
      
            /// Order And Review Statistics
            orderAndReviewStatistics,
      
            /// Searched User Profile Photo
            searchedUserProfilePhoto,
      
            /// Searched User Store Cards
            if(hasSearchedUser) searchedUserStoreCards,
      
            /// Auth User Follwed Store Cards
            if(!hasSearchedUser) authUserFollowedStoreCards,
    
          ],
        ),
      ),
    );
  }

}