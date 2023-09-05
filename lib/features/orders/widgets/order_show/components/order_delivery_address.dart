import 'package:bonako_demo/core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import 'package:bonako_demo/features/addresses/widgets/delivery_address_card.dart';
import 'package:bonako_demo/features/addresses/models/delivery_address.dart';
import 'package:bonako_demo/features/orders/providers/order_provider.dart';
import 'package:bonako_demo/features/orders/models/order.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class OrderDeliveryAddress extends StatefulWidget {
  
  final Order order;
  final Function(DeliveryAddress)? onRequestedDeliveryAddress;

  const OrderDeliveryAddress({
    Key? key,
    required this.order,
    this.onRequestedDeliveryAddress
  }) : super(key: key);

  @override
  State<OrderDeliveryAddress> createState() => _OrderDeliveryAddressState();
}

class _OrderDeliveryAddressState extends State<OrderDeliveryAddress> {
  
  late Order order;
  bool isLoading = false;
  void _startLoader() => setState(() => isLoading = true);
  void _stopLoader() => setState(() => isLoading = false);
  OrderProvider get orderProvider => Provider.of<OrderProvider>(context, listen: false);
  Function(DeliveryAddress)? get onRequestedDeliveryAddress => widget.onRequestedDeliveryAddress;

  @override
  void initState() {
    super.initState();

    order = widget.order;
    
    /// If the order delivery address does not exist, then request this order delivery address
    if(order.deliveryAddressId != null && order.relationships.deliveryAddress == null) _requestOrderDeliveryAddress();
  }

  void _requestOrderDeliveryAddress() async {

    _startLoader();

    orderProvider.setOrder(widget.order).orderRepository.showOrderDeliveryAddress().then((response) {

      if(response.statusCode == 200) {

        /// Set the delivery address on this order
        order.relationships.deliveryAddress = DeliveryAddress.fromJson(response.data);

        if(onRequestedDeliveryAddress != null) onRequestedDeliveryAddress!(order.relationships.deliveryAddress!);

      }

    }).whenComplete(() {
      _stopLoader();
    });

  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      duration: const Duration(milliseconds: 500),
      child: isLoading
        ? const CustomCircularProgressIndicator()
        : Column(
          children: [
            if(order.relationships.deliveryAddress != null) DeliveryAddressCard(deliveryAddress: order.relationships.deliveryAddress!),
          ],
        )
    );
  }
}