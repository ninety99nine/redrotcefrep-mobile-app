import 'package:bonako_demo/core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import 'package:bonako_demo/core/shared_widgets/icon_button/phone_icon_button.dart';
import 'package:bonako_demo/features/orders/providers/order_provider.dart';
import 'package:bonako_demo/features/orders/models/order.dart';
import 'package:bonako_demo/core/shared_models/user.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class OrderCallCustomer extends StatefulWidget {
  
  final Order order;
  final Function(User)? onRequestedCustomer;

  const OrderCallCustomer({
    Key? key,
    required this.order,
    this.onRequestedCustomer
  }) : super(key: key);

  @override
  State<OrderCallCustomer> createState() => _OrderCallCustomerState();
}

class _OrderCallCustomerState extends State<OrderCallCustomer> {
  
  late Order order;
  bool isLoading = false;
  void _startLoader() => setState(() => isLoading = true);
  void _stopLoader() => setState(() => isLoading = false);
  Function(User)? get onRequestedCustomer => widget.onRequestedCustomer;
  OrderProvider get orderProvider => Provider.of<OrderProvider>(context, listen: false);

  @override
  void initState() {
    super.initState();

    order = widget.order;
    
    /// If the order customer does not exist, then request this order customer
    if(order.customerUserId != null && order.relationships.customer == null) _requestOrderCustomer();
  }

  void _requestOrderCustomer() async {

    if(isLoading) return;

    _startLoader();

    orderProvider.setOrder(widget.order).orderRepository.showOrderCustomer().then((response) {

      if(response.statusCode == 200) {

        /// Set the customer on this order
        order.relationships.customer = User.fromJson(response.data);

        if(onRequestedCustomer != null) onRequestedCustomer!(order.relationships.customer!);

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
            if(order.relationships.customer != null) PhoneIconButton(number: order.relationships.customer!.mobileNumber!.withExtension)
          ],
        )
    );
  }
}