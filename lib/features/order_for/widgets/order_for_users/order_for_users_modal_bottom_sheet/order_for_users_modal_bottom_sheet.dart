import '../../../../../core/shared_widgets/bottom_modal_sheet/custom_bottom_modal_sheet.dart';
import '../../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../../stores/models/shoppable_store.dart';
import 'package:flutter/material.dart';
import '../order_for_users_content.dart';

class OrderForUsersModalBottomSheet extends StatefulWidget {
  
  final ShoppableStore store;

  const OrderForUsersModalBottomSheet({
    super.key,
    required this.store
  });

  @override
  State<OrderForUsersModalBottomSheet> createState() => _OrderForUsersModalBottomSheetState();
}

class _OrderForUsersModalBottomSheetState extends State<OrderForUsersModalBottomSheet> {

  ShoppableStore get store => widget.store;

  @override
  Widget build(BuildContext context) {
    return CustomBottomModalSheet(
      /// Trigger to open the bottom modal sheet
      trigger: const CustomBodyText('view', isLink: true,),
      /// Content of the bottom modal sheet
      content: OrderForUsersContent(
        store: store,
      ),
    );
  }
}