import '../../../models/shoppable_store.dart';
import 'package:flutter/material.dart';
import 'profile/profile.dart';
import 'logo.dart';

class StorePrimarySectionContent extends StatefulWidget {

  final double? logoRadius;
  final ShoppableStore store;
  final bool showProfileRightSide;

  const StorePrimarySectionContent({
    Key? key,
    this.logoRadius,
    required this.store, 
    this.showProfileRightSide = true,
  }) : super(key: key);

  @override
  State<StorePrimarySectionContent> createState() => _StorePrimarySectionContentState();
}

class _StorePrimarySectionContentState extends State<StorePrimarySectionContent> {

  ShoppableStore get store => widget.store;
  double? get logoRadius => widget.logoRadius;
  bool get showProfileRightSide => widget.showProfileRightSide;

  @override
  Widget build(BuildContext context) {
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      
        //  Store Logo
        StoreLogo(store: store, radius: logoRadius),
      
        //  Spacer
        const SizedBox(width: 8,),
      
        //  Store Profile (Name, Description, Adverts, Rating, e.t.c)
        Expanded(child: StoreProfile(store: store, showProfileRightSide: showProfileRightSide))

      ]
    );
  }
}