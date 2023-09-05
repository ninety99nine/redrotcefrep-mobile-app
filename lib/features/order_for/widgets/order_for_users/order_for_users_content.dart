import 'package:get/get.dart';

import '../../../../core/shared_widgets/text/custom_title_medium_text.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import 'order_for_users_in_vertical_list_view_infinite_scroll.dart';
import '../../../friend_groups/models/friend_group.dart';
import '../../../stores/providers/store_provider.dart';
import '../../../stores/models/shoppable_store.dart';
import '../../../../core/shared_models/user.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'order_for_users_page/order_for_users_page.dart';

class OrderForUsersContent extends StatefulWidget {
  
  final ShoppableStore store;
  final bool showingFullPage;

  const OrderForUsersContent({
    super.key,
    required this.store,
    this.showingFullPage = false
  });

  @override
  State<OrderForUsersContent> createState() => _OrderForUsersContentState();
}

class _OrderForUsersContentState extends State<OrderForUsersContent> {

  ShoppableStore get store => widget.store;
  double get topPadding => showingFullPage ? 32 : 0;
  bool get showingFullPage => widget.showingFullPage;
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);

  /// Content to show based on the specified view
  Widget get content {

    /// Show users view
    return OrderForUsersInVerticalListViewInfiniteScroll(
      store: store,
    );
    
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Stack(
        children: [
          AnimatedSwitcher(
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            duration: const Duration(milliseconds: 500),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                
                /// Wrap Padding around the following:
                /// Title, Subtitle, Filters
                Padding(
                  padding: EdgeInsets.only(top: 20 + topPadding, left: 32, bottom: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                
                      /// Title
                      CustomTitleMediumText('Ordering For', padding: EdgeInsets.only(bottom: 8),),
                      
                      /// Subtitle
                      CustomBodyText('See who your are ordering for'),
                      
                    ],
                  ),
                ),
          
                /// Content
                Expanded(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    alignment: Alignment.topCenter,
                    width: double.infinity,
                    color: Colors.white,
                    child: content,
                  ),
                )
            
              ],
            ),
          ),
  
          /// Expand Icon
          if(!showingFullPage) Positioned(
            top: 8,
            right: 50,
            child: IconButton(
              icon: const Icon(Icons.open_in_full_rounded, size: 24, color: Colors.grey),
              onPressed: () {
                
                /// Close the Modal Bottom Sheet
                Get.back();

                /// Set the store
                storeProvider.setStore(store);
                
                /// Navigate to the page
                Get.toNamed(OrderForUsersPage.routeName);
              
              }
            ),
          ),
  
          /// Cancel Icon
          Positioned(
            right: 10,
            top: 8 + topPadding,
            child: IconButton(
              icon: Icon(Icons.cancel, size: 28, color: Theme.of(context).primaryColor,),
              onPressed: () => Get.back()
            ),
          ),
          
        ],
      ),
    );
  }
}