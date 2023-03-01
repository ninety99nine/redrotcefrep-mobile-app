import 'profile_right_side/profile_right_side.dart';
import 'profile_left_side/profile_left_side.dart';
import '../../../../../models/shoppable_store.dart';
import 'package:flutter/material.dart';

class StoreProfile extends StatefulWidget {

  final ShoppableStore store;
  final Function? onRefreshStores;
  final bool showProfileRightSide;

  const StoreProfile({
    Key? key,
    required this.store, 
    this.onRefreshStores,
    this.showProfileRightSide = true
  }) : super(key: key);

  @override
  State<StoreProfile> createState() => _StoreProfileState();
}

class _StoreProfileState extends State<StoreProfile> {

  ShoppableStore get store => widget.store;
  Function? get onRefreshStores => widget.onRefreshStores;
  bool get showProfileRightSide => widget.showProfileRightSide;

  @override
  Widget build(BuildContext context) {
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        //  Store Profile Left Side (Name, Description, e.t.c)
        Expanded(child: StoreProfileLeftSide(
          store: store,
        )),
          
        //  Spacer
        if(showProfileRightSide) const SizedBox(width: 8,),

        //  Store Profile Right Side (Adverts, Rating, e.t.c)
        if(showProfileRightSide) StoreProfileRightSide(
          store: store,
          onRefreshStores: onRefreshStores
        )

      ]
    );
  }
}