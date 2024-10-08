import 'package:perfect_order/core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import 'package:perfect_order/features/notifications/models/notification_types/orders/order_seen_notification.dart';
import 'package:perfect_order/features/notifications/models/notification.dart' as model;
import 'package:perfect_order/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:perfect_order/core/shared_widgets/text/custom_body_text.dart';
import 'package:perfect_order/features/orders/providers/order_provider.dart';
import 'package:perfect_order/features/orders/services/order_services.dart';
import 'package:perfect_order/features/orders/enums/order_enums.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class OrderSeenNotificationContent extends StatefulWidget {

  final bool isLoading;
  final model.Notification notification;
  
  const OrderSeenNotificationContent({
    super.key,
    required this.isLoading,
    required this.notification
  });

  @override
  State<OrderSeenNotificationContent> createState() => _OrderSeenNotificationContentState();
}

class _OrderSeenNotificationContentState extends State<OrderSeenNotificationContent> {

  bool get isLoading => widget.isLoading;
  String get storeName => storeProperties.name;
  String get orderNumber => orderProperties.number;
  DateTime get createdAt => widget.notification.createdAt;
  String get summary => orderSeenNotification.orderProperties.summary;
  bool get isAssociatedAsFriend => orderProperties.isAssociatedAsFriend;
  String get seenByUserName => orderSeenNotification.seenByUserProperties.name;
  StoreProperties get storeProperties => orderSeenNotification.storeProperties;
  OrderProperties get orderProperties => orderSeenNotification.orderProperties;
  String get customerFirstName => orderSeenNotification.customerProperties.firstName;
  OrderProvider get orderProvider => Provider.of<OrderProvider>(context, listen: false);
  OrderSeenNotification get orderSeenNotification => OrderSeenNotification.fromJson(widget.notification.data);

  TextStyle style(BuildContext context, {Color? color}) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      height: 1.4,
      color: color ?? Theme.of(context).primaryColor
    );
  }

  Widget notificationBody(BuildContext context) {

    if(isAssociatedAsFriend) {

      return RichText(
        /// Order placed by 
        text: TextSpan(
          text: 'Order placed by ',
          style: style(context),
          children: [
            /// John
            TextSpan(
              text: customerFirstName,
              style: style(context),
            ),
            /// has been seen by
            TextSpan(
              text: ' has been seen by ',
              style: style(context, color: Colors.grey),
            ),
            /// Jane Doe
            TextSpan(
              text: seenByUserName,
              style: style(context),
            ),
            /// - VIP ticket for P500.00
            TextSpan(
              text: ' - $summary',
              style: style(context, color: Colors.grey),
            ),
          ]
        ),
      );

    }else{

      return RichText(
        /// Your order has been seen by
        text: TextSpan(
          text: 'Your order has been seen by ',
          style: style(context),
          children: [
            /// John Doe 
            TextSpan(
              text: seenByUserName,
              style: style(context),
            ),
            /// - VIP ticket for P500.00
            TextSpan(
              text: ' - $summary',
              style: style(context, color: Colors.grey),
            ),
          ]
        ),
      );

    }

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
              if(!isLoading) Icon(FontAwesomeIcons.circleDot, color: Colors.blue.shade700, size: 12,)
    
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