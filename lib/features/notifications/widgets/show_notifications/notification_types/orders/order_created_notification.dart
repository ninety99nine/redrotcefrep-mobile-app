import 'package:perfect_order/features/notifications/models/notification_types/orders/order_created_notification.dart';
import 'package:perfect_order/core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import 'package:perfect_order/features/notifications/models/notification.dart' as model;
import 'package:perfect_order/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:perfect_order/core/shared_widgets/text/custom_body_text.dart';
import 'package:perfect_order/features/orders/providers/order_provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class OrderCreatedNotificationContent extends StatefulWidget {

  final bool isLoading;
  final model.Notification notification;
  
  const OrderCreatedNotificationContent({
    super.key,
    required this.isLoading,
    required this.notification
  });

  @override
  State<OrderCreatedNotificationContent> createState() => _OrderCreatedNotificationContentState();
}

class _OrderCreatedNotificationContentState extends State<OrderCreatedNotificationContent> {

  bool get isLoading => widget.isLoading;
  String get storeName => storeProperties.name;
  String get orderNumber => orderProperties.number;
  bool get hasOccasion => ocassionProperties != null;
  int get otherTotalFriends => orderForTotalFriends - 1;
  DateTime get createdAt => widget.notification.createdAt;
  int get orderForTotalFriends => orderProperties.orderForTotalFriends;
  bool get isAssociatedAsFriend => orderProperties.isAssociatedAsFriend;
  String get summary => orderCreatedNotification.orderProperties.summary;
  String get customerName => orderCreatedNotification.customerProperties.name;
  OrderProperties get orderProperties => orderCreatedNotification.orderProperties;
  StoreProperties get storeProperties => orderCreatedNotification.storeProperties;
  OrderProvider get orderProvider => Provider.of<OrderProvider>(context, listen: false);
  OcassionProperties? get ocassionProperties => orderCreatedNotification.ocassionProperties;
  OrderCreatedNotification get orderCreatedNotification => OrderCreatedNotification.fromJson(widget.notification.data);

  TextStyle style(BuildContext context, {Color? color}) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      height: 1.4,
      color: color ?? Theme.of(context).primaryColor
    );
  }

  Widget notificationBody(BuildContext context) {

    if(isAssociatedAsFriend) {

      return RichText(
        /// John Doe
        text: TextSpan(
          text: customerName,
          style: style(context),
          children: [
            
            /// placed an order and tagged
            TextSpan(
              text: ' placed an order and tagged ',
              style: style(context),
            ),

            /// You
            TextSpan(
              text: 'You',
              style: style(context, color: Colors.grey),
            ),
            
            /// and 1 other friend || and 2 other friends
            if(otherTotalFriends > 0) TextSpan(
              text: ' and $otherTotalFriends ${otherTotalFriends == 1 ? 'other friend' : 'other friends'}',
              style: style(context),
            ),

            /// - VIP ticket for P500.00
            TextSpan(
              text: ' - $summary',
              style: style(context, color: Colors.grey),
            ),

            /// ❤️ Happy Valentines
            if(hasOccasion) TextSpan(
              text: ' ${ocassionProperties!.name}',
              style: style(context, color: Colors.grey),
            )

          ]
        ),
      );

    }else{

      return RichText(
        /// John Doe
        text: TextSpan(
          text: customerName,
          style: style(context),
          children: [

            /// placed an order - VIP ticket for P500.00
            TextSpan(
              text: ' placed an order - $summary',
              style: style(context, color: Colors.grey),
            ),

            /// ❤️ Happy Valentines
            if(hasOccasion) TextSpan(
              text: ' ${ocassionProperties!.name}',
              style: style(context, color: Colors.grey),
            )

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
              if(!isLoading) const Icon(Icons.shopping_bag_outlined, size: 16,),
    
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