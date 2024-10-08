import 'package:perfect_order/core/shared_widgets/Loader/custom_circular_progress_indicator.dart';
import 'package:perfect_order/features/cart/widgets/cart/cart_details.dart';
import 'package:perfect_order/features/orders/providers/order_provider.dart';
import 'package:perfect_order/features/orders/models/order.dart';
import 'package:perfect_order/core/shared_models/cart.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class OrderCartDetails extends StatefulWidget {
  
  final Order order;
  final bool showTopDivider;
  final Function(Cart)? onRequestedCart;

  const OrderCartDetails({
    Key? key,
    required this.order,
    this.onRequestedCart,
    this.showTopDivider = true
  }) : super(key: key);

  @override
  State<OrderCartDetails> createState() => _OrderCartDetailsState();
}

class _OrderCartDetailsState extends State<OrderCartDetails> {

  late Order order;
  bool isLoading = false;
  bool get showTopDivider => widget.showTopDivider;
  void _startLoader() => setState(() => isLoading = true);
  void _stopLoader() => setState(() => isLoading = false);
  Function(Cart)? get onRequestedCart => widget.onRequestedCart;
  OrderProvider get orderProvider => Provider.of<OrderProvider>(context, listen: false);

  @override
  void initState() {
    super.initState();

    order = widget.order;

    /// If the order cart does not exist, then request this order cart
    if(order.relationships.cart == null) _requestOrderCart();
  }

  void _requestOrderCart() async {

    if(isLoading) return;

    _startLoader();

    orderProvider.setOrder(order).orderRepository.showOrderCart().then((response) {

      if(response.statusCode == 200) {
        order.relationships.cart = Cart.fromJson(response.data);
        if(onRequestedCart != null) onRequestedCart!(order.relationships.cart!);
      }

    }).whenComplete(() {
      _stopLoader();
    });

  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
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
            cart: widget.order.relationships.cart!,
            showTopDivider: showTopDivider,
            boldTotal: true
          ),
      )
    );
  }
}