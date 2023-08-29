import 'dart:convert';

import 'package:bonako_demo/core/shared_models/user.dart';
import 'package:bonako_demo/core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/authentication/providers/auth_provider.dart';
import 'package:bonako_demo/features/stores/providers/store_provider.dart';
import 'package:bonako_demo/features/stores/widgets/store_cards/store_card/primary_section_content/profile/profile_right_side/adverts/show_adverts/advert_carousel.dart';
import 'package:bonako_demo/features/stores/widgets/store_cards/store_card/secondary_section_content/secondary_section_content.dart';
import 'package:bonako_demo/features/orders/widgets/orders_show/user_orders_in_horizontal_list_view_infinite_scroll.dart';

import '../subscribe_to_store/subscribe_to_store_modal_bottom_sheet/subscribe_to_store_modal_bottom_sheet.dart';
import '../store_menu/store_menu_modal_bottom_sheet/store_menu_modal_bottom_sheet.dart';
import '../store_cards/store_card/primary_section_content/primary_section_content.dart';
import '../../../../core/shared_widgets/message_alert/custom_message_alert.dart';
import '../../../shopping_cart/widgets/shopping_cart_content.dart';
import '../add_store_to_group/add_to_group_button.dart';
import '../follow_store/follow_store_button.dart';
import '../../services/store_services.dart';
import '../../models/shoppable_store.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class StorePage extends StatefulWidget {

  static const routeName = 'StorePage';

  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
  
}

class _StorePageState extends State<StorePage> {

  StoreProvider? storeProvider;

  @override
  void initState() {
    super.initState();
    
    /**
     *  Set the storeProvider from this initState() method so that we can run method on dispose()
     *  without encoutering the following flutter error:
     * 
     *  To safely refer to a widget's ancestor in its dispose() method, save a reference to the
     *  ancestor by calling dependOnInheritedWidgetOfExactType() in the widget's
     *  didChangeDependencies() method.
     * 
     *  This error occurs if the storeProvider is referenced after its declared as a getter
     *  method, just like the following:
     * 
     *  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
     */
    storeProvider = Provider.of<StoreProvider>(context, listen: false);

    /**
     *  The Future.delayed() function is used to prevent the following flutter error:
     * 
     *  This _InheritedProviderScope<StoreProvider?> widget cannot be marked as needing 
     *  to build because the framework is already in the process of building widgets. 
     *  A widget can be marked as needing to be built during the build phase only if 
     *  one of its ancestors is currently building. This exception is allowed 
     *  because the framework builds parent widgets before children, which 
     *  means a dirty descendant will always be built. Otherwise, the 
     *  framework might not visit this widget during this build phase
     * 
     *  This is because updateShowingStorePageStatus() executes the
     *  notifyListeners() method which causes the widgets to
     *  rebuild. We should wait for the initState to first
     *  complete before we can execute this method.  
     */
    Future.delayed(Duration.zero).then((value) {

      /// Indicate that we are showing the store page
      storeProvider!.updateShowingStorePageStatus(true);

    });

  }

  @override
  void dispose() {

    super.dispose();

    /**
     *  The Future.delayed() function is used to prevent the following flutter error:
     * 
     *  This _InheritedProviderScope<StoreProvider?> widget cannot be marked as needing to 
     *  build because the framework is locked. The widget on which setState() or 
     *  markNeedsBuild() was called was: _InheritedProviderScope<StoreProvider?>
     */
    Future.delayed(Duration.zero).then((value) {

      /// Indicate that we are not showing the store page
      storeProvider!.updateShowingStorePageStatus(false);

    });

  }

  @override
  Widget build(BuildContext context) {

    final ShoppableStore store = ModalRoute.of(context)!.settings.arguments as ShoppableStore;

    return Scaffold(
      body: SafeArea(
        child: StorePageContent(store: store),
      ),
    );
  }
}

class StorePageContent extends StatefulWidget {

  final ShoppableStore store;
  
  const StorePageContent({required this.store, Key? key}) : super(key: key);

  @override
  State<StorePageContent> createState() => _StorePageContentState();
}

class _StorePageContentState extends State<StorePageContent> {

  ShoppableStore? store;
  bool isLoading = false;

  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);

  void _stopLoader() => setState(() => isLoading = false);

  @override
  void initState() {
    super.initState();

    /// Set the widget store as the local store
    store = widget.store;

    /**
     *  We need to re-fetch this store on two conditions:
     * 
     *  1) If the user and store association does not exist. This usually occurs when we
     *     navigate to this StorePage widget after searching for a store. Stores that
     *     are being searched don't contain the user and store association 
     *     relationship. We need this information to know if the user has
     *     access to the store as a shopper and as a team member.
     * 
     *  2) If the store does not have the relationship totals e.g total followers,
     *     team members, e.t.c. This usually occurs when we navigate to this
     *     StorePage widget after clicking on a store card from the user's
     *     profile. Usually such store cards do not request these totals
     *     so that we can improve performance.
     */

    final doesNotHaveUserStoreAssociation = store!.attributes.userStoreAssociation == null;
    final doesNotHaveRelationshipTotals = store!.teamMembersCount == null ||
                                          store!.followersCount == null ||
                                          store!.couponsCount == null ||
                                          store!.reviewsCount == null ||
                                          store!.ordersCount == null;

    if(doesNotHaveUserStoreAssociation || doesNotHaveRelationshipTotals) {
      
      requestStore();

    }

  }

  void requestStore() {

    isLoading = true;

    storeProvider.storeRepository.showStore(
      storeUrl: store!.links.self.href,
      withCountTeamMembers: true,
      withVisibleProducts: true,
      withVisitShortcode: true,
      withCountFollowers: true,
      withCountProducts: true,
      withCountReviews: true,
      withCountCoupons: true,
      withCountOrders: true,
      withRating: true,
    ).then((response) {

      if(response.statusCode == 200) {

        final responseBody = jsonDecode(response.body);

        setState(() {
        
          /// Set the response store as the local store
          store = ShoppableStore.fromJson(responseBody);

        });

      }
      
    }).whenComplete(() {

      _stopLoader();

    });

  }

  @override
  Widget build(BuildContext context) {

    return isLoading 
      ? Column(
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
  
              /// Back Arrow
              IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),

            ],
          ),

          const CustomCircularProgressIndicator(),

        ],
      )
      : ListenableProvider.value(
        value: store,
        child: const Content()
      );
  }
}

class Content extends StatelessWidget {

  const Content({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    
    /**
     *  Capture the store that was passed on ListenableProvider.value()
     *  
     *  Set listen to "true'" to catch changes at this level of the
     *  widget tree. For now i have disabled listening at this
     *  level because i can listen to the store changes from
     *  directly on the ShoppableProductCards widget level, 
     *  which is a descendant widget of this widget.
     */
    ShoppableStore store = Provider.of<ShoppableStore>(context, listen: true);
    AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);

    User user = authProvider.user!;
    bool hasDescription = store.description != null;
    bool canAccessAsShopper = StoreServices.canAccessAsShopper(store);
    double logoRadius = canAccessAsShopper && hasDescription ? 36 : 24;
    bool isTeamMemberWhoHasJoined = StoreServices.isTeamMemberWhoHasJoined(store);

    return SingleChildScrollView(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
      
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                              
                      /// Back Arrow
                      IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
                            
                      /// Menu Modal Bottom Sheet
                      StoreMenuModalBottomSheet(
                        store: store,
                      ),
                            
                    ],
                  ),
          
                  /// Store Logo, Profile, Adverts, Rating, e.t.c
                  StorePrimarySectionContent(
                    store: store,
                    logoRadius: logoRadius, 
                    showProfileRightSide: false,
                    subscribeButtonAlignment: Alignment.topRight
                  ),
          
                  if(canAccessAsShopper) Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      
                      /// Add Store To Group Button
                      AddStoreToGroupButton(store: store),
            
                      /// Spacer
                      const SizedBox(width: 8,),
          
                      /// Follow / Unfollow Button
                      FollowStoreButton(store: store, alignment: Alignment.centerRight),
          
                    ],
                  ),
            
                ],
              ),
            ),

            /// Store Adverts, Products, Shopping Cart e.t.c
            if(isTeamMemberWhoHasJoined || (!isTeamMemberWhoHasJoined && canAccessAsShopper)) ...[
        
              /**
               *  The StoreSecondarySectionContent() widgets is placed here so that they can listen 
               *  to changes on the store and pickup those new updates e.g Whenever we toggle the 
               *  teamMemberWantsToViewAsCustomer on the ShoppableStore model, we execute the 
               *  notifyListeners() method so that this change and be picked up by these 
               *  widgets and render the UI to reflect whether we want to view as a 
               *  customer or a team member. This is not the only type of update,
               *  but the idea applies across any update on the store model that
               *  requires widgets to rebuild.
               */
              StoreSecondarySectionContent(
                store: store,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                shoppingCartCurrentView: ShoppingCartCurrentView.storePage
              ),
          
              /// Divider
              const Divider(height: 40,),
          
            ],
        
            /// User Orders
            UserOrdersInHorizontalListViewInfiniteScroll(
              store: store,
              user: user,
            ),
            
            //  Spacer
            const SizedBox(height: 100),
          ]
      )
    );
  }
}
