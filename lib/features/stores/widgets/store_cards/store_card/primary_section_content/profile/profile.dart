import 'package:perfect_order/core/shared_widgets/checkbox/custom_checkbox.dart';
import 'package:perfect_order/features/home/providers/home_provider.dart';
import 'package:perfect_order/features/stores/providers/store_provider.dart';
import 'package:perfect_order/features/stores/widgets/subscribe_to_store/subscribe_to_store_modal_bottom_sheet/subscribe_to_store_modal_bottom_sheet.dart';
import 'package:perfect_order/features/stores/services/store_services.dart';
import 'package:provider/provider.dart';
import 'profile_right_side/profile_right_side.dart';
import '../../../../../models/shoppable_store.dart';
import 'profile_left_side/profile_left_side.dart';
import 'package:flutter/material.dart';

class StoreProfile extends StatefulWidget {

  final ShoppableStore store;
  final bool showProfileRightSide;
  final Alignment subscribeButtonAlignment;

  const StoreProfile({
    Key? key,
    required this.store, 
    this.showProfileRightSide = true,
    this.subscribeButtonAlignment = Alignment.centerRight
  }) : super(key: key);

  @override
  State<StoreProfile> createState() => _StoreProfileState();
}

class _StoreProfileState extends State<StoreProfile> {

  ShoppableStore get store => widget.store;
  bool get showProfileRightSide => widget.showProfileRightSide;

  @override
  Widget build(BuildContext context) {
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        //  Store Profile Left Side (Name, Description, e.t.c)
        Expanded(
          child: StoreProfileLeftSide(store: store)
        ),
          
        //  Spacer
        if(showProfileRightSide) const SizedBox(width: 8,),

        //  Store Profile Right Side (Adverts, Rating, e.t.c)
        if(showProfileRightSide) StoreProfileRightSide(store: store)

      ]
    );
  }
}