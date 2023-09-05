import 'package:bonako_demo/core/shared_widgets/checkbox/custom_checkbox.dart';
import 'package:bonako_demo/features/home/providers/home_provider.dart';
import 'package:bonako_demo/features/stores/providers/store_provider.dart';
import 'package:bonako_demo/features/stores/services/store_services.dart';
import 'package:bonako_demo/features/stores/widgets/subscribe_to_store/subscribe_to_store_modal_bottom_sheet/subscribe_to_store_modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

import '../../../../models/shoppable_store.dart';
import 'package:flutter/material.dart';
import 'profile/profile.dart';
import 'store_logo.dart';

class StorePrimarySectionContent extends StatefulWidget {

  final double? logoRadius;
  final ShoppableStore store;
  final bool showProfileRightSide;
  final Alignment subscribeButtonAlignment;

  const StorePrimarySectionContent({
    Key? key,
    this.logoRadius,
    required this.store, 
    this.showProfileRightSide = true,
    this.subscribeButtonAlignment = Alignment.centerRight
  }) : super(key: key);

  @override
  State<StorePrimarySectionContent> createState() => _StorePrimarySectionContentState();
}

class _StorePrimarySectionContentState extends State<StorePrimarySectionContent> {

  ShoppableStore get store => widget.store;
  double? get logoRadius => widget.logoRadius;
  bool get hasCoverPhoto => store.hasCoverPhoto;
  bool get showProfileRightSide => widget.showProfileRightSide;
  bool get isShowingStorePage => storeProvider.isShowingStorePage;
  bool get hasSelectedMyStores => homeProvider.hasSelectedMyStores;
  Alignment get subscribeButtonAlignment => widget.subscribeButtonAlignment;
  bool get canAccessAsTeamMember => StoreServices.canAccessAsTeamMember(store);
  bool get teamMemberWantsToViewAsCustomer => store.teamMemberWantsToViewAsCustomer;
  bool get isTeamMemberWhoHasJoined => StoreServices.isTeamMemberWhoHasJoined(store);
  HomeProvider get homeProvider => Provider.of<HomeProvider>(context, listen: false);
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: true);

  @override
  Widget build(BuildContext context) {
    
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          
            //  Store Logo
            StoreLogo(store: store, radius: logoRadius),
          
            //  Spacer
            const SizedBox(width: 8,),
          
            //  Store Profile (Name, Description, Adverts, Rating, e.t.c)
            Expanded(
              child: StoreProfile(
                store: store, 
                showProfileRightSide: showProfileRightSide,
                subscribeButtonAlignment: subscribeButtonAlignment
              )
            )

          ]
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
        
            /// View As Customer Checkbox
            if((isShowingStorePage || hasSelectedMyStores) && isTeamMemberWhoHasJoined) ...[
        
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: 16.0, bottom: 16.0, left: isShowingStorePage ? 16.0 : 0),
                  child: CustomCheckbox(
                    value: teamMemberWantsToViewAsCustomer,
                    text: 'View as customer',
                    onChanged: (value) {
                      if(value != null) store.updateTeamMemberWantsToViewAsCustomer(value);
                    }
                  ),
                ),
              ),
        
            ],
        
            /// Subscribe Modal Bottom Sheet (Access Denied For Team Member)
            if(isTeamMemberWhoHasJoined && !canAccessAsTeamMember) Expanded(
              child: AnimatedSize(
                clipBehavior: Clip.none,
                duration: const Duration(milliseconds: 500),
                child: AnimatedSwitcher(
                  switchInCurve: Curves.easeIn,
                  switchOutCurve: Curves.easeOut,
                  duration: const Duration(milliseconds: 500),
                  child: Column(
                    key: ValueKey(teamMemberWantsToViewAsCustomer),
                    children: [
                      
                      /// Access Denied For Team Member
                      if(hasCoverPhoto) ...[
                        SubscribeToStoreModalBottomSheet(
                          store: widget.store,
                          subscribeButtonAlignment: subscribeButtonAlignment,
                        ),
                      ],
                
                    ]
                  ),
                )
              ),
            )
        
          ],
        )

      ],
    );
  }
}