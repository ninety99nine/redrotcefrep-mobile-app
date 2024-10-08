import 'package:perfect_order/features/orders/widgets/order_show/components/order_viewers.dart';
import 'package:perfect_order/core/shared_widgets/button/custom_text_button.dart';
import 'package:perfect_order/features/stores/models/shoppable_store.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:perfect_order/features/orders/models/order.dart';
import 'package:perfect_order/core/utils/snackbar.dart';
import 'package:perfect_order/core/utils/dialog.dart';
import 'package:flutter/material.dart';

class OrderViews extends StatelessWidget {
  
  final Order order;

  const OrderViews({
    Key? key,
    required this.order
  }) : super(key: key);

  bool get hasBeenSeen => totalViewsByTeam > 0;
  int get totalViewsByTeam => order.totalViewsByTeam;
  ShoppableStore get store => order.relationships.store!;

  String get totalViewsMessage {
    if(hasBeenSeen) {
      return '$totalViewsByTeam ${totalViewsByTeam == 1 ? 'view' : 'views'}';
    }else {
      return 'No views';
    }
  }

  void showViewers (BuildContext context) {

    if(hasBeenSeen == false) {
      SnackbarUtility.showInfoMessage(message: '${store.name} team hasn\'t seen this order yet', duration: 4);
      return;
    }

    /// Show Dialog Of Viewers
    DialogUtility.showInfiniteScrollContentDialog(
      content: OrderViewers(order: order), 
      context: context
    );

  }

  @override
  Widget build(BuildContext context) {
    return CustomTextButton(
      totalViewsMessage,
      prefixIconSize: 12,
      onPressed: () => showViewers(context),
      prefixIcon: FontAwesomeIcons.circleDot,
      color: hasBeenSeen ? null : Colors.grey,
    );
  }
}