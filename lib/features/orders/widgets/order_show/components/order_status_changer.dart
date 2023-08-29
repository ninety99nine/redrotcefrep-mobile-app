import 'package:bonako_demo/core/shared_widgets/message_alert/custom_message_alert.dart';
import 'package:bonako_demo/core/shared_widgets/chips/custom_choice_chip.dart';
import 'package:bonako_demo/features/orders/providers/order_provider.dart';
import 'package:bonako_demo/core/shared_models/name_and_description.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import 'package:bonako_demo/features/orders/models/order.dart';
import 'package:bonako_demo/core/utils/snackbar.dart';
import 'package:bonako_demo/core/utils/dialog.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';

class OrderStatusChanger extends StatefulWidget {
  
  final Order order;
  final Function(Order)? onUpdatedOrderStatus;

  const OrderStatusChanger({
    Key? key,
    required this.order,
    this.onUpdatedOrderStatus,
  }) : super(key: key);

  @override
  State<OrderStatusChanger> createState() => _OrderStatusChangerState();
}

class _OrderStatusChangerState extends State<OrderStatusChanger> {

  bool isSubmitting = false;
  AudioPlayer audioPlayer = AudioPlayer();

  Order get order => widget.order;
  NameAndDescription? selectedFollowUpStatus;
  bool get isCompleted => order.attributes.isCompleted;
  bool get hasFollowUpStatuses => followUpStatuses.isNotEmpty;
  ShoppableStore get store => widget.order.relationships.store!;
  Function(Order)? get onUpdatedOrderStatus => widget.onUpdatedOrderStatus;
  bool get canManageOrders => store.attributes.userStoreAssociation!.canManageOrders;
  OrderProvider get orderProvider => Provider.of<OrderProvider>(context, listen: false);
  List<NameAndDescription> get followUpStatuses => widget.order.attributes.followUpStatuses;

  void _startSubmittionLoader() => setState(() => isSubmitting = true);
  void _stopSubmittionLoader() => setState(() => isSubmitting = false);

  Future<bool> _requestUpdateStatus(String followUpStatusName) async {

    /// Update prevented
    if(isSubmitting) return false;

    //// Get the selected follow up status
    selectedFollowUpStatus = followUpStatuses.firstWhereOrNull((followUpStatus) {
      return followUpStatus.name.toLowerCase() == followUpStatusName.toLowerCase();
    });

    /// Confirm action to change status
    final bool? confirmation = await confirmAction();

    /// If we are not loading and we can accept all
    if(confirmation == true) {

      _startSubmittionLoader();

      return orderProvider.setOrder(widget.order).orderRepository.updateStatus(
        status: selectedFollowUpStatus!.name,
        withCart: true,
      ).then((response) {

        if(response.statusCode == 200) {

          final responseBody = jsonDecode(response.body);

          final order = Order.fromJson(responseBody);

          /// Play success sound
          if(isCompleted) audioPlayer.play(AssetSource('sounds/success.mp3'));

          SnackbarUtility.showSuccessMessage(message: selectedFollowUpStatus!.name);

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

    }else{

      /// Update prevented
      return false;

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
                onSelected: (_) => _requestUpdateStatus(name),
              );
      
            }).toList()
          ],
        ),
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: (canManageOrders && hasFollowUpStatuses && !isCompleted) ? [
                            
        /// Spacer
        const SizedBox(height: 8,),

        /// Instructions
        const CustomMessageAlert('Change the order status'),
        
        /// Spacer
        const SizedBox(height: 8,),

        /// Follow Up Status Choice Chips
        followUpStatusChoiceChips

      ] : [],
    );
  }
}