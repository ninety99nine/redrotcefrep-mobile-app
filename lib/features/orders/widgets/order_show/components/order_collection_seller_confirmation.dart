import 'package:bonako_demo/features/qr_code_scanner/widgets/qr_code_scanner_dialog/qr_code_scanner_dialog.dart';
import 'package:bonako_demo/core/shared_widgets/text_form_field/custom_one_time_pin_field.dart';
import 'package:bonako_demo/core/shared_widgets/button/custom_elevated_button.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/orders/providers/order_provider.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import 'package:bonako_demo/features/orders/models/order.dart';
import 'package:bonako_demo/core/utils/snackbar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';

class OrderCollectionSellerConfirmation extends StatefulWidget {
  
  final Order order;
  final bool showImage;
  final double imageHeight;
  final bool autoShowQRScanner;
  final Function(Order)? onUpdatedOrderStatus;

  const OrderCollectionSellerConfirmation({
    Key? key,
    required this.order,
    this.showImage = true,
    this.imageHeight = 100,
    this.onUpdatedOrderStatus,
    this.autoShowQRScanner = false,
  }) : super(key: key);

  @override
  State<OrderCollectionSellerConfirmation> createState() => _OrderCollectionSellerConfirmationState();
}

class _OrderCollectionSellerConfirmationState extends State<OrderCollectionSellerConfirmation> {

  bool isSubmitting = false;
  String? providedCollectionCode;
  AudioPlayer audioPlayer = AudioPlayer();
  final _formKey = GlobalKey<FormState>();

  Order get order => widget.order;
  bool get showImage => widget.showImage;
  double get imageHeight => widget.imageHeight;
  bool get isCompleted => order.attributes.isCompleted;
  ShoppableStore get store => order.relationships.store!;
  bool get autoShowQRScanner => widget.autoShowQRScanner;
  Function(Order)? get onUpdatedOrderStatus => widget.onUpdatedOrderStatus;
  bool get canManageOrders => store.attributes.userStoreAssociation!.canManageOrders;
  OrderProvider get orderProvider => Provider.of<OrderProvider>(context, listen: false);
  DialToShowCollectionCode get dialToShowCollectionCode => order.attributes.dialToShowCollectionCode;
  bool get collectionCodeProvided => providedCollectionCode == null ? false : providedCollectionCode!.length == 6;

  void _startSubmittionLoader() => setState(() => isSubmitting = true);
  void _stopSubmittionLoader() => setState(() => isSubmitting = false);

  /// This allows us to access the state of UpdateStoreForm widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<QRCodeScannerDialogState> _qrCodeScannerDialogState = GlobalKey<QRCodeScannerDialogState>();

  @override
  void initState() {
    super.initState();
    
    /**
     *  By using addPostFrameCallback, you ensure that the callback runs after the widget has
     *  been fully built and is ready for display. This removes the need for a manual delay.
     */
    WidgetsBinding.instance.addPostFrameCallback((_) {

      /// Check if we want to auto show the qr code scanner.
      if (autoShowQRScanner && canManageOrders) {

        if (_qrCodeScannerDialogState.currentState != null) {

          /// Automatically open the qr code scanner
          _qrCodeScannerDialogState.currentState!.showQRCodeScanner();

        }

      }

    });

  }

  Future<bool> _requestUpdateStatus() async {

    /// Update prevented
    if(isSubmitting) return false;

    _startSubmittionLoader();

    return orderProvider.setOrder(order).orderRepository.updateStatus(
      withDeliveryAddress: order.deliveryAddressId == null ? false : true,
      withPaymentMethod: order.paymentMethodId == null ? false : true,
      collectionCode: providedCollectionCode,
      withCountTransactions: true,
      withCustomer: true,
      status: 'Completed',
      withCart: true,
    ).then((response) {

      if(response.statusCode == 200) {

        final order = Order.fromJson(response.data);

        /// Play success sound
        if(isCompleted) audioPlayer.play(AssetSource('sounds/success.mp3'));

        SnackbarUtility.showSuccessMessage(message: 'Completed');

        if(onUpdatedOrderStatus != null) {

          /// Notify the parent that the order was updated
          onUpdatedOrderStatus!(order);

        }

        /// Updated successfully
        return true;
        
      }else {

        /// Play error sound
        if(isCompleted) audioPlayer.play(AssetSource('sounds/error.mp3'));

        /// Update failed
        return false;

      }

    }).whenComplete((){

      _stopSubmittionLoader();

    });
  }

  Widget get instruction {
    return Expanded(
      child: CustomBodyText(
        height: 1.4,
        dialToShowCollectionCode.instruction,
        margin: const EdgeInsets.only(top: 8, bottom: 16),
      ),
    );
  }

  Widget get qrCodeScannerDialog {
    return Container(
      margin: const EdgeInsets.only(top: 4.0),
      child: QRCodeScannerDialog(
        key: _qrCodeScannerDialogState,
        onScanned: (value) {
          
          /// Close the Dialog Modal
          Get.back();
    
          /**
           *  Split the value into 2 separate parts:
           * 
           *  The QR Code consists of two parts
           * 
           *  1) The url to update the status of this order to completed with the collection code embedded
           *  2) The collection code
           */
          List<String> values = value.split('|');
    
          /// For our case we just want to extract the collection code
          String extractedCollectionCode = values[1];
      
          /// Set the collection code
          setState(() => providedCollectionCode = extractedCollectionCode);
    
          /// Submit the request to complete this order
          _requestUpdateStatus();
    
        },
      ),
    );
  }

  Widget get oneTimePinField {
    return CustomOneTimePinField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      enabled: !isSubmitting,
      onChanged: (value) {
        setState(() => providedCollectionCode = value);
      }
    );
  }

  Widget get confirmCollectionButton {
    return CustomElevatedButton(
      width: 150,
      'Confirm Collection',
      alignment: Alignment.center,
      disabled: !collectionCodeProvided,
      isLoading: isSubmitting && collectionCodeProvided,
      onPressed: () {
        _requestUpdateStatus();
      },
    );
  }

  List<Widget> get content {

    if(canManageOrders && !isCompleted) {

      return [
        
        /// Confirm Collection Form
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
      
              //  Image
              if(showImage) Container(
                height: imageHeight,
                alignment: Alignment.centerLeft,
                child: Image.asset('assets/images/orders/collection.png'),
              ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// Instruction
                  instruction,

                  /// Spacer
                  const SizedBox(width: 8.0,),

                  /// QR Code Scanner
                  qrCodeScannerDialog,

                ],
              ),
        
              /// One Time Pin Field
              oneTimePinField,
                  
              /// Confirm Collection Button
              confirmCollectionButton

            ],
          ),
        )

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
        key: ValueKey('$isCompleted'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: content
      ),
    );
  }
}