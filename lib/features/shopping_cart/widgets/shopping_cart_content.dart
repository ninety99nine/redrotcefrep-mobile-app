import 'package:bonako_demo/features/orders/widgets/order_show/components/order_payment/order_request_payment/order_request_payment_dialog.dart';
import 'package:bonako_demo/features/orders/widgets/orders_show/orders_modal_bottom_sheet/orders_modal_bottom_sheet.dart';
import 'package:bonako_demo/features/shopping_cart/widgets/delivery_or_pickup/delivery_or_pickup.dart';
import 'package:bonako_demo/features/shopping_cart/widgets/occassion/occasion_details.dart';
import 'package:bonako_demo/features/shopping_cart/widgets/special_note/special_note.dart';
import 'package:bonako_demo/features/shopping_cart/widgets/payment/payment_details.dart';
import '../../products/widgets/shoppable_product_cards/shoppable_product_cards.dart';
import '../../../core/shared_widgets/button/custom_elevated_button.dart';
import 'package:bonako_demo/features/orders/models/order.dart';
import 'package:bonako_demo/core/utils/error_utility.dart';
import '../../../core/utils/api_conflict_resolver.dart';
import '../../order_for/widgets/order_for_details.dart';
import '../../friend_groups/models/friend_group.dart';
import '../../stores/providers/store_provider.dart';
import 'package:bonako_demo/core/utils/dialog.dart';
import '../../stores/models/shoppable_store.dart';
import '../../../core/shared_models/cart.dart';
import '../../../core/shared_models/user.dart';
import '../../../core/utils/debouncer.dart';
import 'package:collection/collection.dart';
import '../../../core/utils/snackbar.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'cart_details.dart';

class ShoppingCartContent extends StatefulWidget {

  final ShoppingCartCurrentView shoppingCartCurrentView;

  const ShoppingCartContent({
    super.key,
    required this.shoppingCartCurrentView
  });

  @override
  State<ShoppingCartContent> createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCartContent> {

  ShoppableStore? store;
  Map serverErrors = {};
  bool isSubmitting = false;
  bool hasInitialized = false;
  List lastSelectedProductItems = [];
  bool get hasStore => store != null;
  String? get orderFor => store?.orderFor;
  bool get isLoading => store?.isLoading ?? true;
  List<User> get friends => store == null ? [] : store!.friends;
  bool get canShowCallToAction => hasStore && hasSelectedProducts;
  bool get hasSelectedProducts => store?.hasSelectedProducts ?? false;
  List<FriendGroup> get friendGroups => store == null ? [] : store!.friendGroups;
  bool get doesNotHaveShoppingCart => (store?.hasShoppingCart ?? false) == false;
  final DebouncerUtility debouncerUtility = DebouncerUtility(milliseconds: 1000);
  ShoppingCartCurrentView get shoppingCartCurrentView => widget.shoppingCartCurrentView;
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  final ApiConflictResolverUtility apiConflictResolverUtility = ApiConflictResolverUtility();
  bool get isShowingStorePage => Provider.of<StoreProvider>(context, listen: true).isShowingStorePage;
  bool get isShoppingOnStorePage => (shoppingCartCurrentView == ShoppingCartCurrentView.storePage && isShowingStorePage);
  bool get isShoppingOnStoreCard => (shoppingCartCurrentView == ShoppingCartCurrentView.storeCard && !isShowingStorePage);
  bool get isShoppingOnStoreOrdersModalBottomSheet => (shoppingCartCurrentView == ShoppingCartCurrentView.storeOrdersModalBottomSheet);

  /// This allows us to access the state of OrdersModalBottomSheetState widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<OrdersModalBottomSheetState> _ordersModalBottomSheetState = GlobalKey<OrdersModalBottomSheetState>();

  void _startSubmittionLoader() => setState(() => isSubmitting = true);
  void _stopSubmittionLoader() => setState(() => isSubmitting = false);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    /// Get the updated Shoppable Store Model
    store = Provider.of<ShoppableStore>(context, listen: false);

    /**
     *  If the Shoppable Store Model does not have any selected products, but the current state of the 
     *  lastSelectedProductItems is not empty, then we must reset its value by also making it empty. 
     *  Lets assume that the app loads the first time and this ShoppingCartContent widget is rendered. In 
     *  this state the hasSelectedProducts = false and lastSelectedProductItems is empty. When we 
     *  select any product then the hasSelectedProducts = true and the Shoppable Store Model 
     *  selectedProducts property (which has the selected product) will differ from the 
     *  lastSelectedProductItems property (which has no selected product), therefore
     *  allowing the _requestInspectShoppingCart() to make a call to update the
     *  Shoppable Store Model shoppingCart and the current state of the 
     *  lastSelectedProductItems to match the state of the 
     *  selectedProducts. 
     * 
     *  If the same product is removed, the selected products are emptied and the Shoppable Store 
     *  Model shoppingCart is removed and the notify listeners will be called leading to this 
     *  didChangeDependencies() method to be called with the emptied selected products. The 
     *  lastSelectedProductItems still holds the old state, but the _requestInspectShoppingCart() 
     *  method will not run since hasSelectedProducts = false. The problem is that if i now 
     *  select the same product again, the state of the  Shoppable Store Model selectedProducts 
     *  will be changed, but it will be the same as the old state of lastSelectedProductItems 
     *  and the _requestInspectShoppingCart() method will not be called beause 
     *  _productsHaveChanged() = false eventhough hasSelectedProducts = true. 
     *  
     *  This means we can't update the shopping cart which was recently removed. To combat this issue, 
     *  we must reset the lastSelectedProductItems everytime that the Shoppable Store Model 
     *  selectedProducts is emptied. As a result, when the Shoppable Store Model 
     *  selectedProducts are populated, the outcome is  different from that of 
     *  the lastSelectedProductItems and the _requestInspectShoppingCart()
     *  method will now be called since _productsHaveChanged() = true and
     *  hasSelectedProducts = true.
     */
    if(hasSelectedProducts == false && lastSelectedProductItems.isNotEmpty) {
      lastSelectedProductItems = [];
    }
    
    /**
     *  When selecting a product, changing quantity, e.t.c, the Shoppable
     *  Store Model will be updated, which will then notify listeners, 
     *  and since we are listening for changes on this Store Model
     *  because of the property set on the build() method:
     * 
     *  Provider.of<ShoppableStore>(context, listen: true);
     * 
     *  This build() method will therefore be triggered to rebuild, thereby 
     *  causing the didChangeDependencies() to run as well. Once this
     *  happens we can execute the following updates:
     * 
     *  1) _requestInspectShoppingCart(): We can request the shopping cart
     * 
     *  Resolving Infinite Loop Scenerio
     *  --------------------------------
     * 
     *  When making the first Request to retrieve the shopping cart, the Request will complete
     *  and execute the setShoppingCart() of the ShoppableStore model. This will update the
     *  shopping cart on the ShoppableStore model and notify listeners. As a result the 
     *  build() method will be called again as well as the didChangeDependencies(). 
     *  This will cause the _requestInspectShoppingCart() to run again, and the 
     *  cycle repeats itself over and over again without end (infinite loop)
     * 
     *  To prevent this infinite loop, we must always check if any changes have been
     *  made on the selected products before we can make our request. If no changes
     *  have been made then the request must not be attempted.
     * 
     *  About hasInitialized
     *  --------------------
     * 
     *  The "hasInitialized" simply prevents us from running _requestInspectShoppingCart()
     *  while the Widget is being initialised. This would trigger an automatic execution
     *  of _requestInspectShoppingCart() e.g When we navigate from the StoreCard to
     *  the StorePage, the Store Page will start to setup this ShoppingCartContent widget,
     *  thereby calling didChangeDependencies() before the build() method is
     *  called and therefore automatically make a request to update the
     *  shopping cart. Remove "hasInitialized" if this is desired.
     * 
     *  We don't really worry about the _requestInspectShoppingCart() being automatically 
     *  executed in the case of the ShoppingCartContent() being a descendant of a StoreCard() 
     *  because the StoreCard() normally starts without a shoppingCart or selected 
     *  products. So since this ShoppingCartContent() widget's lastSelectedProductItems 
     *  are empty and the Shoppable Store selectedProducts are empty, we 
     *  therefore don't have  a difference in items that could cause the 
     *  _requestInspectShoppingCart() to be executed. As a result this
     *  only becomes a cause for concern when ShoppingCartContent() is
     *  being built while we already have selectedProducts on the
     *  Shoppable Store Model.
     * 
     *  In the case of the ShoppingCartContent() being a descendant of a StorePage(), we 
     *  normally navigate to the StorePage() with or without the shoppingCart or 
     *  selected products. So depending on the case, this auto-execution of the
     *  _requestInspectShoppingCart() might not be desired. In our case, the
     *  justification is to minimize the number of Api Requests being made.
     */
    if( hasInitialized && (isShoppingOnStoreCard || isShoppingOnStorePage || isShoppingOnStoreOrdersModalBottomSheet) && hasSelectedProducts && _productsHaveChanged() ) {

      /// Request the shopping cart
      _requestInspectShoppingCart();

    }

    hasInitialized = true;

  }

  bool _productsHaveChanged() {

    /**
     *  DeepCollectionEquality() helps us to deeply compare lists that might contain other collections
     * 
     *  Reference: https://stackoverflow.com/questions/10404516/how-can-i-compare-lists-for-equality-in-dart 
     */
    Function deepEq = const DeepCollectionEquality().equals;

    //  Get a list of each selected product id, name and quantity
    List selectedProductItems = store == null ? [] : store!.selectedProducts.map((product) => [product.id, product.name, product.quantity]).toList();

    //  Check if the two lists are the same or different (Return true if they are different)
    final bool hasChanged = deepEq(selectedProductItems, lastSelectedProductItems) == false;
    
    return hasChanged;

  }

  Future<void> _requestInspectShoppingCart() async {

    /**
     *  Future.delayed() is used to avaoid the following error that occurs when attempting
     *  to run the store!.startLoader() method. The error is shown belo
     * 
     *  This _InheritedProviderScope<ShoppableStore?> widget cannot be marked as needing 
     *  to build because the framework is already in the process of building widgets. A
     *  widget can be marked as needing to be built during the build phase only if one 
     *  of its ancestors is currently building. This exception is allowed because the 
     *  framework builds parent widgets before children, which means a dirty 
     *  descendant will always be built. Otherwise, the framework might not 
     *  visit this widget during this build phase.
     */
    Future.delayed(Duration.zero).then((_) => store!.startLoader());

    //  Get a list of each selected product id, name and quantity
    lastSelectedProductItems = store!.selectedProducts.map((product) => [product.id, product.name, product.quantity]).toList();

    /**
     *  Using Debouncer to delay the request until user has stopped
     *  interacting with the shopping cart for one second
     */
    await debouncerUtility.run(() async {

      /// The apiConflictResolverUtility resoloves the comflict of 
      /// retrieving data returned by the wrong request. Whenever
      /// we make multiple requests, we only ever want the data 
      /// of the last request and not any other request.
      apiConflictResolverUtility.addRequest(
        
        /// The request we are making
        onRequest: () => storeProvider.setStore(store!).storeRepository.inspectShoppingCart(
          deliveryDestination: store!.deliveryDestination,
          products: store!.selectedProducts,
          cartCouponCodes: [],
        ),
        
        /// The response returned by the last request
        onCompleted: (response) {

          if(!mounted) return;

          if( response.statusCode == 200 ) {

            setState(() {

              /// Capture the shopping cart
              final Cart shoppingCart = Cart.fromJson(response.data);

              /// Set the shopping cart on the Shoppable Store Model
              /// Don't notify listeners, since this will be
              /// handled by the store!.stopLoader() method
              store!.setShoppingCart(
                shoppingCart,
                canNotifyListeners: false
              );

              /// After the Order is created we automatically open the 
              /// Orders Modal Popup to show the Order on the list of
              /// other orders. This functionality is part of the
              /// features/orders/widgets/orders_modal_popup.dart
            });

          }

        }, 
        
        /// What to do while the request is loading
        onStartLoader: () {
          /// On the next request continue showing the loader incase the previous request
          /// stopped the loader. This makes sure that the loader stays loading as long
          /// as we have a request executing.
          if(mounted) store!.startLoader();
        },
        
        /// What to do when the request completes
        onStopLoader: () {
          if(mounted) store!.stopLoader();
        }
        

      /// On Error
      ).catchError((e) {

        if(mounted) {

          SnackbarUtility.showErrorMessage(message: 'Can\'t show shopping cart');

        }

      });

    });

  }
  
  Future<void> _requestConvertShoppingCart() async {

    print('_requestConvertShoppingCart ####################');

    _startSubmittionLoader();
    
    await storeProvider.setStore(store!).storeRepository.convertShoppingCart(
      deliveryDestination: store!.deliveryDestination,
      addressForDelivery: store!.addressForDelivery,
      pickupDestination: store!.pickupDestination,
      collectionType: store!.collectionType,
      products: store!.selectedProducts,
      specialNote: store!.specialNote,
      friendGroups: friendGroups,
      occasion: store!.occasion,
      cartCouponCodes: [],
      orderFor: orderFor!,
      friends: friends,
    ).then((response) async {

      if(!mounted) return;

      if( response.statusCode == 201 ) {

        final Order createdOrder = Order.fromJson(response.data);

        /// Set the store relationship
        createdOrder.relationships.store = store;

        setState(() {
              
          /// Increment the number of orders placed
          store!.ordersCount = store!.ordersCount! + 1;

          /// Unset the shopping cart on the Shoppable Store Model
          store!.resetShoppingCart(
            canNotifyListeners: true
          );

          /// If the store has the onCreatedOrder method
          if(store!.onCreatedOrder != null) {

            /// Trigger this onCreatedOrder method and pass this order
            store!.onCreatedOrder!(createdOrder);

          }

        });
        
        SnackbarUtility.showSuccessMessage(message: 'Your order has been sent.\nOpen orders to stay up to date', duration: 6);
        
        if(!isShoppingOnStoreOrdersModalBottomSheet) {
          openOrdersModalBottomSheet();
        }

        if(createdOrder.attributes.canRequestPayment) {

          Future.delayed(const Duration(seconds: 1)).then((value) {

            /// Open Dialog
            showOrderRequestPaymentDialog(createdOrder);

          });

        }

      }

    }).onError((dio.DioException exception, stackTrace) {

      ErrorUtility.setServerValidationErrors(setState, serverErrors, exception);

    }).catchError((error) {

      printError(info: error.toString());

      SnackbarUtility.showErrorMessage(message: 'Can\'t show placed order');

    }).whenComplete(() {

      _stopSubmittionLoader();

    });

  }

  void openOrdersModalBottomSheet() {
    if(_ordersModalBottomSheetState.currentState != null) {
      _ordersModalBottomSheetState.currentState!.openBottomModalSheet();
    }
  }

  void showOrderRequestPaymentDialog(Order createdOrder)
  {
    /// Open Dialog
    DialogUtility.showInfiniteScrollContentDialog(
      context: context,
      heightRatio: 0.9,
      showCloseIcon: false,
      backgroundColor: Colors.transparent,
      content: OrderRequestPaymentDialog(
        order: createdOrder,
        onRequestPayment: (_) => {},
      )
    );
  }

  @override
  Widget build(BuildContext context) {

    /// Listen to changes on the Shoppable Store Model that was passed on 
    /// ListenableProvider.value() of the StoreCard. Once these changes
    /// occur, the didChangeDependencies() change will be notified
    /// first so that we can capture the store and its changes. We 
    /// can then run any other logic after the updated store is 
    /// retrieved. After the didChangeDependencies() completes
    /// its logic, this build() method will be called to
    /// rebuild the UI and implement any new changes.
    Provider.of<ShoppableStore>(context, listen: true);

    return Column(
      children: [

        /// Products 
        ShoppableProductCards(
          shoppingCartCurrentView: shoppingCartCurrentView
        ),

        /// Show the cart details
        const CartDetails(),

        /// Show the order for details
        const OrderForDetails(),

        /// Show the occasion details
        const OccasionDetails(),

        /// Show the special note
        SpecialNote(serverErrors: serverErrors),

        /// Show the payment details
        const PaymentDetails(),

        /// Show the cart details
        const DeliveryOrPickup(),

        //  Call To Action
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: canShowCallToAction ? CustomElevatedButton(
            width: 100,
            'Place Order',
            isLoading: isSubmitting,
            alignment: Alignment.center,
            disabled:  doesNotHaveShoppingCart || isLoading,
            onPressed: isSubmitting ? null : _requestConvertShoppingCart,
          ) : null,
        ),

        /// Orders Modal Bottom Sheet
        OrdersModalBottomSheet(
          store: store,
          key: _ordersModalBottomSheetState,
          trigger: (openBottomModalSheet) => Container(),
        )

      ],
    );

  }
}