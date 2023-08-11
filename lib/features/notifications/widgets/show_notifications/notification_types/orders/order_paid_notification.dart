import 'package:bonako_demo/features/notifications/models/notification_types/orders/order_paid_notification.dart';
import 'package:bonako_demo/features/notifications/models/notification.dart' as model;
import 'package:bonako_demo/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';

class OrderPaidNotificationContent extends StatefulWidget {

  final model.Notification notification;
  
  const OrderPaidNotificationContent({
    super.key,
    required this.notification
  });

  @override
  State<OrderPaidNotificationContent> createState() => _OrderPaidNotificationContentState();
}

class _OrderPaidNotificationContentState extends State<OrderPaidNotificationContent> {

  String get orderNumber => orderProperties.number;
  bool get orderedByYou => orderProperties.orderedByYou;
  DateTime get createdAt => widget.notification.createdAt;
  String get payerName => transactionProperties.payerName;
  String get customerName => orderProperties.customerProperties.name;
  bool get orderedAndPaidByYou => transactionProperties.orderedAndPaidByYou;
  StoreProperties get storeProperties => orderPaidNotification.storeProperties;
  OrderProperties get orderProperties => orderPaidNotification.orderProperties;
  bool get orderedAndPaidBySamePerson => transactionProperties.orderedAndPaidBySamePerson;
  TransactionProperties get transactionProperties => orderPaidNotification.transactionProperties;
  OrderPaidNotification get orderPaidNotification => OrderPaidNotification.fromJson(widget.notification.data);

  TextStyle style(BuildContext context, {Color? color}) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      height: 1.4,
      color: color ?? Theme.of(context).primaryColor
    );
  }

  Widget notificationFooter(BuildContext context) {

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
  
        /// Activity Summary, Reads as:
        /// 1) Ordered and paid by You
        /// 1) Ordered and paid by John Doe
        /// 2) Ordered by You paid by Jane Doe
        /// 2) Ordered by John Doe paid by Jane Doe
        Expanded(
          child: RichText(
            text: TextSpan(
              /// Activity
              text: 'Ordered ${orderedAndPaidBySamePerson ? ' and paid by ' : ' by '}',
              style: style(context),
              children: [
                if(!orderedAndPaidBySamePerson) TextSpan(
                  /// User Name
                  text: orderedByYou ? 'You' : customerName,
                  style: style(context),
                ),
                if(!orderedAndPaidBySamePerson) TextSpan(
                  /// Activity
                  text: ' paid by ',
                  style: style(context, color: Colors.grey),
                ),
                TextSpan(
                  /// User Name
                  text: orderedAndPaidByYou ? 'You' : payerName,
                  style: style(context),
                ),
              ]
            ),
          ),
        ),

        /// Spacer
        const SizedBox(width: 8,),

        /// Order Number
        CustomBodyText('#$orderNumber', lightShade: true),

      ],
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
              CustomTitleSmallText(storeProperties.name),
              
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
    
              /// Order Summary
              Expanded(
                child: CustomBodyText(orderProperties.summary)
              ),
          
              /// Spacer
              const SizedBox(width: 8),
          
              /// Icon
              const Icon(Icons.attach_money_rounded, color: Colors.green, size: 16,),
    
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
