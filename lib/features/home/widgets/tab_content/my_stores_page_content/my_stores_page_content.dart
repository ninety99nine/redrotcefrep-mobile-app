import 'package:perfect_order/features/home/providers/home_provider.dart';
import 'package:perfect_order/features/team_members/widgets/team_member_invitations_show/team_member_invitations_modal_bottom_sheet/team_member_invitations_modal_bottom_sheet.dart';
import 'package:perfect_order/features/stores/widgets/subscribe_to_store/subscribe_to_store_modal_bottom_sheet/subscribe_to_store_modal_bottom_sheet.dart';
import 'package:perfect_order/features/stores/widgets/create_store/create_store_modal_bottom_sheet/create_store_modal_bottom_sheet.dart';
import 'package:perfect_order/features/stores/widgets/update_store/update_store_modal_bottom_sheet/update_store_modal_bottom_sheet.dart';
import 'package:perfect_order/features/sms_alert/widgets/sms_alert_show/sms_alert_modal_bottom_sheet/sms_alert_modal_bottom_sheet.dart';
import 'package:perfect_order/features/products/widgets/show_products/products_modal_bottom_sheet/products_modal_bottom_sheet.dart';
import 'package:perfect_order/features/orders/widgets/orders_show/orders_modal_bottom_sheet/orders_modal_bottom_sheet.dart';
import 'package:perfect_order/features/reviews/widgets/reviews_show/reviews_modal_bottom_sheet/reviews_modal_bottom_sheet.dart';
import 'package:perfect_order/features/chat/widgets/ai_chat_modal_bottom_sheet/ai_chat_modal_bottom_sheet.dart';
import 'package:perfect_order/core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import 'package:perfect_order/core/shared_widgets/cards/custom_title_and_number_card.dart';
import 'package:perfect_order/core/shared_widgets/text/custom_title_medium_text.dart';
import 'package:perfect_order/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:perfect_order/features/stores/widgets/store_cards/store_cards.dart';
import 'package:perfect_order/core/shared_widgets/text/custom_body_text.dart';
import 'package:perfect_order/features/stores/providers/store_provider.dart';
import 'package:perfect_order/features/stores/models/shoppable_store.dart';
import 'package:perfect_order/core/constants/constants.dart' as constants;
import 'package:perfect_order/features/user/models/resource_totals.dart';
import 'package:perfect_order/features/reviews/enums/review_enums.dart';
import 'package:perfect_order/features/orders/enums/order_enums.dart';
import 'package:perfect_order/features/stores/enums/store_enums.dart';
import 'package:perfect_order/features/products/models/product.dart';
import '../../../../authentication/providers/auth_provider.dart';
import 'package:perfect_order/features/orders/models/order.dart';
import 'package:perfect_order/core/shared_models/user.dart';
import 'package:perfect_order/core/utils/snackbar.dart';
import 'package:perfect_order/core/utils/dialer.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class MyStoresPageContent extends StatefulWidget {

  final Function(int) onChangeNavigationTab;
  final Future<dio.Response?> Function() onRequestShowResourceTotals;

  const MyStoresPageContent({
    super.key,
    required this.onChangeNavigationTab,
    required this.onRequestShowResourceTotals
  });

  @override
  State<MyStoresPageContent> createState() => _MyStoresPageContentState();
}

class _MyStoresPageContentState extends State<MyStoresPageContent> with WidgetsBindingObserver{

  late User authUser;
  bool isLoadingStore = false;
  ResourceTotals? resourceTotals;
  ShoppableStore? firstCreatedStore;
  bool isLoadingResourceTotals = false;
  bool sentFirstRequestToLoadStore = false;

  bool get hasResourceTotals => resourceTotals != null;
  bool get hasCreatedAStore => firstCreatedStore != null;
  bool get doesNotHaveResourceTotals => resourceTotals == null;
  bool get doesNotHaveProfilePhoto => authUser.profilePhoto == null;
  int? get totalSmsAlertCredits => resourceTotals?.totalSmsAlertCredits;
  Function(int) get onChangeNavigationTab => widget.onChangeNavigationTab;
  int? get totalOrdersAsTeamMember => resourceTotals?.totalOrdersAsTeamMember;
  String get mobileNumberShortcode => authUser.attributes.mobileNumberShortcode;
  int? get totalReviewsAsTeamMember => resourceTotals?.totalReviewsAsTeamMember;
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
  HomeProvider get homeProvider => Provider.of<HomeProvider>(context, listen: false);
  int get totalReceivedOrders => hasCreatedAStore ? firstCreatedStore!.ordersCount ?? 0 : 0;
  int get totalCreatedProducts => hasCreatedAStore ? firstCreatedStore!.productsCount ?? 0 : 0;
  bool get hasReceivedAnOrder => hasCreatedAStore ? (firstCreatedStore!.ordersCount ?? 0) > 0 : false;
  bool get hasCreatedAProduct => hasCreatedAStore ? (firstCreatedStore!.productsCount ?? 0) > 0 : false;
  int? get totalStoresInvitedToJoinAsTeamMember => resourceTotals?.totalStoresInvitedToJoinAsTeamMember;
  bool get hasStoresAsACustomer => hasResourceTotals ? resourceTotals!.totalStoresAsCustomer > 0 : false;
  Future<dio.Response?> Function() get onRequestShowResourceTotals => widget.onRequestShowResourceTotals;
  bool get hasStoresAsRecentVisitor => hasResourceTotals ? resourceTotals!.totalStoresAsRecentVisitor > 0 : false;
  bool get hasStoresJoinedAsNonCreator => hasResourceTotals ? resourceTotals!.totalStoresJoinedAsNonCreator > 0 : false;
  bool get hasStoreInvitationsToJoinAsTeamMember => hasResourceTotals ? resourceTotals!.totalStoresInvitedToJoinAsTeamMember > 0 : false;
  bool get hasDialedStoreOnUssd => hasCreatedAStore ? firstCreatedStore!.attributes.userStoreAssociation!.lastSeenOnUssdAt != null : false;
  DateTime? get lastSubscriptionEndAt => hasCreatedAStore ? firstCreatedStore!.attributes.userStoreAssociation!.lastSubscriptionEndAt : null;
  bool get hasSubscribedAtleastOnce => hasCreatedAStore ? firstCreatedStore!.attributes.userStoreAssociation!.lastSubscriptionEndAt != null : false;
  bool get hasCompletedMilestones => hasCreatedAStore ? (hasCreatedAProduct && hasDialedStoreOnUssd && hasSubscribedAtleastOnce && hasReceivedAnOrder) : false;
  bool get hasJoinedRecentlyCreatedStoreLessThan24HoursAgo => hasCreatedAStore ? firstCreatedStore!.attributes.userStoreAssociation!.createdAt.isAfter(DateTime.now().subtract(const Duration(days: 1))) : false;

  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);

  final GlobalKey<SmsAlertModalBottomSheetState> _smsAlertModalBottomSheetState = GlobalKey<SmsAlertModalBottomSheetState>();
  final GlobalKey<CreateStoreModalBottomSheetState> _createStoreModalBottomSheetState = GlobalKey<CreateStoreModalBottomSheetState>();

  void _startShowStoreLoader() => setState(() => isLoadingStore = true);
  void _stopShowStoreLoader() => setState(() => isLoadingStore = false);
  void _startRequestResourceTotalsLoader() => setState(() => isLoadingResourceTotals = true);
  void _stopRequestResourceTotalsLoader() => setState(() => isLoadingResourceTotals = false);

  @override
  void initState() {
    print('part');
    super.initState();
    authUser = authProvider.user!;

    _showFirstCreatedStore();

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
     *  Once the user returns we want to refresh the state of the store incase they
     *  dialed, subscribed or placed an order to the store. This will allow us to
     *  pickup on these changes and updated accordingly
     */
    if (state == AppLifecycleState.resumed) {

      _showFirstCreatedStore();

    }

  }

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

  void _showFirstCreatedStore() {

    _startShowStoreLoader();

    authProvider.userRepository.showFirstCreatedStore(
      withCountCollectedOrders: true,
      withCountTeamMembers: true,
      withVisibleProducts: true,
      withVisitShortcode: true,
      withCountFollowers: true,
      withCountProducts: true,
      withCountReviews: true,
      withCountCoupons: true,
      withCountOrders: true,
      withRating: true
    ).then((response) {
    print('part 1 ----------');

      setState(() => sentFirstRequestToLoadStore = true);
    print('part 2 ----------');

      if(response.statusCode == 200) {

    print('part 3 ----------');
        final bool storeExists = response.data['exists'];

        if(storeExists) {
    print('part 4 ----------');

          setState(() => firstCreatedStore = ShoppableStore.fromJson(response.data['store']));

        }

      }

    }).catchError((error) {

      printError(info: error.toString());

      SnackbarUtility.showErrorMessage(message: 'Failed to show your first store');

    }).whenComplete(() {

      _stopShowStoreLoader();

    });

  }

  Widget get _hasCompletedMilestones {
    return Column(
      children: [

        /// If Created A Store Less Than 24 Hours Ago
        if(hasCreatedAStore && hasJoinedRecentlyCreatedStoreLessThan24HoursAgo) ...[

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
                    text: 'Congratulations 👏 you are ready for market 🎉 Tell your customers to dial ', 
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(height: 1.4),
                    children: [
                      TextSpan(
                        text: mobileNumberShortcode,
                        recognizer: TapGestureRecognizer()..onTap = () {
                          DialerUtility.dial(number: mobileNumberShortcode);
                        },
                        style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline, color: Colors.green)
                      ),
                      const TextSpan(text: '. Buy '),
                      TextSpan(
                        text: 'Sms Alerts', 
                        recognizer: TapGestureRecognizer()..onTap = () {
                          openSmsAlertModalBottomSheet();
                        },
                        style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline, color: Colors.green)
                      ),
                      const TextSpan(text: ' to be notified of new orders'),
                    ]
                  )
                ),
          
              ],
            )
          ),

          /// Spacer
          const SizedBox(height: 16),

        ],

        /// If Created A Store More Than 24 Hours Ago
        if(hasCreatedAStore && !hasJoinedRecentlyCreatedStoreLessThan24HoursAgo) ...[

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
                DialerUtility.dial(number: mobileNumberShortcode);
              },
              child: RichText(
                textAlign: TextAlign.left,
                text: TextSpan(
                  text: 'Hey ${authUser.firstName}, customers dial ',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(height: 1.4),
                  children: [
                    TextSpan(
                      text: mobileNumberShortcode,
                      style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline, color: Colors.green)
                    ),
                    const TextSpan(text: ' to place orders. They can also use the mobile app for a better experience. '),
                    const TextSpan(
                      text: 'Learn How?',
                      style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline, color: Colors.green)
                    ),
                  ]
                )
              ),
            ),
          ),

          /// Spacer
          const SizedBox(height: 16),

        ],

        /// If Has Not Created A Store
        if(!hasCreatedAStore) ...[

          /// Instruction Note
          GestureDetector(
            onTap: () {
              DialerUtility.dial(number: mobileNumberShortcode);
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
                      text: 'first store' ,
                      recognizer: TapGestureRecognizer()..onTap = () {
                        openCreateStoreModalBottomSheet();
                      },
                      style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline, color: Colors.green)
                    ),
                    const TextSpan(text: ' and start getting orders 😎. It\'s so easy'),
                  ]
                )
              ),
            ),
          ),

          /// Spacer
          const SizedBox(height: 16),

        ],

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

            /// Create Store Modal Bottom Sheet
            CreateStoreModalBottomSheet(
              key: _createStoreModalBottomSheetState,
              onCreatedStore: _onCreatedStore,
              trigger: (openBottomModalSheet) => IconButton(
                icon: const Icon(Icons.add_circle_rounded), 
                onPressed: openBottomModalSheet,
                iconSize: 40, 
              )
            )

          ],
        ),

        /// Spacer
        const SizedBox(height: 16),

        /// Store Card
        StoreCards(
          showFirstRequestLoader: false,
          //scrollController: scrollController,
          userAssociation: UserAssociation.teamMemberJoined,
          key: const ValueKey('searchedUserStoreCards'),
          contentBeforeSearchBar: (isLoading, totalItems) {

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

                    ],
                  )
                )
              ),
            );
          
          }
        ),

      ],
    );
  }

  Widget get _hasNotCompletedMilestones {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
      child: Column(
        children: [
    
          /// Title
          const CustomTitleMediumText('How ${constants.appName} Works', margin: EdgeInsets.only(top: 32),),
    
          Stack(
            children: [
              
              _milestones,
    
            ],
          ),
    
          /// Invitation Request To Join Stores
          if(hasStoreInvitationsToJoinAsTeamMember) _invitationRequestToJoinStores,

          /// Seller Image
          _sellerImage,

          /// Spacer
          const SizedBox(height: 100),
    
        ],
    
      ),
    );
  }

  Widget get orderAndReviewStatistics {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Wrap(          
          children: [

            OrdersModalBottomSheet(
              userOrderAssociation: UserOrderAssociation.teamMember,
              trigger: (openBottomModalSheet) => CustomTitleAndNumberCard(
                title: totalOrdersAsTeamMember == 1 ? 'Order' : 'Orders', 
                onTap: openBottomModalSheet,
                number: totalOrdersAsTeamMember,
              )
            ),

            ReviewsModalBottomSheet(
              userReviewAssociation: UserReviewAssociation.teamMember,
              trigger: (openBottomModalSheet) => CustomTitleAndNumberCard(
                title: totalReviewsAsTeamMember == 1 ? 'Review' : 'Reviews',
                onTap: openBottomModalSheet,
                number: totalReviewsAsTeamMember,
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
    
              /// Create Store Milestone
              _addMilestone(
                number: 1,
                checked: hasCreatedAStore,
                content: createStoreInstruction
              ),
    
              /// Create Products Milestone
              _addMilestone(
                number: 2,
                checked: hasCreatedAProduct,
                content: createProductsInstruction
              ),
    
              /// Dail Store On USSD Milestone
              _addMilestone(
                number: 3,
                checked: hasDialedStoreOnUssd,
                content: dialStoreInstruction
              ),
    
              /// Subscribe Milestone
              _addMilestone(
                number: 4,
                checked: hasSubscribedAtleastOnce,
                content: subcribeInstruction
              ),
    
              /// Subscribe Milestone
              _addMilestone(
                number: 5,
                checked: hasReceivedAnOrder,
                content: receiveOrderInstruction
              )
              
            ],
          ),

          if(isLoadingStore || isLoadingResourceTotals) Positioned(
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

  Widget get _sellerImage {
    return Container(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20)
      ),
      alignment: Alignment.center,
      child: SizedBox(
        width: double.infinity,
        child: Image.asset('assets/images/seller_1.jpeg')
      ),
    );
  }

  Widget get _invitationRequestToJoinStores {
    return TeamMemberInvitationsModalBottomSheet(
      canRefreshStores: false,
      onRespondedToInvitation: onRespondedToInvitation,
      trigger: (openBottomModalSheet) => Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: RichText(
          text: TextSpan(
            text: 'You have ', 
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              TextSpan(
                text: '$totalStoresInvitedToJoinAsTeamMember ${totalStoresInvitedToJoinAsTeamMember == 1 ? 'Invitation' : 'Invitations'}', 
                style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline, color: Colors.green)
              ),
              TextSpan(
                text: ' ${totalStoresInvitedToJoinAsTeamMember == 1 ? ' to join a store' : 'to join stores'}'
              )
            ]
          )
        ),
      )
    );
  }



          

  Widget get createStoreInstruction {

    if(hasCreatedAStore) {

      return UpdateStoreModalBottomSheet(
        onUpdatedStore: _onUpdatedStore,
        store: firstCreatedStore!,
        trigger: RichText(
          text: TextSpan(
            text: 'Created ', 
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              TextSpan(
                text: firstCreatedStore!.name, 
                style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline, color: Colors.green)
              ),
            ]
          )
        ),
      );

    }else{

      return CreateStoreModalBottomSheet(
        onCreatedStore: _onCreatedStore,
        trigger: (openBottomModalSheet) => RichText(
          text: TextSpan(
            text: 'First ', 
            style: Theme.of(context).textTheme.bodyMedium,
            children: const [
              TextSpan(
                text: 'create store', 
                style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)
              ),
            ]
          )
        ),
      );

    }

  }

  void openSmsAlertModalBottomSheet() {
    _smsAlertModalBottomSheetState.currentState?.openBottomModalSheet();
  }

  void openCreateStoreModalBottomSheet() {
    _createStoreModalBottomSheetState.currentState?.openBottomModalSheet();
  }

  void onRespondedToInvitation() {
    _onRequestShowResourceTotals();
  }

  void _onRequestShowResourceTotals() async {
    _startRequestResourceTotalsLoader();
    await onRequestShowResourceTotals();
    _stopRequestResourceTotalsLoader();
  }

  void _onCreatedStore(ShoppableStore createdStore) {
    Get.back();
    _showFirstCreatedStore();
    _onRequestShowResourceTotals();
    setState(() => firstCreatedStore = createdStore);
  }

  void _onUpdatedStore(ShoppableStore updatedStore) {
    Get.back();
    _showFirstCreatedStore();
    setState(() => firstCreatedStore = updatedStore);
  }
  
  Widget get createProductsInstruction {

    if(hasCreatedAProduct == true) {

      Widget instruction = RichText(
        text: TextSpan(
          text: 'Added ', 
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(
              text: '$totalCreatedProducts ${totalCreatedProducts == 1 ? 'product' : 'products'}',
              style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline, color: Colors.green)
            ),
          ]
        )
      );

      return ProductsModalBottomSheet(
        store: firstCreatedStore!,
        onCreatedProduct: _onCreatedProduct,
        trigger: (openBottomModalSheet) => instruction
      );

    }else{

      Widget instruction = RichText(
        text: TextSpan(
          text: 'Then ', style: Theme.of(context).textTheme.bodyMedium,
          children: const [
            TextSpan(text: 'add products', style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
          ]
        )
      );

      if(firstCreatedStore == null) {

        return GestureDetector(
          onTap: () {
            SnackbarUtility.showInfoMessage(message: 'Create your store first');
          },
          child: instruction,
        );

      }else{

        return ProductsModalBottomSheet(
          store: firstCreatedStore!,
          onCreatedProduct: _onCreatedProduct,
          trigger: (openBottomModalSheet) => instruction
        );

      }

    }

  }

  void _onCreatedProduct(Product createdProduct) {
    _showFirstCreatedStore();
    setState(() => firstCreatedStore!.relationships.products.add(createdProduct));
  }

  Widget get dialStoreInstruction {

    Widget instruction = hasDialedStoreOnUssd
      ? RichText(
        text: TextSpan(
          text: 'Dialed your store on ', style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(text: mobileNumberShortcode, style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline, color: Colors.green)),
            const TextSpan(text: ' 🚀')
          ]
        )
      )
      : RichText(
        text: TextSpan(
          text: 'Dial your store on ', style: Theme.of(context).textTheme.bodyMedium!.copyWith(height: 1),
          children: [
            TextSpan(text: mobileNumberShortcode, style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
            if(hasCreatedAProduct) const TextSpan(text: ' 🚀')
          ]
        )
    );

    return GestureDetector(
      onTap: () {
        if(!hasCreatedAStore) {
          SnackbarUtility.showInfoMessage(message: 'Create your store first');
        }else if(!hasCreatedAProduct) {
          SnackbarUtility.showInfoMessage(message: 'Add your product first');
        }else{
          DialerUtility.dial(number: mobileNumberShortcode);
        }
      },
      child: instruction
    );

  }

  Widget get subcribeInstruction {

    if(hasSubscribedAtleastOnce == true) {

      return RichText(
        text: TextSpan(
          text: 'Subscribed until ',
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(
              text: DateFormat('dd MMM yyyy @ HH:mm').format(lastSubscriptionEndAt!),
              style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline, color: Colors.green)
            ),
          ]
        )
      );

    }else{

      Widget instruction = RichText(
        text: TextSpan(
          text: 'Open for business by ',
          style: Theme.of(context).textTheme.bodyMedium,
          children: const [
            TextSpan(
              text: 'subscribing',
              style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
            ),
          ]
        )
      );

      if(!hasCreatedAStore || !hasCreatedAProduct) {

        return GestureDetector(
          onTap: () {
            if(!hasCreatedAStore) {
              SnackbarUtility.showInfoMessage(message: 'Create your store first');
            }else if(!hasCreatedAProduct) {
              SnackbarUtility.showInfoMessage(message: 'Add your product first');
            }else{
              DialerUtility.dial(number: mobileNumberShortcode);
            }
          },
          child: instruction,
        );

      }else{

        return SubscribeToStoreModalBottomSheet(
          store: firstCreatedStore!,
          trigger: instruction
        );

      }

    }

  }

  Widget get receiveOrderInstruction {

    if(hasReceivedAnOrder == true) {

      Widget instruction = RichText(
        text: TextSpan(
          text: 'Received ', 
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(
              text: '$totalReceivedOrders ${totalReceivedOrders == 1 ? 'order' : 'orders'}',
              style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline, color: Colors.green)
            ),
            const TextSpan(text: ' ❤️')
          ]
        )
      );

      return OrdersModalBottomSheet(
        store: firstCreatedStore!,
        onUpdatedOrder: _onUpdatedOrder,
        trigger: (openBottomModalSheet) => instruction,
        userOrderAssociation: UserOrderAssociation.teamMember,
      );

    }else{

      Widget instruction = RichText(
        text: TextSpan(
          text: 'Receive your ', 
          style: Theme.of(context).textTheme.bodyMedium,
          children: const [

            TextSpan(
              text: 'first order' ,
              style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)
            ),

          ]
        )
      );

      if(!hasCreatedAStore || !hasCreatedAProduct || !hasSubscribedAtleastOnce) {

        return GestureDetector(
          onTap: () {
            if(!hasCreatedAStore) {
              SnackbarUtility.showInfoMessage(message: 'Create your store first');
            }else if(!hasCreatedAProduct) {
              SnackbarUtility.showInfoMessage(message: 'Add your product first');
            }else if(!hasSubscribedAtleastOnce) {
              SnackbarUtility.showInfoMessage(message: 'Subscribe first');
            }else{
              /// Navigate to "Order" tab
              onChangeNavigationTab(homeProvider.orderTabIndex);
            }
          },
          child: instruction,
        );

      }else{

        return OrdersModalBottomSheet(
          store: firstCreatedStore!,
          onUpdatedOrder: _onUpdatedOrder,
          trigger: (openBottomModalSheet) => instruction,
          userOrderAssociation: UserOrderAssociation.teamMember,
        );

      }

    }

  }

  void _onUpdatedOrder(Order updatedOrder) {
    _showFirstCreatedStore();
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
            child: doesNotHaveResourceTotals || !sentFirstRequestToLoadStore
              ? const CustomCircularProgressIndicator(
                  margin: EdgeInsets.symmetric(vertical: 100),
                  strokeWidth: 2,
                  size: 16
                )
              : Column(
                  children: [
                        
                    /// Store Creation Milestones
                    if(hasCompletedMilestones || hasStoresJoinedAsNonCreator) _hasCompletedMilestones,

                    /// Has Not Completed Everything Content
                    if(!hasCompletedMilestones && !hasStoresJoinedAsNonCreator) _hasNotCompletedMilestones

                  ]
                )
          )
        )
      ),
    );
  }
}