import '../../../../core/shared_widgets/text/custom_title_large_text.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../friend_groups/models/friend_group.dart';
import '../../../stores/providers/store_provider.dart';
import '../../../stores/models/shoppable_store.dart';
import '../../../../core/shared_models/user.dart';
import 'users_in_vertical_list_view_infinite_scroll.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'users_page/users_page.dart';

class UsersContent extends StatefulWidget {
  
  final String orderFor;
  final List<User> friends;
  final ShoppableStore store;
  final bool showingFullPage;
  final List<FriendGroup> friendGroups;

  const UsersContent({
    super.key,
    required this.store,
    required this.friends,
    required this.orderFor,
    required this.friendGroups,
    this.showingFullPage = false
  });

  @override
  State<UsersContent> createState() => _UsersContentState();
}

class _UsersContentState extends State<UsersContent> {

  String get orderFor => widget.orderFor;
  ShoppableStore get store => widget.store;
  List<User> get friends => widget.friends;
  double get topPadding => showingFullPage ? 32 : 0;
  bool get showingFullPage => widget.showingFullPage;
  List<FriendGroup> get friendGroups => widget.friendGroups;
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);

  /// Content to show based on the specified view
  Widget get content {

    /// Show users view
    return UsersInVerticalListViewInfiniteScroll(
      store: store,
      friends: friends,
      orderFor: orderFor,
      friendGroups: friendGroups,
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
                      CustomTitleLargeText('Ordering For', padding: EdgeInsets.only(bottom: 8),),
                      
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
                Navigator.of(context).pop();

                /// Set the store
                storeProvider.setStore(store);
                
                /// Navigate to the page
                Navigator.of(context).pushNamed(UsersPage.routeName);
              
              }
            ),
          ),
  
          /// Cancel Icon
          Positioned(
            right: 10,
            top: 8 + topPadding,
            child: IconButton(
              icon: Icon(Icons.cancel, size: 28, color: Theme.of(context).primaryColor,),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          
        ],
      ),
    );
  }
}