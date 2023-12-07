import 'package:bonako_demo/core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import 'package:bonako_demo/core/shared_models/user_order_collection_association.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_large_text.dart';
import 'package:bonako_demo/core/shared_widgets/checkbox/custom_checkbox.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/orders/providers/order_provider.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:bonako_demo/features/orders/models/order.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class OrderCollectionBuyerConfirmation extends StatefulWidget {
  
  final Order order;
  final bool showImage;
  final double imageHeight;
  final bool autoShowCollectionCode;

  const OrderCollectionBuyerConfirmation({
    Key? key,
    required this.order,
    this.showImage = true,
    this.imageHeight = 100,
    this.autoShowCollectionCode = false,
  }) : super(key: key);

  @override
  State<OrderCollectionBuyerConfirmation> createState() => _OrderCollectionBuyerConfirmationState();
}

class _OrderCollectionBuyerConfirmationState extends State<OrderCollectionBuyerConfirmation> {

  bool isSubmitting = false;
  bool acceptToCollectOrder = false;

  Order get order => widget.order;
  bool get showImage => widget.showImage;
  double get imageHeight => widget.imageHeight;
  bool get isCompleted => order.attributes.isCompleted;
  bool get hasCollectionCode => collectionCode != null;
  bool get hasCollectionQrCode => collectionQrCode != null;
  void _startSubmittionLoader() => setState(() => isSubmitting = true);
  void _stopSubmittionLoader() => setState(() => isSubmitting = false);
  bool get hasCollectionCodeExpiresAt => collectionCodeExpiresAt != null;
  bool get autoShowCollectionCode => widget.autoShowCollectionCode;
  bool get canCollect => userOrderCollectionAssociation?.canCollect == true;
  String? get collectionCode => userOrderCollectionAssociation?.collectionCode;
  String? get collectionQrCode => userOrderCollectionAssociation?.collectionQrCode;
  OrderProvider get orderProvider => Provider.of<OrderProvider>(context, listen: false);
  DateTime? get collectionCodeExpiresAt => userOrderCollectionAssociation?.collectionCodeExpiresAt;
  bool get collectionCodeHasExpired => hasCollectionCodeExpiresAt && collectionCodeExpiresAt!.isBefore(DateTime.now());
  UserOrderCollectionAssociation? get userOrderCollectionAssociation => order.attributes.userOrderCollectionAssociation;

  @override
  void initState() {
    super.initState();
    
    /**
     *  Check if we want to auto generate the collection code and collection qr code.
     * 
     *  (1) If this order has not been completed and...
     *  (2) If this user and order collection association does not have a collection code or...
     *  (2) If this user and order collection association does not have a qr collection code or..
     *  (2) If this user and order collection association collection code has expired
     * 
     *  Then automatically request a new collection code and collection qr code.
     */
    if(autoShowCollectionCode && canCollect && !isCompleted && (!hasCollectionCode || !hasCollectionQrCode || collectionCodeHasExpired)) {

      acceptToCollectOrder = true;
      _requestGenerateCollectionCode();

    }else{
    
      /**
       *  Check if we want to auto select the collection checkbox.
       * 
       *  (2) If this user and order collection association has a collection code or...
       *  (2) If this user and order collection association has a qr collection code and...
       *  (2) If this user and order collection association collection code has not expired
       * 
       *  Then automatically request a new collection code and collection qr code.
       */
      if(canCollect && (hasCollectionCode || hasCollectionQrCode) && !collectionCodeHasExpired) {

        acceptToCollectOrder = true;

      }

    }
  }

  void _requestGenerateCollectionCode() {

    if(isSubmitting) return;

    _startSubmittionLoader();

    orderProvider.setOrder(order).orderRepository.generateCollectionCode().then((response) {

      if(response.statusCode == 200) {

        order.attributes.userOrderCollectionAssociation!.collectionCodeExpiresAt = DateTime.parse(response.data['collectionCodeExpiresAt']);
        order.attributes.userOrderCollectionAssociation!.collectionQrCode = response.data['collectionQrCode'];
        order.attributes.userOrderCollectionAssociation!.collectionCode = response.data['collectionCode'];

      }

    }).whenComplete(() {
      
      _stopSubmittionLoader();

    });

  }

  void _requestRevokeCollectionCode() {

    if(isSubmitting) return;

    _startSubmittionLoader();

    orderProvider.setOrder(order).orderRepository.revokeCollectionCode().then((response) {

      if(response.statusCode == 200) {

        order.attributes.userOrderCollectionAssociation!.collectionCodeExpiresAt = null;
        order.attributes.userOrderCollectionAssociation!.collectionQrCode = null;
        order.attributes.userOrderCollectionAssociation!.collectionCode = null;

      }

    }).whenComplete(() {
      
      _stopSubmittionLoader();

    });

  }

  void resetCollectionCode() {
    Future.delayed(Duration.zero).then((_) {
      setState(() {
        acceptToCollectOrder = false;
        order.attributes.userOrderCollectionAssociation!.collectionCode = null;
        order.attributes.userOrderCollectionAssociation!.collectionQrCode = null;
        order.attributes.userOrderCollectionAssociation!.collectionCodeExpiresAt = null;
      });
    });
  }

  List<Widget> get content {
    
    if(isSubmitting) {

      return [

        const CustomCircularProgressIndicator(margin: EdgeInsets.symmetric(vertical: 32),)

      ];

    }else if(isCompleted) {

      return [
        
        /// Spacer
        const SizedBox(height: 16,),

        /// Collection Verified By
        Row(
          children: [

            /// Title
            const CustomBodyText('Verified By: '),
          
            /// Spacer
            const SizedBox(width: 8,),

            /// Name
            CustomBodyText(order.attributes.collectionVerifiedByUserName, isLink: true,),

          ],
        ),
        
        /// Spacer
        const SizedBox(height: 16,),

        /// Collection By
        Row(
          children: [

            /// Title
            const CustomBodyText('Collected By: '),
          
            /// Spacer
            const SizedBox(width: 8,),

            /// Name
            CustomBodyText(order.attributes.collectionByUserName, isLink: true,),

          ],
        ),
        
        /// Spacer
        const SizedBox(height: 16,),
        
        /// Collection Verified At DateTime
        Row(
          children: [

            /// Watch Later Icon
            const Icon(Icons.watch_later_outlined, size: 20, color: Colors.grey,),
          
            /// Spacer
            const SizedBox(width: 8,),

            /// Collection Verified At DateTime
            CustomBodyText(timeago.format(order.collectionVerifiedAt!)),
          
            /// Spacer
            const SizedBox(width: 8,),

            /// Collection Verified At DateTime
            CustomBodyText(DateFormat.yMMMEd().format(order.collectionVerifiedAt!), lightShade: true),

          ],
        ),

      ];

    }else if(canCollect) {

      return [
      
        //  Image
        if(showImage) Container(
          height: imageHeight,
          alignment: Alignment.centerLeft,
          child: Image.asset('assets/images/orders/collection.png'),
        ),

        /// Spacer
        if(!showImage) const SizedBox(height: 16,),

        /// Request Collection Code & QR Code
        CustomCheckbox(
          crossAxisAlignment: CrossAxisAlignment.start,
          text: 'I have received this order and have verified that the contents are as advertised by the seller',
          value: acceptToCollectOrder,
          onChanged: (status) {    
            acceptToCollectOrder = status ?? false;

            if(status == true) {
              _requestGenerateCollectionCode();
            }else{
              _requestRevokeCollectionCode();
            }
          }
        ),

        /// Spacer
        const SizedBox(height: 16,),

        /// Collection Code Expiry Countdown
        if(!isSubmitting && hasCollectionCodeExpiresAt) CountdownTimer(
          endTime: collectionCodeExpiresAt!.millisecondsSinceEpoch,
          onEnd: () => resetCollectionCode(),
          widgetBuilder: (context, time) {

            final String minutes = (time == null || time.min == null) ? '00' : '${time.min! < 10 ? '0' : ''}${time.min}';
            final String seconds = (time == null || time.sec == null) ? '00' : '${time.sec! < 10 ? '0' : ''}${time.sec}';

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                const CustomBodyText('Expires in'),
                
                const SizedBox(width: 8,),

                CustomTitleLargeText('$minutes:$seconds'),

              ],
            );

          },
        ),

        if(!isSubmitting && hasCollectionCode) ...[

          /// Spacer
          const SizedBox(height: 16,),

          /// Collection Code
          Align(
            alignment: Alignment.center,
            child: Text(
              collectionCode!,
              style: TextStyle(
                fontSize: 40,
                letterSpacing: 16,
                color: Colors.grey.shade400,
              ),
            ),
          ),

        ],

        /// Spacer
        if(!isSubmitting && hasCollectionCode && hasCollectionQrCode) const SizedBox(height: 16,),

        if(!isSubmitting && hasCollectionQrCode) ...[

          /// Collection QR Code
          Center(
            child: Container(
              width: 200,
              height: 200,
              color: Colors.grey.shade100,
              child: Stack(
                children: [
                  
                  /// QR Code Loader
                  const CustomCircularProgressIndicator(),

                  /// QR Code Image
                  Image.network(collectionQrCode!),

                ],
              ),
            ),
          ),

          /// Spacer
          const SizedBox(height: 16,),

        ],

      ];

    }else{

      return [];

    }

  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      duration: const Duration(milliseconds: 500),
      child: Column(
        key: ValueKey('$isSubmitting'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: content
      ),
    );
  }
}