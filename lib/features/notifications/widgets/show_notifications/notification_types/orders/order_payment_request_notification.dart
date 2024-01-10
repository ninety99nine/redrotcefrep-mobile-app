import 'package:bonako_demo/features/notifications/models/notification_types/orders/order_payment_request_notification.dart';
import 'package:bonako_demo/core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import 'package:bonako_demo/features/notifications/models/notification.dart' as model;
import 'package:bonako_demo/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/orders/providers/order_provider.dart';
import 'package:bonako_demo/core/shared_models/money.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class OrderPaymentRequestNotificationContent extends StatefulWidget {

  final bool isLoading;
  final model.Notification notification;
  
  const OrderPaymentRequestNotificationContent({
    super.key,
    required this.isLoading,
    required this.notification
  });

  @override
  State<OrderPaymentRequestNotificationContent> createState() => _OrderPaymentRequestNotificationContentState();
}

class _OrderPaymentRequestNotificationContentState extends State<OrderPaymentRequestNotificationContent> {

  bool get isLoading => widget.isLoading;
  String get storeName => storeProperties.name;
  DateTime get createdAt => notification.createdAt;
  Money get amount => transactionProperties.amount;
  String get orderNumber => orderProperties.number;
  model.Notification get notification => widget.notification;
  String get paymentMethodName => paymentMethodProperties.name;
  String get requestedByUserName => requestedByUserProperties.name;
  String? get dpoPaymentUrl => transactionProperties.dpoPaymentUrl;
  bool get isFullPayment => transactionProperties.percentage == 100;
  String get summary => orderPaymentRequestNotification.orderProperties.summary;
  OrderProvider get orderProvider => Provider.of<OrderProvider>(context, listen: false);
  StoreProperties get storeProperties => orderPaymentRequestNotification.storeProperties;
  OrderProperties get orderProperties => orderPaymentRequestNotification.orderProperties;
  TransactionProperties get transactionProperties => orderPaymentRequestNotification.transactionProperties;
  PaymentMethodProperties get paymentMethodProperties => orderPaymentRequestNotification.paymentMethodProperties;
  RequestedByUserProperties get requestedByUserProperties => orderPaymentRequestNotification.requestedByUserProperties;
  OrderPaymentRequestNotification get orderPaymentRequestNotification => OrderPaymentRequestNotification.fromJson(notification.data);

  TextStyle style(BuildContext context, {Color? color}) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      height: 1.4,
      color: color ?? Theme.of(context).primaryColor
    );
  }

  Widget notificationBody(BuildContext context) {

    return RichText(
      /// Payment request of
      text: TextSpan(
        text: 'Payment request of ',
        style: style(context, color: Colors.grey),
        children: [
          /// P100.00
          TextSpan(
            text: amount.amountWithCurrency,
            style: style(context),
          ),
          /// (Full Payment) || (Partial Payment)
          TextSpan(
            text: '${isFullPayment ? ' (Full payment)' : ' (Partial payment)'} ',
            style: style(context, color: Colors.grey),
          ),
          /// requested by
          TextSpan(
            text: ' requested by ',
            style: style(context, color: Colors.grey),
          ),
          /// John Doe
          TextSpan(
            text: requestedByUserName,
            style: style(context),
          ),
          /// using
          TextSpan(
            text: ' using ',
            style: style(context, color: Colors.grey),
          ),
          /// Credit/Debit Card
          TextSpan(
            text: paymentMethodName,
            style: style(context),
          ),
          /// - VIP ticket for P500.00
          TextSpan(
            text: ' - $summary',
            style: style(context, color: Colors.grey),
          )
        ]
      ),
    );

  }

  Widget notificationFooter(BuildContext context) {
    
    return RichText(
      /// ~ Order
      text: TextSpan(
        text: '~ Order ',
        style: style(context, color: Colors.grey),
        children: [
          /// #00001
          TextSpan(
            text: '#$orderNumber',
            style: style(context),
          ),
        ]
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
    
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
    
              /// Store Name
              Expanded(child: CustomTitleSmallText(storeName)),
    
              /// Spacer
              const SizedBox(width: 8),
              
              /// Notificaiton Date And Time Ago
              CustomBodyText(timeago.format(createdAt, locale: 'en_short')),
    
            ],
          ),
    
          /// Spacer
          const SizedBox(height: 4),
          
          /// Notification Content
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
    
              /// Notification Body
              Expanded(
                child: notificationBody(context)
              ),
          
              /// Spacer
              const SizedBox(width: 8),
    
              /// Loader
              if(isLoading) const CustomCircularProgressIndicator(
                size: 8, 
                strokeWidth: 2,
                margin: EdgeInsets.only(top: 4, right: 4),
              ),
          
              /// Icon
              if(!isLoading) const Icon(Icons.attach_money_rounded, size: 16,),
    
            ],
          ),
          
          /// Spacer
          const SizedBox(height: 4),
    
          /// Notification Footer
          notificationFooter(context)
    
        ],
      ),
    );
  }
}
