import 'package:perfect_order/features/notifications/models/notification_types/orders/order_paid_using_dpo_notification.dart';
import 'package:perfect_order/core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import 'package:perfect_order/features/notifications/models/notification.dart' as model;
import 'package:perfect_order/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:perfect_order/core/shared_widgets/text/custom_body_text.dart';
import 'package:perfect_order/features/orders/providers/order_provider.dart';
import 'package:perfect_order/features/orders/services/order_services.dart';
import 'package:perfect_order/features/orders/enums/order_enums.dart';
import 'package:perfect_order/core/shared_models/money.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class OrderPaidUsingDpoNotificationContent extends StatefulWidget {

  final bool isLoading;
  final model.Notification notification;
  
  const OrderPaidUsingDpoNotificationContent({
    super.key,
    required this.isLoading,
    required this.notification
  });

  @override
  State<OrderPaidUsingDpoNotificationContent> createState() => _OrderPaidUsingDpoNotificationContentState();
}

class _OrderPaidUsingDpoNotificationContentState extends State<OrderPaidUsingDpoNotificationContent> {

  bool get isLoading => widget.isLoading;
  String get storeName => storeProperties.name;
  DateTime get createdAt => notification.createdAt;
  Money get amount => transactionProperties.amount;
  String get orderNumber => orderProperties.number;
  bool get paidByYou => transactionProperties.paidByYou;
  model.Notification get notification => widget.notification;
  String get paymentMethodName => paymentMethodProperties.name;
  bool get isFullPayment => transactionProperties.percentage == 100;
  String get dpoCustomerName => transactionProperties.dpoCustomerName;
  StoreProperties get storeProperties => orderMarkedAsPaidNotification.storeProperties;
  OrderProperties get orderProperties => orderMarkedAsPaidNotification.orderProperties;
  OrderProvider get orderProvider => Provider.of<OrderProvider>(context, listen: false);
  TransactionProperties get transactionProperties => orderMarkedAsPaidNotification.transactionProperties;
  PaymentMethodProperties get paymentMethodProperties => orderMarkedAsPaidNotification.paymentMethodProperties;
  OrderPaidUsingDpoNotification get orderMarkedAsPaidNotification => OrderPaidUsingDpoNotification.fromJson(notification.data);

  TextStyle style(BuildContext context, {Color? color}) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      height: 1.4,
      color: color ?? Theme.of(context).primaryColor
    );
  }

  Widget notificationBody(BuildContext context) {

    return RichText(
      /// Full payment of || Partial payment of
      text: TextSpan(
        text: '${isFullPayment ? 'Full payment' : 'Partial payment'} of ',
        style: style(context, color: Colors.grey),
        children: [
          /// P100.00
          TextSpan(
            text: amount.amountWithCurrency,
            style: style(context),
          ),
          /// paid by
          TextSpan(
            text: ' paid by ',
            style: style(context, color: Colors.grey),
          ),
          /// You || John Doe
          TextSpan(
            text: paidByYou ? 'You' : dpoCustomerName,
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
              if(!isLoading) const Icon(Icons.attach_money_rounded, color: Colors.green, size: 16,),
    
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
