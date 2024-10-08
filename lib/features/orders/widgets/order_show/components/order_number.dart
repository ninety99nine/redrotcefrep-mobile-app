import 'package:perfect_order/core/shared_widgets/text/custom_title_large_text.dart';
import 'package:perfect_order/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:perfect_order/features/orders/models/order.dart';
import 'package:flutter/material.dart';

enum OrderNumberSize {
  small,
  big
}

class OrderNumber extends StatelessWidget {
  
  final Order order;
  final bool showPrefix;
  final OrderNumberSize orderNumberSize;

  const OrderNumber({
    Key? key,
    required this.order,
    this.showPrefix = true,
    this.orderNumberSize = OrderNumberSize.big
  }) : super(key: key);

  Widget get smallOrderNumber {
    return CustomTitleSmallText(
      '${showPrefix ? 'Order ' : ''}#${order.attributes.number}',
      margin: const EdgeInsets.only(top: 8, bottom: 8),  
    );
  }

  Widget get bigOrderNumber {
    return CustomTitleLargeText(
      '${showPrefix ? 'Order ' : ''}#${order.attributes.number}',
      margin: const EdgeInsets.only(top: 8, bottom: 8),  
    );
  }

  @override
  Widget build(BuildContext context) {
    return orderNumberSize == OrderNumberSize.small ? smallOrderNumber : bigOrderNumber;
  }
}