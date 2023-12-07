import 'package:bonako_demo/features/stores/widgets/store_cards/store_card/primary_section_content/profile/profile_right_side/store_dialer.dart';
import 'package:bonako_demo/features/orders/widgets/order_show/components/order_other_associated_friends.dart';
import 'package:bonako_demo/features/orders/widgets/order_show/components/order_customer_mobile_number.dart';
import 'package:bonako_demo/features/orders/widgets/order_show/components/order_customer_display_name.dart';
import 'package:bonako_demo/features/orders/widgets/order_show/components/order_payment_details.dart';
import 'package:bonako_demo/features/orders/widgets/order_show/components/order_collection_type.dart';
import 'package:bonako_demo/features/orders/widgets/order_show/components/order_payment_method.dart';
import 'package:bonako_demo/features/orders/widgets/order_show/components/order_call_customer.dart';
import 'package:bonako_demo/features/orders/widgets/order_show/components/order_cart_details.dart';
import 'package:bonako_demo/features/orders/widgets/order_show/components/order_created_at.dart';
import 'package:bonako_demo/core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import 'package:bonako_demo/features/orders/widgets/order_show/components/order_occasion.dart';
import 'package:bonako_demo/features/orders/widgets/order_show/components/order_number.dart';
import 'package:bonako_demo/core/shared_models/user_order_collection_association.dart';
import 'package:bonako_demo/features/payment_methods/models/payment_method.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/orders/providers/order_provider.dart';
import 'package:bonako_demo/core/shared_models/name_and_description.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import 'package:bonako_demo/features/occasions/models/occasion.dart';
import 'package:bonako_demo/features/orders/models/order.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class OrderPaymentContent extends StatefulWidget {
  
  final Order order;
  final Function(Order)? onUpdatedOrder;

  const OrderPaymentContent({
    Key? key,
    required this.order,
    this.onUpdatedOrder
  }) : super(key: key);

  @override
  State<OrderPaymentContent> createState() => OrderPaymentContentState();
}

class OrderPaymentContentState extends State<OrderPaymentContent> {
  
  late Order order;
  bool isLoading = false;

  ShoppableStore get store => order.relationships.store!;
  void _startLoader() => setState(() => isLoading = true);
  void _stopLoader() => setState(() => isLoading = false);
  Function(Order)? get onUpdatedOrder => widget.onUpdatedOrder;
  bool get canManageOrders => store.attributes.userStoreAssociation!.canManageOrders;
  OrderProvider get orderProvider => Provider.of<OrderProvider>(context, listen: false);

  bool get hasOccasion => occasion != null;
  bool get hasPaymentMethod => paymentMethod != null;
  bool get hasCollectionType => collectionType != null;
  bool get hasSpecialNote => order.specialNote != null;
  Occasion? get occasion => order.relationships.occasion;
  NameAndDescription? get collectionType => order.collectionType;
  bool get hasOtherAssociatedFriends => otherAssociatedFriends != null;
  PaymentMethod? get paymentMethod => order.relationships.paymentMethod;
  String? get otherAssociatedFriends => order.attributes.otherAssociatedFriends;
  bool get isAssociatedAsAFriend => userOrderCollectionAssociation?.isAssociatedAsFriend ?? false;
  bool get isAssociatedAsACustomer => userOrderCollectionAssociation?.isAssociatedAsCustomer ?? false;
  UserOrderCollectionAssociation? get userOrderCollectionAssociation => order.attributes.userOrderCollectionAssociation;

  @override
  void initState() {
    super.initState();
    order = widget.order;

    /// If the order cart does not exist, then request this order cart
    if(order.relationships.cart == null) _requestShowOrder();
  }

  void _requestShowOrder() async {

    if(isLoading) return;

    _startLoader();

    orderProvider.setOrder(order).orderRepository.showOrder(
      withCart: true,
      withCustomer: true,
      withCountTransactions: true,
      withOccasion: order.occasionId == null ? false : true,
      withPaymentMethod: order.paymentMethodId == null ? false : true,
      withDeliveryAddress: order.deliveryAddressId == null ? false : true,
    ).then((response) {

      if(response.statusCode == 200) {
        
        _onUpdatedOrder(Order.fromJson(response.data));

      }

    }).whenComplete(() {
      _stopLoader();
    });

  }

  void _onUpdatedOrder(Order updatedOrder) {
    setState(() {

      /// Set the store on this updated order
      updatedOrder.relationships.store = order.relationships.store;

      /// Update the order with the updated order
      order = updatedOrder;

      /// Notify the parent widget of the updated order
      notifyParentWidgetOnUpdatedOrder(order);

    });

  }

  void notifyParentWidgetOnUpdatedOrder(Order order) {
    if(onUpdatedOrder != null) onUpdatedOrder!(order);
  }

  Widget get orderOverview {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16.0),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 500),
        child: AnimatedSwitcher(
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          duration: const Duration(milliseconds: 500),
          child: isLoading 
            ? const SizedBox()
            : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [

                /// Customer Information
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            
                          /// Order Customer Name
                          OrderCustomerDisplayName(order: order),
                  
                          /// Spacer
                          const SizedBox(height: 4,),
                  
                          /// Order Customer Mobile Number
                          OrderCustomerMobileNumber(order: order),
                    
                          if(hasOtherAssociatedFriends) ...[
                    
                            /// Spacer
                            const SizedBox(height: 4,),

                            /// Other Associated Friends e.g "+ 2 friends" or "for 2 friends"
                            OrderOtherAssociatedFriends(order: order),

                          ]

                        ],
                      ),
                
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                    
                          /// Order Created At Time Ago
                          OrderCreatedAt(order: order),

                          if(hasCollectionType || hasPaymentMethod) ...[
                        
                            /// Spacer
                            const SizedBox(height: 4,),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                
                                /// Collection Type
                                OrderCollectionType(order: order),

                                if(hasCollectionType && hasPaymentMethod) ...[

                                  /// Separator
                                  const CustomBodyText('|', lightShade: true, margin: EdgeInsets.symmetric(horizontal: 4.0)),

                                ],

                                /// Payment Method
                                OrderPaymentMethod(order: order),

                              ],
                            ),

                          ],
                    
                          /// Order Occasion
                          if(hasOccasion) ...[
                    
                            /// Spacer
                            const SizedBox(height: 4,),
                            
                            /// Order Occasion
                            OrderOccasion(order: order),

                          ]

                        ],
                      ),
                
                    ],
                  ),
                ),

                /// Divider
                const Divider(height: 0),

              ],
            )
        )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 500),
      child: AnimatedSwitcher(
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        duration: const Duration(milliseconds: 500),
        child: Column(
          key: ValueKey(order.id),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Order Overview
            orderOverview,

            /// 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      /// Order Number
                      OrderNumber(order: order),
              
                      /// Order Call Customer
                      if(canManageOrders && !isLoading) OrderCallCustomer(order: order),
              
                      /// Store Dialer
                      if(!canManageOrders && (isAssociatedAsACustomer || isAssociatedAsAFriend)) StoreDialer(store: store),
                      
                    ],
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: isLoading ? [

                      const CustomCircularProgressIndicator(
                        margin: EdgeInsets.symmetric(vertical: 40),
                      ),

                    ] : [
            
                      /// Order Cart Details
                      OrderCartDetails(order: order),
                
                      /// Order Payment Details
                      OrderPaymentDetails(order: order, onMarkedAsPaid: _requestShowOrder, onRequestPayment: (_) => _requestShowOrder),
                
                      /// Spacer
                      const SizedBox(height: 50),

                    ],
                  )
            
                ],
              ),
            ),

          ],
        )
      )
    );
  }
}