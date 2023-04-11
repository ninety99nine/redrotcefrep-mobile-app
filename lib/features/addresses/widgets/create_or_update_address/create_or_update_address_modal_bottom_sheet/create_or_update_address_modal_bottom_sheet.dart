import 'package:bonako_demo/core/shared_models/user.dart';
import 'package:bonako_demo/core/shared_widgets/bottom_modal_sheet/custom_bottom_modal_sheet.dart';
import '../create_or_update_address_content.dart';
import '../../../models/address.dart';
import 'package:flutter/material.dart';

class CreateOrUpdateAddressModalBottomSheet extends StatefulWidget {

  final User user;
  final Address? address;
  final Function()? onDeletedAddress;
  final Widget Function(Function)? trigger;
  final Function(Address)? onCreatedAddress;
  final Function(Address)? onUpdatedAddress;

  const CreateOrUpdateAddressModalBottomSheet({
    super.key,
    this.trigger,
    this.address,
    required this.user,
    this.onCreatedAddress,
    this.onUpdatedAddress,
    this.onDeletedAddress,
  });

  @override
  State<CreateOrUpdateAddressModalBottomSheet> createState() => CreateOrUpdateAddressModalBottomSheetState();
}

class CreateOrUpdateAddressModalBottomSheetState extends State<CreateOrUpdateAddressModalBottomSheet> {

  User get user => widget.user;
  Address? get address => widget.address;
  Widget Function(Function)? get trigger => widget.trigger;
  Function()? get onDeletedAddress => widget.onDeletedAddress;
  Function(Address)? get onUpdatedAddress => widget.onUpdatedAddress;
  Function(Address)? get onCreatedAddress => widget.onCreatedAddress;

  /// This allows us to access the state of CustomBottomModalSheet widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomBottomModalSheetState> _customBottomModalSheetState = GlobalKey<CustomBottomModalSheetState>();

  Widget get _trigger {

    Widget defaultTrigger = Icon(Icons.mode_edit_outlined, size: 20, color: Colors.grey.shade400);

    return trigger == null ? defaultTrigger : trigger!(openBottomModalSheet);

  }

  /// Open the bottom modal sheet to show the new order placed
  void openBottomModalSheet() {
    if(_customBottomModalSheetState.currentState != null) {
      _customBottomModalSheetState.currentState!.showBottomSheet(context);
    } 
  }

  @override
  Widget build(BuildContext context) {
    return CustomBottomModalSheet(
      key: _customBottomModalSheetState,
      /// Trigger to open the bottom modal sheet
      trigger: _trigger,
      /// Content of the bottom modal sheet
      content: CreateOrUpdateAddressContent(
        user: user,
        address: address,
        onDeletedAddress: onDeletedAddress,
        onUpdatedAddress: onUpdatedAddress,
        onCreatedAddress: onCreatedAddress
      ),
    );
  }
}