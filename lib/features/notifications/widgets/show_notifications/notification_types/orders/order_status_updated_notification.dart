import 'package:bonako_demo/features/notifications/models/notification_types/orders/order_status_updated_notification.dart';
import 'package:bonako_demo/core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import 'package:bonako_demo/features/notifications/models/notification.dart' as model;
import 'package:bonako_demo/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/orders/providers/order_provider.dart';
import 'package:bonako_demo/features/orders/services/order_services.dart';
import 'package:bonako_demo/features/orders/enums/order_enums.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class OrderStatusUpdatedNotificationContent extends StatefulWidget {

  final bool isLoading;
  final model.Notification notification;
  
  const OrderStatusUpdatedNotificationContent({
    super.key,
    required this.isLoading,
    required this.notification
  });

  @override
  State<OrderStatusUpdatedNotificationContent> createState() => _OrderStatusUpdatedNotificationContentState();
}

class _OrderStatusUpdatedNotificationContentState extends State<OrderStatusUpdatedNotificationContent> {
  
  bool get isLoading => widget.isLoading;
  String get status => orderProperties.status;
  String get storeName => storeProperties.name;
  String get orderNumber => orderProperties.number;
  DateTime get createdAt => widget.notification.createdAt;
  bool get isAssociatedAsFriend => orderProperties.isAssociatedAsFriend;
  String get summary => orderStatusUpdatedNotification.orderProperties.summary;
  StoreProperties get storeProperties => orderStatusUpdatedNotification.storeProperties;
  OrderProperties get orderProperties => orderStatusUpdatedNotification.orderProperties;
  OrderProvider get orderProvider => Provider.of<OrderProvider>(context, listen: false);
  String get updatedByUserName => orderStatusUpdatedNotification.updatedByUserProperties.name;
  String get customerFirstName => orderStatusUpdatedNotification.customerProperties.firstName;
  OrderStatusUpdatedNotification get orderStatusUpdatedNotification => OrderStatusUpdatedNotification.fromJson(widget.notification.data);

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
            /// updated as
            TextSpan(
              text: ' updated as ',
              style: style(context, color: Colors.grey),
            ),
            /// Waiting || On Its Way || Ready For Pickup || Completed || Cancelled
            TextSpan(
              text: status,
              style: style(context),
            ),
            /// by
            TextSpan(
              text: ' by ',
              style: style(context, color: Colors.grey),
            ),
            /// Jane Doe
            TextSpan(
              text: updatedByUserName,
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
        /// Your order has been updated as
        text: TextSpan(
          text: 'Your order has been updated as ',
          style: style(context),
          children: [
            /// Waiting || On Its Way || Ready For Pickup || Completed || Cancelled
            TextSpan(
              text: status,
              style: style(context),
            ),
            /// by
            TextSpan(
              text: ' by ',
              style: style(context, color: Colors.grey),
            ),
            /// Jane Doe
            TextSpan(
              text: updatedByUserName,
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
