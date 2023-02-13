import '../../../../../core/shared_widgets/text_form_fields/custom_one_time_pin_field.dart';
import '../../../../../core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import '../../../../core/shared_widgets/message_alerts/custom_message_alert.dart';
import '../../../../../core/shared_widgets/buttons/custom_elevated_button.dart';
import '../../../../../core/shared_widgets/text/custom_title_medium_text.dart';
import '../../../../../core/shared_widgets/buttons/custom_text_button.dart';
import '../../../../../core/shared_widgets/chips/custom_choice_chip.dart';
import '../../../../../core/shared_widgets/text/custom_body_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../../core/shared_models/name_description.dart';
import '../../../cart/widgets/cart/cart_details.dart';
import '../../../stores/services/store_services.dart';
import '../../../stores/models/shoppable_store.dart';
import '../../../../../core/utils/snackbar.dart';
import '../../providers/order_provider.dart';
import 'package:collection/collection.dart';
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
    this.triggerCancel = false,
    this.onRequestedOrderRelationships,
  }) : super(key: key);

  @override
  State<OrderContent> createState() => OrderContentState();
}

class OrderContentState extends State<OrderContent> {
  
  late Order order;
  Map serverErrors = {};
  bool isLoading = false;
  bool isSubmitting = false;
  String? collectionConfirmationCode;
  final _formKey = GlobalKey<FormState>();
  NameAndDescription? selectedFollowUpStatus;

  Color? get color => widget.color;
  ShoppableStore get store => widget.store;
  String get statusName => order.status.name;
  bool get hasBeenSeen => totalViewsByTeam > 0;
  bool get triggerCancel => widget.triggerCancel;
  int get totalViewsByTeam => order.totalViewsByTeam;
  String get customerName => order.attributes.customerName;
  bool get hasFollowUpStatuses => followUpStatuses.isNotEmpty;
  Function(Order)? get onUpdatedOrder => widget.onUpdatedOrder;
  bool get isCompleted => statusName.toLowerCase() == 'completed';
  bool get canManageOrders => StoreServices.hasPermissionsToManageOrders(store);
  List<NameAndDescription> get followUpStatuses => order.attributes.followUpStatuses;
  Function(Order)? get onRequestedOrderRelationships => widget.onRequestedOrderRelationships;
  bool get canShowEnterCollectionCode => followUpStatuses.where((followUpStatus) {
    return followUpStatus.name.toLowerCase() == 'completed';
  }).isNotEmpty;
  /// Check if this order can be cancelled
  bool get canCancel => followUpStatuses.where((followUpStatus) {
    return followUpStatus.name.toLowerCase() == 'cancelled';
  }).isNotEmpty;
  DialToShowConfirmationCode get dialToShowConfirmationCode => order.attributes.dialToShowConfirmationCode;
  bool get collectionCodeProvided => collectionConfirmationCode == null ? false : collectionConfirmationCode!.length == 6;
  String? get collectionConfirmationCodeError => serverErrors.containsKey('collectionConfirmationCode') ? serverErrors['collectionConfirmationCode'] : null;
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

  void _startLoader() => setState(() => isLoading = true);
  void _stopLoader() => setState(() => isLoading = false);
  void _startSubmittionLoader() => setState(() => isSubmitting = true);
  void _stopSubmittionLoader() => setState(() => isSubmitting = false);

  OrderProvider get orderProvider => Provider.of<OrderProvider>(context, listen: false);

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

        if(onRequestedOrderRelationships != null) {

          onRequestedOrderRelationships!(order);

        }

      }

    }).whenComplete(() {
      _stopLoader();
    });

  }

  Future<bool> _requestUpdateStatus() async {

    /// Update prevented
    if(isSubmitting) return false;

    /// Confirm as long as the confirmation code is not provided
    final bool? confirmation = collectionConfirmationCode == null ? await confirmAction() : true;

    /// If we are not loading and we can accept all
    if(confirmation == true) {

      _startSubmittionLoader();

      return orderProvider.setOrder(order).orderRepository.updateStatus(
        collectionConfirmationCode: collectionConfirmationCode,
        status: selectedFollowUpStatus!.name,
        withTransactions: false,
        withCustomer: false,
        context: context,
        withCart: true,
      ).then((response) {

        final responseBody = jsonDecode(response.body);

        if(response.statusCode == 200) {

          final order = Order.fromJson(responseBody);

          SnackbarUtility.showSuccessMessage(message: selectedFollowUpStatus!.name, context: context);

          if(onUpdatedOrder != null) {

            /// Notify the parent that the order was updated
            onUpdatedOrder!(order);

          }

          /// Updated successfully
          return true;
          
        }else if(response.statusCode == 422) {

          handleServerValidation(responseBody['errors']);
          
        }

        /// Update failed
        return false;

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
        SnackbarUtility.showInfoMessage(
          message: 'This order is already cancelled',
          context: context
        );

      });

    }

  }

  Future<bool> _updateStatus(String followUpStatusName, { String? collectionConfirmationCode }) {

    //// Get the selected follow up status
    selectedFollowUpStatus = followUpStatuses.firstWhereOrNull((followUpStatus) {

      return followUpStatus.name.toLowerCase() == followUpStatusName.toLowerCase();
    
    });

    //// If the follow up status exists
    if(selectedFollowUpStatus != null) {
      
      /// Set the collection confirmation code if provided
      this.collectionConfirmationCode = collectionConfirmationCode;

      /// Reset server errors
      _resetServerErrors();

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

  void handleServerValidation(Map errors) {

    /**
     *  errors = {
     *    mobileNumbers0: [The mobile number must start with one of the following: 267.]
     * }
     */
    setState(() {

      errors.forEach((key, value) {
        serverErrors[key] = value[0];
      });

      Future.delayed(const Duration(milliseconds: 10)).then((value) {
        _formKey.currentState!.validate();
      });
    });

  }

  void _resetServerErrors() {
    setState(() => serverErrors = {});
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

  Widget get collectionCode {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          CustomBodyText(
            height: 1.4,
            dialToShowConfirmationCode.instruction,
            margin: const EdgeInsets.only(top: 8, bottom: 16),
          ),
    
          /// One Time Pin Field
          CustomOneTimePinField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            errorText: collectionConfirmationCodeError,
            enabled: !isSubmitting,
            //onCompleted: update,
            //onSubmitted: update,
            onChanged: (value) {
              
              /// Set the collection confirmation code
              setState(() => collectionConfirmationCode = value);

              /// Reset errors if any
              if(collectionConfirmationCodeError != null) _resetServerErrors();

            },
            //onSaved: update,
          ),
              
          /// Confirm Collection Button
          confirmCollectionButton

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

        _updateStatus('Completed', collectionConfirmationCode: collectionConfirmationCode);

      },
    );
  }

  void showViewers () {

    if(hasBeenSeen == false) {
      SnackbarUtility.showInfoMessage(message: '${store.name} team hasn\'t seen this order yet', duration: 4, context: context);
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
    
          /// Title
          CustomTitleMediumText(
            'Order #${order.attributes.number}',
            margin: const EdgeInsets.only(top: 8, bottom: 8),  
          ),
    
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
          if(canManageOrders) AnimatedSize(
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
                children: [
    
                  if(isSubmitting && !collectionCodeProvided) const CustomCircularProgressIndicator(
                    margin: EdgeInsets.only(top: 8),
                  ),
                  
                  AnimatedContainer(
                    height: (isSubmitting && !collectionCodeProvided)  ? 0 : null,
                    duration: const Duration(milliseconds: 500),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
    
                        /// Instructions
                        Container(
                          margin: const EdgeInsets.only(top: 8, bottom: 8),
                          child: CustomMessageAlert(instruction, type: isCompleted ? AlertMessageType.success : AlertMessageType.info, icon: isCompleted ? Icons.check_circle : null,)
                        ),
    
                        /// Collection Code
                        if(canShowEnterCollectionCode) collectionCode,
    
                        if(canShowEnterCollectionCode && hasFollowUpStatuses) ...[
                          
                          /// Spacer
                          const SizedBox(height: 16,),
    
                          /// Instructions
                          const CustomMessageAlert('Change the order status'),
                          
                          /// Spacer
                          const SizedBox(height: 8,),
    
                        ],
    
                        /// Follow Up Status Choice Chips
                        if(hasFollowUpStatuses) followUpStatusChoiceChips
    
                      ],
                    ),
                  ),
    
                ],
              )
            ),
          ),
    
        ],
      ),
    );
  }
}