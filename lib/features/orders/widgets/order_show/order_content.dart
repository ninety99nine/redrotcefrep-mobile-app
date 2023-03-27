import 'package:bonako_demo/core/shared_models/user_and_order_association.dart';
import 'package:bonako_demo/core/shared_widgets/checkboxes/custom_checkbox.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_large_text.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:bonako_demo/features/qr_code_scanner/widgets/qr_code_scanner.dart';
import 'package:bonako_demo/features/qr_code_scanner/widgets/qr_code_scanner_dialog/qr_code_scanner_dialog.dart';
import 'package:bonako_demo/features/stores/widgets/store_cards/store_card/primary_section_content/store_logo.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:intl/intl.dart';

import '../../../../../core/shared_widgets/text_form_fields/custom_one_time_pin_field.dart';
import '../../../../../core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import '../../../../core/shared_widgets/message_alerts/custom_message_alert.dart';
import '../../../../../core/shared_widgets/buttons/custom_elevated_button.dart';
import '../../../../../core/shared_widgets/text/custom_title_medium_text.dart';
import '../../../../../core/shared_widgets/buttons/custom_text_button.dart';
import '../../../../../core/shared_widgets/chips/custom_choice_chip.dart';
import '../../../../../core/shared_widgets/text/custom_body_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/shared_models/name_and_description.dart';
import '../../../cart/widgets/cart/cart_details.dart';
import '../../../stores/services/store_services.dart';
import '../../../stores/models/shoppable_store.dart';
import '../../../../../core/utils/snackbar.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../providers/order_provider.dart';
import 'package:collection/collection.dart';

import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/utils/dialog.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../models/order.dart';
import 'order_viewers.dart';
import 'order_status.dart';
import 'dart:convert';

class OrderContent extends StatefulWidget {
  
  final Order order;
  final Color? color;
  final bool showLogo;
  final bool triggerCancel;
  final ShoppableStore store;
  final Function(Order)? onUpdatedOrder;
  final Function(Order)? onRequestedOrderRelationships;

  const OrderContent({
    Key? key,
    this.color,
    required this.store,
    required this.order,
    this.onUpdatedOrder,
    this.showLogo = false,
    this.triggerCancel = false,
    this.onRequestedOrderRelationships,
  }) : super(key: key);

  @override
  State<OrderContent> createState() => OrderContentState();
}

class OrderContentState extends State<OrderContent> {
  
  late Order order;
  bool isLoading = false;
  bool isSubmitting = false;
  String? providedCollectionCode;
  bool acceptToCollectOrder = false;
  final _formKey = GlobalKey<FormState>();
  AudioPlayer audioPlayer = AudioPlayer();
  NameAndDescription? selectedFollowUpStatus;

  Color? get color => widget.color;
  bool get showLogo => widget.showLogo;
  ShoppableStore get store => widget.store;
  String get statusName => order.status.name;
  bool get hasBeenSeen => totalViewsByTeam > 0;
  bool get triggerCancel => widget.triggerCancel;
  int get totalViewsByTeam => order.totalViewsByTeam;
  String get customerName => order.attributes.customerName;
  bool get hasFollowUpStatuses => followUpStatuses.isNotEmpty;
  Function(Order)? get onUpdatedOrder => widget.onUpdatedOrder;
  bool get isCompleted => statusName.toLowerCase() == 'completed';
  bool get canCollect => userAndOrderAssociation?.canCollect == true;
  String? get collectionCode => userAndOrderAssociation?.collectionCode;
  bool get hasCollectionCodeExpiresAt => collectionCodeExpiresAt != null;
  String? get collectionQrCode => userAndOrderAssociation?.collectionQrCode;
  bool get canManageOrders => StoreServices.hasPermissionsToManageOrders(store);
  bool get hasCollectionCode => userAndOrderAssociation?.collectionCode != null;
  bool get hasCollectionQrCode => userAndOrderAssociation?.collectionQrCode != null;
  List<NameAndDescription> get followUpStatuses => order.attributes.followUpStatuses;
  OrderProvider get orderProvider => Provider.of<OrderProvider>(context, listen: false);
  DateTime? get collectionCodeExpiresAt => userAndOrderAssociation?.collectionCodeExpiresAt;
  Function(Order)? get onRequestedOrderRelationships => widget.onRequestedOrderRelationships;
  UserAndOrderAssociation? get userAndOrderAssociation => order.attributes.userAndOrderAssociation;
  bool get collectionCodeHasExpired => collectionCodeExpiresAt == null ? true : collectionCodeExpiresAt!.isBefore(DateTime.now());

  bool get canShowEnterCollectionCode => followUpStatuses.where((followUpStatus) {
    return followUpStatus.name.toLowerCase() == 'completed';
  }).isNotEmpty && canCollect == false;

  /// Check if this order can be cancelled
  bool get canCancel => followUpStatuses.where((followUpStatus) {
    return followUpStatus.name.toLowerCase() == 'cancelled';
  }).isNotEmpty;
  DialToShowCollectionCode get dialToShowCollectionCode => order.attributes.dialToShowCollectionCode;
  bool get collectionCodeProvided => providedCollectionCode == null ? false : providedCollectionCode!.length == 6;
  String get instruction {
    if(isCompleted) {
      return 'Collected by the customer';
    }else if(canShowEnterCollectionCode) {
      return 'Confirm that $customerName collected this order';
    }else {
      return 'Notify $customerName on the next steps for this order';
    }
  }
  String get totalViewsMessage {
    if(hasBeenSeen) {
      return '$totalViewsByTeam ${totalViewsByTeam == 1 ? 'view' : 'views'}';
    }else {
      return 'No views';
    }
  }

  @override
  void initState() {
    super.initState();

    /// Set the order provided (without relationships such as cart, customer, transactions, e.t.c)
    order = widget.order;

    /// Request the same order (with relationships such as cart, customer, transactions, e.t.c)
    if(order.relationships.cart == null) _requestShowOrder();

    /// If we should immediately trigger the cancellation of this order.
    /// Future.delayed() is required so that we allow the use of
    /// setState when firing the requestCancelOrder method
    Future.delayed(Duration.zero).then((value) {
      if(triggerCancel) requestCancelOrder();
    });
  }

  @override
  void dispose() {
    super.dispose();
    audioPlayer.dispose();
  }

  void _startLoader() => setState(() => isLoading = true);
  void _stopLoader() => setState(() => isLoading = false);
  void _startSubmittionLoader() => setState(() => isSubmitting = true);
  void _stopSubmittionLoader() => setState(() => isSubmitting = false);

  void _requestShowOrder() async {

    _startLoader();

    orderProvider.setOrder(order).orderRepository.showOrder(
      withTransactions: false,
      withCustomer: false,
      context: context,
      withCart: true,
    ).then((response) {

      final responseBody = jsonDecode(response.body);

      if(response.statusCode == 200) {

        order = Order.fromJson(responseBody);

        /// If the user and order association has a collection code, then this means that the user
        /// must have accepted the terms and conditions to collect the order.
        if(hasCollectionCode && !collectionCodeHasExpired) {

          /// Indicate that the customer accepts to collect this order
          setState(() => acceptToCollectOrder = true);

        }

        if(onRequestedOrderRelationships != null) {

          onRequestedOrderRelationships!(order);

        }

      }

    }).whenComplete(() {
      _stopLoader();
    });

  }

  void _requestGenerateCollectionCode() {

    _startSubmittionLoader();

    orderProvider.setOrder(order).orderRepository.generateCollectionCode().then((response) {

      if(response.statusCode == 200) {

        final responseBody = jsonDecode(response.body);

        order.attributes.userAndOrderAssociation!.collectionCodeExpiresAt = DateTime.parse(responseBody['collectionCodeExpiresAt']);
        order.attributes.userAndOrderAssociation!.collectionQrCode = responseBody['collectionQrCode'];
        order.attributes.userAndOrderAssociation!.collectionCode = responseBody['collectionCode'];

      }

    }).whenComplete(() {
      
      _stopSubmittionLoader();

    });

  }

  void _requestRevokeCollectionCode() {

    _startSubmittionLoader();

    orderProvider.setOrder(order).orderRepository.revokeCollectionCode().then((response) {

      if(response.statusCode == 200) {

        order.attributes.userAndOrderAssociation!.collectionCodeExpiresAt = null;
        order.attributes.userAndOrderAssociation!.collectionQrCode = null;
        order.attributes.userAndOrderAssociation!.collectionCode = null;

      }

    }).whenComplete(() {
      
      _stopSubmittionLoader();

    });

  }

  Future<bool> _requestUpdateStatus() async {

    /// Update prevented
    if(isSubmitting) return false;

    /// Confirm as long as the confirmation code is not provided
    final bool? confirmation = providedCollectionCode == null ? await confirmAction() : true;

    /// If we are not loading and we can accept all
    if(confirmation == true) {

      _startSubmittionLoader();

      return orderProvider.setOrder(order).orderRepository.updateStatus(
        collectionCode: providedCollectionCode,
        status: selectedFollowUpStatus!.name,
        withTransactions: false,
        withCustomer: false,
        context: context,
        withCart: true,
      ).then((response) {

        if(response.statusCode == 200) {

          final responseBody = jsonDecode(response.body);

          final order = Order.fromJson(responseBody);

          /// Play success sound
          if(isCompleted) audioPlayer.play(AssetSource('sounds/success.mp3'));

          SnackbarUtility.showSuccessMessage(message: selectedFollowUpStatus!.name);

          if(onUpdatedOrder != null) {

            /// Notify the parent that the order was updated
            onUpdatedOrder!(order);

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

    }else{

      /// Update prevented
      return false;

    }
  }

  /// This method is used by parent widgets to trigger
  /// the order cancellation process while on a dialog.
  /// We use the Navigator.of(context).pop() to close
  /// the Dialog and return true or false of whether
  /// the order update was started and whether it
  /// was successful. This true and false values
  /// are important since they can be used on
  /// ListTile Widgets wrapped with the
  /// Dismissible widget. The value can
  /// then be used to determine if we
  /// should dismiss the item or not.
  void requestCancelOrder() async {

    /// If we can cancel this order
    if(canCancel) {

      /// Attempt to cancel the order
      _updateStatus('Cancelled');

    }else{

      /// After closing the Dialog, show a Snackbar message
      Future.delayed(Duration.zero).then((value) {

        /// We cannot cancel a cancelled order
        SnackbarUtility.showInfoMessage(message: 'This order is already cancelled');

      });

    }

  }

  Future<bool> _updateStatus(String followUpStatusName, { String? providedCollectionCode }) {

    //// Get the selected follow up status
    selectedFollowUpStatus = followUpStatuses.firstWhereOrNull((followUpStatus) {

      return followUpStatus.name.toLowerCase() == followUpStatusName.toLowerCase();
    
    });

    //// If the follow up status exists
    if(selectedFollowUpStatus != null) {
      
      /// Set the collection code if provided
      this.providedCollectionCode = providedCollectionCode;

      /// Attempt update
      return _requestUpdateStatus();

    }else{

      /// Update prevented
      return Future.delayed(Duration.zero).then((_) => false);

    }
  }

  Future<bool?> confirmAction() {
    return DialogUtility.showConfirmDialog(
      title: selectedFollowUpStatus!.name,
      content: selectedFollowUpStatus!.description,  
      context: context
    );
  }

  Widget get followUpStatusChoiceChips {

    return ClipRRect(
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(24),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Wrap(
          spacing: 8,
          children: [
            ...followUpStatuses.where((followUpStatus) {

              final String name = followUpStatus.name.toLowerCase();

              /// Exclude the completed follow up status
              return ['completed'].contains(name) == false;

            }).map((followUpStatus) {

              final String name = followUpStatus.name;
      
              return CustomChoiceChip(
                label: name,
                onSelected: (_) => _updateStatus(name),
              );
      
            }).toList()
          ],
        ),
      ),
    );

  }

  Widget get enterCollectionCode {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              Expanded(
                child: CustomBodyText(
                  height: 1.4,
                  dialToShowCollectionCode.instruction,
                  margin: const EdgeInsets.only(top: 8, bottom: 16),
                ),
              ),

              QRCodeScannerDialog(
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
                  _updateStatus('Completed', providedCollectionCode: providedCollectionCode);

                },
              ),

            ],
          ),
    
          /// One Time Pin Field
          CustomOneTimePinField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            enabled: !isSubmitting,
            //onCompleted: update,
            //onSubmitted: update,
            onChanged: (value) {
              
              /// Set the collection code
              setState(() => providedCollectionCode = value);

            },
            //onSaved: update,
          ),
              
          /// Confirm Collection Button
          confirmCollectionButton

        ],
      ),
    );
  }

  Widget get showCollectionCode {
    return AnimatedSwitcher(
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      duration: const Duration(milliseconds: 500),
      child: Column(
        key: ValueKey(isSubmitting),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// Spacer
          const SizedBox(height: 16,),

          /// Request Collection Code & QR Code
          CustomCheckbox(
            //  text: 'I accept that I have received this order and have verified that the contents are as advertised by the seller',
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

          /// Collection Code
          if(!isSubmitting && hasCollectionCode) ...[

            /// Spacer
            const SizedBox(height: 16,),

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

          /// Collection QR Code
          if(!isSubmitting && hasCollectionQrCode) ...[

            Align(
              alignment: Alignment.center,
              child: Image.network(
                collectionQrCode!,
              ),
            ),

            /// Spacer
            const SizedBox(height: 16,),

          ],

        ],
      ),
    );
  }

  Widget get confirmCollectionButton{

    /// Confirm Collection Button
    return CustomElevatedButton(
      width: 150,
      'Confirm Collection',
      alignment: Alignment.center,
      disabled: !collectionCodeProvided,
      isLoading: isSubmitting && collectionCodeProvided,
      onPressed: () {

        _updateStatus('Completed', providedCollectionCode: providedCollectionCode);

      },
    );
  }

  void resetCollectionCode() {
    Future.delayed(Duration.zero).then((_) {
      setState(() {
        acceptToCollectOrder = false;
        order.attributes.userAndOrderAssociation!.collectionCode = null;
        order.attributes.userAndOrderAssociation!.collectionQrCode = null;
        order.attributes.userAndOrderAssociation!.collectionCodeExpiresAt = null;
      });
    });
  }

  void showViewers () {

    if(hasBeenSeen == false) {
      SnackbarUtility.showInfoMessage(message: '${store.name} team hasn\'t seen this order yet', duration: 4);
      return;
    }

    /// Show Dialog Of Viewers
    DialogUtility.showInfiniteScrollContentDialog(
      content: OrderViewers(
        store: store,
        order: order,
      ), 
      context: context
    );

  }

  Widget orderSummaryWrapper({ required Widget child }) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 500),
      child: AnimatedSwitcher(
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        duration: const Duration(milliseconds: 500),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          key: ValueKey(order.id),
          color: color ?? Colors.grey.shade50,
          child: child,
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return orderSummaryWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
    
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [

              if(showLogo) ...[
                
                /// Store Logo
                StoreLogo(store: store),

                /// Spacer
                const SizedBox(width: 8,),

              ],

              /// Title
              CustomTitleMediumText(
                'Order #${order.attributes.number}',
                margin: const EdgeInsets.only(top: 8, bottom: 8),  
              ),

            ],
          ),

          if(showLogo) Divider(),
    
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
    
              /// Status
              OrderStatus(
                status: statusName,
              ),
    
              /// Views
              CustomTextButton(
                totalViewsMessage,
                prefixIconSize: 12,
                onPressed: showViewers,
                prefixIcon: FontAwesomeIcons.circleDot,
                color: hasBeenSeen ? null : Colors.grey,
              ),
              
            ],
          ),
    
          /// Status description
          CustomBodyText(
            order.status.description,
            margin: const EdgeInsets.only(top: 8, bottom: 8),  
          ),
    
          /// Cart Calculations
          AnimatedSize(
            duration: const Duration(milliseconds: 500),
            child: AnimatedSwitcher(
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              duration: const Duration(milliseconds: 500),
              child: isLoading 
                ? const CustomCircularProgressIndicator(
                  size: 16,
                  margin: EdgeInsets.symmetric(vertical: 16),
                )
                : CartDetails(
                  cart: order.relationships.cart!,
                  boldTotal: true
                ),
            )
          ),
    
          /// Manage Order Options 
          SizedBox(
            width: double.infinity,
            child: AnimatedSize(
              duration: const Duration(milliseconds: 500),
              child: AnimatedSwitcher(
                switchInCurve: Curves.easeIn,
                switchOutCurve: Curves.easeOut,
                duration: const Duration(milliseconds: 500),
                /**
                 *  Notice that I used the Column in such a way that I can show the loader and 
                 *  conditionally animate the height of the AnimatedContainer. This is because
                 *  if I completely remove the AnimatedContainer content while loading, the
                 *  size of the DialogUtility.showContentDialog() will re-adjust itself to
                 *  fit the content if the width has become smaller. This is the case if
                 *  this OrderContent is displayed on a Dialog and the result causes
                 *  the dialog width to keep changing based on the width of the
                 *  of the longest widget. This is the case because we use the
                 *  "mainAxisSize: MainAxisSize.min" on the Dialog. To keep
                 *  the size from changing, we can keep the content of the
                 *  AnimatedContainer and simply use "0" as the container
                 *  height to temporarily hide the content while loading.
                 */
                child: Column(
                  key: ValueKey('$isLoading'),
                  children: isLoading ? [] : [
              
                    if(isSubmitting) const CustomCircularProgressIndicator(
                      margin: EdgeInsets.only(top: 8),
                    ),
                    
                    AnimatedContainer(
                      height: isSubmitting ? 0 : null,
                      duration: const Duration(milliseconds: 500),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
          
                          /// Show Order Collection Code & QR Code (Customer side)
                          if(canCollect && !isCompleted) showCollectionCode,
              
                          /// Instructions
                          if(isCompleted || (canManageOrders && canShowEnterCollectionCode)) Container(
                            margin: const EdgeInsets.only(top: 8, bottom: 8),
                            child: CustomMessageAlert(instruction, type: isCompleted ? AlertMessageType.success : AlertMessageType.info, icon: isCompleted ? Icons.check_circle : null,)
                          ),
                            
                          /// Spacer
                          const SizedBox(height: 8,),

                          if(isCompleted) ...[

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

                          ],
              
                          /// Enter Collection Code (Merchant side)
                          if(canManageOrders && !isCompleted) enterCollectionCode,
              
                          /// Change Order Status (Merchant side)
                          if(canManageOrders && hasFollowUpStatuses && !isCompleted) ...[
                            
                            /// Spacer
                            const SizedBox(height: 8,),
              
                            /// Instructions
                            const CustomMessageAlert('Change the order status'),
                            
                            /// Spacer
                            const SizedBox(height: 8,),
              
                            /// Follow Up Status Choice Chips
                            followUpStatusChoiceChips
              
                          ],
              
                        ],
                      ),
                    ),
              
                  ],
                )
              ),
            ),
          ),
    
        ],
      ),
    );
  }
}