import 'package:bonako_demo/core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/orders/providers/order_provider.dart';
import 'package:bonako_demo/features/occasions/models/occasion.dart';
import 'package:bonako_demo/features/orders/models/order.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class OrderOccasion extends StatefulWidget {
  
  final Order order;
  final Function(Occasion)? onRequestedOccasion;

  const OrderOccasion({
    Key? key,
    required this.order,
    this.onRequestedOccasion
  }) : super(key: key);

  @override
  State<OrderOccasion> createState() => _OrderOccasionState();
}

class _OrderOccasionState extends State<OrderOccasion> {
  
  late Order order;
  bool isLoading = false;
  void _startLoader() => setState(() => isLoading = true);
  void _stopLoader() => setState(() => isLoading = false);
  Function(Occasion)? get onRequestedOccasion => widget.onRequestedOccasion;
  OrderProvider get orderProvider => Provider.of<OrderProvider>(context, listen: false);

  @override
  void initState() {
    super.initState();

    order = widget.order;
    
    /// If the order occasion does not exist, then request this order occasion
    if(order.occasionId != null && order.relationships.occasion == null) _requestOrderOccasion();
  }

  void _requestOrderOccasion() async {

    _startLoader();

    orderProvider.setOrder(widget.order).orderRepository.showOrderOccasion().then((response) {

      final responseBody = jsonDecode(response.body);

      if(response.statusCode == 200) {

        /// Set the occasion on this order
        order.relationships.occasion = Occasion.fromJson(responseBody);

        if(onRequestedOccasion != null) onRequestedOccasion!(order.relationships.occasion!);

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
            if(order.relationships.occasion != null) CustomBodyText(order.relationships.occasion!.name, overflow: TextOverflow.ellipsis, height: 1, lightShade: false),
          ],
        )
    );
  }
}