import 'package:bonako_demo/features/friend_groups/widgets/friend_group_stores/friend_group_stores_page/friend_group_stores_page.dart';
import 'package:bonako_demo/features/friend_groups/widgets/friend_group_stores/friend_group_stores_in_vertical_infinite_scroll.dart';
import 'package:bonako_demo/features/friend_groups/widgets/friend_group_stores/friend_group_store_filters.dart';
import '../../../../core/shared_widgets/button/custom_elevated_button.dart';
import '../../../../core/shared_widgets/text/custom_title_medium_text.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../models/friend_group.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FriendGroupStoresContent extends StatefulWidget {
  
  final bool showingFullPage;
  final FriendGroup friendGroup;
  final String? friendGroupStoreFilter;
  final Function(ShoppableStore)? onAddedStore;
  final Function(List<ShoppableStore>)? onRemovedStores;

  const FriendGroupStoresContent({
    super.key,
    this.onAddedStore,
    this.onRemovedStores,
    required this.friendGroup,
    this.friendGroupStoreFilter,
    this.showingFullPage = false
  });

  @override
  State<FriendGroupStoresContent> createState() => _FriendGroupStoresContentState();
}

class _FriendGroupStoresContentState extends State<FriendGroupStoresContent> {

  String friendGroupStoreFilter = 'All';
  double get topPadding => showingFullPage ? 32 : 0;
  FriendGroup get friendGroup => widget.friendGroup;
  bool get showingFullPage => widget.showingFullPage;
  Function(ShoppableStore)? get onAddedStore => widget.onAddedStore;
  Function(List<ShoppableStore>)? get onRemovedStores => widget.onRemovedStores;
  
  /// This allows us to access the state of FriendGroupStoreFilters widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  late GlobalKey<FriendGroupStoreFiltersState>? _friendGroupStoreFiltersState;

  String get title {
    return 'Group Stores';
  }

  String get subtitle {
    return 'See stores added to this group';
  }

  @override
  void initState() {

    super.initState();

    /// If the review filter is provided
    if(widget.friendGroupStoreFilter != null) {
      
      /// Set the provided review filter
      friendGroupStoreFilter = widget.friendGroupStoreFilter!;

    }

    /// Set the "_friendGroupStoreFiltersState" so that we can access the FriendGroupStoreFilters widget state
    _friendGroupStoreFiltersState = GlobalKey<FriendGroupStoreFiltersState>();

  }

  /// Content to show based on the specified view
  Widget get content {

    /// Show friends view
    return FriendGroupStoresInVerticalListViewInfiniteScroll(
      friendGroup: friendGroup,
      onAddedStore: onAddedStore,
      onRemovedStores: onRemovedStores,
      friendGroupStoreFilter: friendGroupStoreFilter,
      changeFriendGroupStoreFilter: changeFriendGroupStoreFilter,
    );

  }

  /// Called when the friend group store filter has been changed,
  /// such as changing from "All" to "Popular"
  void onSelectedFriendGroupStoreFilter(String friendGroupStoreFilter) {
    setState(() => this.friendGroupStoreFilter = friendGroupStoreFilter);
  }

  /// Select the specified friend group store filter
  void changeFriendGroupStoreFilter(String friendGroupStoreFilter) {
    _friendGroupStoreFiltersState?.currentState?.changeFriendGroupStoreFilter(friendGroupStoreFilter);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              
              /// Wrap Padding around the following:
              /// Title, Subtitle
              Padding(
                padding: EdgeInsets.only(top: 20 + topPadding, left: 32, bottom: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              
                    /// Title
                    CustomTitleMediumText(title, padding: const EdgeInsets.only(bottom: 8),),
                    
                    /// Subtitle
                    Align(
                      key: ValueKey(subtitle),
                      alignment: Alignment.centerLeft,
                      child: CustomBodyText(subtitle),
                    ),

                    //  Filters
                    FriendGroupStoreFilters(
                      friendGroup: friendGroup,
                      key: _friendGroupStoreFiltersState,
                      friendGroupStoreFilter: friendGroupStoreFilter,
                      onSelectedFriendGroupStoreFilter: onSelectedFriendGroupStoreFilter
                    ),
                    
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
  
          /// Expand Icon
          if(!showingFullPage) Positioned(
            top: 8,
            right: 50,
            child: IconButton(
              icon: const Icon(Icons.open_in_full_rounded, size: 24, color: Colors.grey),
              onPressed: () {
                
                /// Close the Modal Bottom Sheet
                Get.back();
                
                /// Navigate to the page
                Get.toNamed(FriendGroupStoresPage.routeName);
              
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