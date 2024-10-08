import 'package:perfect_order/core/shared_widgets/icon_button/phone_icon_button.dart';
import 'package:perfect_order/features/stores/models/shoppable_store.dart';
import 'package:flutter/material.dart';

class StoreDialer extends StatelessWidget {
  
  final ShoppableStore store;

  const StoreDialer({
    Key? key,
    required this.store
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PhoneIconButton(number: store.mobileNumber.withExtension);
  }
}