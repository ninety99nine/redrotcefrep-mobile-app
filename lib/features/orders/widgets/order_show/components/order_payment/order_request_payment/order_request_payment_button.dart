import 'package:bonako_demo/core/shared_models/user_order_collection_association.dart';
import 'package:bonako_demo/core/shared_widgets/icon_button/credit_card_icon_button.dart';
import 'package:bonako_demo/features/orders/widgets/order_show/components/order_payment/order_request_payment/order_request_payment_dialog.dart';
import 'package:bonako_demo/core/shared_widgets/button/custom_elevated_button.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import 'package:bonako_demo/features/transactions/models/transaction.dart';
import 'package:bonako_demo/features/orders/models/order.dart';
import 'package:bonako_demo/core/utils/dialog.dart';
import 'package:flutter/material.dart';

enum OrderRequestPaymentButtonType {
  icon,
  button
}

class OrderRequestPaymentButton extends StatefulWidget {
  
  final Order order;
  final Function(Transaction)? onRequestPayment;
  final OrderRequestPaymentButtonType orderRequestPaymentButtonType;

  const OrderRequestPaymentButton({
    Key? key,
    required this.order,
    this.onRequestPayment,
    this.orderRequestPaymentButtonType = OrderRequestPaymentButtonType.button
  }) : super(key: key);

  @override
  State<OrderRequestPaymentButton> createState() => _OrderRequestPaymentButtonState();
}

class _OrderRequestPaymentButtonState extends State<OrderRequestPaymentButton> {

  Order get order => widget.order;
  ShoppableStore get store => order.relationships.store!;
  bool get canRequestPayment => order.attributes.canRequestPayment;
  Function(Transaction)? get onRequestPayment => widget.onRequestPayment;
  bool get canManageOrders => store.attributes.userStoreAssociation!.canManageOrders;
  bool get isAssociatedAsAFriend => userOrderCollectionAssociation?.isAssociatedAsFriend ?? false;
  bool get isAssociatedAsACustomer => userOrderCollectionAssociation?.isAssociatedAsCustomer ?? false;
  bool get requestingPayment => canManageOrders && !(isAssociatedAsACustomer || isAssociatedAsAFriend);
  OrderRequestPaymentButtonType get orderRequestPaymentButtonType => widget.orderRequestPaymentButtonType;
  UserOrderCollectionAssociation? get userOrderCollectionAssociation => order.attributes.userOrderCollectionAssociation;


  Widget get requestPaymentButton {
    
    if(orderRequestPaymentButtonType == OrderRequestPaymentButtonType.button) {

      return CustomElevatedButton(
        fontSize: 12,
        prefixIcon: Icons.payment,
        alignment: Alignment.center,
        width: requestingPayment ? 130 : 120,
        onPressed: showOrderRequestPaymentDialog,
        requestingPayment ? 'Request Payment' : 'Pay Now',
      );

    }else{

      return CreditCardIconButton(onTap: showOrderRequestPaymentDialog);

    }

  }

  void showOrderRequestPaymentDialog() {

    /// Open Dialog
    DialogUtility.showInfiniteScrollContentDialog(
      context: context,
      heightRatio: 0.9,
      showCloseIcon: false,
      backgroundColor: Colors.transparent,
      content: OrderRequestPaymentDialog(
        order: order,
        onRequestPayment: onRequestPayment,
      )
    );

  }

  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        if(canRequestPayment) requestPaymentButton
      ],
    );
  }
}