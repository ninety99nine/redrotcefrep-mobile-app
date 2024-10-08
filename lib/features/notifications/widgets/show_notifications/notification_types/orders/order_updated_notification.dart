import 'package:perfect_order/features/notifications/models/notification_types/orders/order_updated_notification.dart';
import 'package:perfect_order/core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import 'package:perfect_order/features/notifications/models/notification.dart' as model;
import 'package:perfect_order/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:perfect_order/core/shared_widgets/text/custom_body_text.dart';
import 'package:perfect_order/features/orders/providers/order_provider.dart';
import 'package:perfect_order/features/orders/services/order_services.dart';
import 'package:perfect_order/features/orders/enums/order_enums.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class OrderUpdatedNotificationContent extends StatefulWidget {

  final bool isLoading;
  final model.Notification notification;
  
  const OrderUpdatedNotificationContent({
    super.key,
    required this.isLoading,
    required this.notification
  });

  @override
  State<OrderUpdatedNotificationContent> createState() => _OrderUpdatedNotificationContentState();
}

class _OrderUpdatedNotificationContentState extends State<OrderUpdatedNotificationContent> {

  bool get isLoading => widget.isLoading;
  String get storeName => storeProperties.name;
  String get orderNumber => orderProperties.number;
  bool get hasOccasion => ocassionProperties != null;
  String get customerName => customerProperties.name;
  int get otherTotalFriends => orderForTotalFriends - 1;
  DateTime get createdAt => widget.notification.createdAt;
  String get updatedByUserName => updatedByUserProperties.name;
  int get orderForTotalFriends => orderProperties.orderForTotalFriends;
  bool get isAssociatedAsFriend => orderProperties.isAssociatedAsFriend;
  String get summary => orderUpdatedNotification.orderProperties.summary;
  bool get isAssociatedAsCustomer => orderProperties.isAssociatedAsCustomer;
  OrderProperties get orderProperties => orderUpdatedNotification.orderProperties;
  StoreProperties get storeProperties => orderUpdatedNotification.storeProperties;
  bool get updatedByCustomer => customerProperties.id == updatedByUserProperties.id;
  OrderProvider get orderProvider => Provider.of<OrderProvider>(context, listen: false);
  CustomerProperties get customerProperties => orderUpdatedNotification.customerProperties;
  OcassionProperties? get ocassionProperties => orderUpdatedNotification.ocassionProperties;
  UpdatedByUserProperties get updatedByUserProperties => orderUpdatedNotification.updatedByUserProperties;
  OrderUpdatedNotification get orderUpdatedNotification => OrderUpdatedNotification.fromJson(widget.notification.data);

  TextStyle style(BuildContext context, {Color? color}) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      height: 1.4,
      color: color ?? Theme.of(context).primaryColor
    );
  }

  Widget notificationBody(BuildContext context) {

    if(isAssociatedAsFriend) {

      String taggedPeople;

      if(otherTotalFriends > 0) {

        taggedPeople = 'you and $otherTotalFriends ${otherTotalFriends == 1 ? 'other friend' : 'other friends'}';

      }else{

        taggedPeople = 'you';
      
      }

      return RichText(
        /// John Doe
        text: TextSpan(
          text: updatedByUserName,
          style: style(context),
          children: [
            /// updated an order that
            TextSpan(
              text: ' updated an order that',
              style: style(context, color: Colors.grey),
            ),

            /// you || you and 1 other friend || you and 2 other friends
            TextSpan(
              text: ' $taggedPeople ',
              style: style(context),
            ),

            /// are tagged on
            TextSpan(
              text: 'are tagged on',
              style: style(context, color: Colors.grey),
            ),

            if(!updatedByCustomer) ...[
              
              /// placed by
              TextSpan(
                text: ' placed by ',
                style: style(context, color: Colors.grey),
              ),

              /// Jane Doe
              TextSpan(
                text: customerName,
                style: style(context),
              ),

            ],

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

    }else if (isAssociatedAsCustomer) {

      return RichText(
        /// Your order has been updated
        text: TextSpan(
          text: 'Your order has been updated',
          style: style(context),
          children: [

            /// by
            TextSpan(
              text: ' by ',
              style: style(context, color: Colors.grey),
            ),

            /// You || John Doe
            TextSpan(
              text: updatedByCustomer ? 'You' : updatedByUserName,
              style: style(context),
            ),

            /// - VIP ticket for P500.00
            TextSpan(
              text: ' - $summary',
              style: style(context, color: Colors.grey),
            ),
            
            /// ❤️ Happy Valentines
            if(hasOccasion) TextSpan(
              text: ocassionProperties!.name,
              style: style(context, color: Colors.grey),
            )

          ]
        ),
      );

    }else {

      return RichText(
        /// Order has been updated
        text: TextSpan(
          text: 'Order has been updated',
          style: style(context),
          children: [

            /// by || by customer
            TextSpan(
              text: ' by ${updatedByCustomer ? 'customer: ' : ''}',
              style: style(context, color: Colors.grey),
            ),

            /// John Doe
            TextSpan(
              text: updatedByUserName,
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
              if(!isLoading) const Icon(Icons.shopping_bag_outlined, size: 16,)
    
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