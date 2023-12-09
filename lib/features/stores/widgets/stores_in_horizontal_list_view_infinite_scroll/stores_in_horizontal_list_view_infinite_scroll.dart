import '../../../../core/shared_widgets/infinite_scroll/custom_horizontal_list_view_infinite_scroll.dart';
import 'package:bonako_demo/features/authentication/providers/auth_provider.dart';
import '../../../../core/shared_widgets/text/custom_title_small_text.dart';
import '../store_cards/store_card/primary_section_content/store_logo.dart';
import 'package:bonako_demo/features/stores/services/store_services.dart';
import '../../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../../core/shared_models/user_store_association.dart';
import '../../../../../core/shared_widgets/cards/custom_card.dart';
import '../follow_store/follow_store_button.dart';
import '../../../../core/shared_models/user.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../providers/store_provider.dart';
import '../../models/shoppable_store.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../enums/store_enums.dart';
import 'package:dio/dio.dart' as dio;

class StoresInHorizontalListViewInfiniteScroll extends StatefulWidget {
  
  final User? user;
  final EdgeInsetsGeometry listPadding;
  final UserAssociation userAssociation;
  final EdgeInsetsGeometry headerPadding;
  final Function(ShoppableStore)? onSelectedStore;
  final Widget Function(bool, int)? contentBeforeSearchBar;
  final StoresInHorizontalListViewDesignType storesInHorizontalListViewDesignType;

  const StoresInHorizontalListViewInfiniteScroll({
    Key? key,
    this.user,
    this.onSelectedStore,
    this.contentBeforeSearchBar,
    required this.userAssociation,
    this.listPadding = const EdgeInsets.symmetric(horizontal: 16),
    this.headerPadding = const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
    this.storesInHorizontalListViewDesignType = StoresInHorizontalListViewDesignType.followable
  }) : super(key: key);

  @override
  State<StoresInHorizontalListViewInfiniteScroll> createState() => StoresInHorizontalListViewInfiniteScrollState();
}

class StoresInHorizontalListViewInfiniteScrollState extends State<StoresInHorizontalListViewInfiniteScroll> {

  bool hasStores = false;
  ShoppableStore? selectedStore;
  User? get user => widget.user;
  EdgeInsetsGeometry get listPadding => widget.listPadding;
  EdgeInsetsGeometry get headerPadding => widget.headerPadding;
  UserAssociation get userAssociation => widget.userAssociation;
  Function(ShoppableStore)? get onSelectedStore => widget.onSelectedStore;
  bool get isAssociatedAsCustomer => userAssociation == UserAssociation.customer;
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  Widget Function(bool, int)? get contentBeforeSearchBar => widget.contentBeforeSearchBar;
  bool get isAssociatedAsRecentVisitor => userAssociation == UserAssociation.recentVisitor;
  StoresInHorizontalListViewDesignType get storesInHorizontalListViewDesignType => widget.storesInHorizontalListViewDesignType;

  void selectStore(ShoppableStore store) {
    setState(() {
      selectedStore = store;
      if(onSelectedStore != null) onSelectedStore!(store); 
    });
  }

  /// Render each request item as an FollowableStoreItem
  Widget onRenderItem(store, int index, List stores) {
    
    if(storesInHorizontalListViewDesignType == StoresInHorizontalListViewDesignType.followable) {

      return FollowableStoreItem(
        isAssociatedAsRecentVisitor: isAssociatedAsRecentVisitor,
        isAssociatedAsCustomer: isAssociatedAsCustomer,
        store: (store as ShoppableStore),
        index: index,
        //  user: user,
      );

    }else{

      final selected = selectedStore!.id == store.id;

      return SelectableStoreItem(
        isAssociatedAsRecentVisitor: isAssociatedAsRecentVisitor,
        isAssociatedAsCustomer: isAssociatedAsCustomer,
        store: (store as ShoppableStore),
        selectStore: selectStore,
        selected: selected,
        index: index,
        //  user: user,
      );

    }
  }

  /// Render each request item as an Store
  ShoppableStore onParseItem(store) => ShoppableStore.fromJson(store);
  Future<dio.Response> requestStores(int page, String searchWord) {

    return storeProvider.storeRepository.showUserStores(
      userAssociation: userAssociation,
      user: authProvider.user!,
      searchWord: searchWord,
      page: page
    ).then((response) {

      if( response.statusCode == 200 ) {

        setState(() {

          /// Determine if we have any stores
          hasStores = response.data['total'] > 0;

          if(hasStores) {
            
            /// Capture the first store
            final ShoppableStore firstStore = ShoppableStore.fromJson(response.data['data'][0]);
            
            /// Set the first store to be the selected store
            selectStore(firstStore);

          } 

        });
        
      }

      return response;

    });
  }

  Widget _contentBeforeSearchBar(isLoading, totalItems) {

    if(contentBeforeSearchBar == null) {
 
      String title = 'Title';
      String subtitle = 'Subtitle';

      if(isAssociatedAsCustomer) {
        
        title = 'Local Sellers';
        subtitle = 'Check out local stores you support';

      }else if(isAssociatedAsRecentVisitor) {
        
        title = 'Recent Visits';
        subtitle = 'Check out stores you recently visited';

      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CustomTitleSmallText(title),
          const SizedBox(height: 4,),
          CustomBodyText(subtitle, lightShade: true,),
        ],
      );

    }else{
      
      return contentBeforeSearchBar!(isLoading, totalItems);

    }

  }

  Widget get noContentWidget {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.access_time_outlined, size: 24, color: Colors.grey.shade300,),
          const SizedBox(width: 8,),
          const CustomBodyText(
            'No stores yet', 
            lightShade: true
          ),
        ],
      ),
    );
  }

  double get height {
    if(storesInHorizontalListViewDesignType == StoresInHorizontalListViewDesignType.followable) {
      return 180;
    }else{
      return 140;
    }
  }
  
  @override
  Widget build(BuildContext context) {

    return CustomHorizontalListViewInfiniteScroll(
      height: height,
      showSearchBar: false,
      debounceSearch: true,
      showNoMoreContent: false,
      onParseItem: onParseItem, 
      listPadding: listPadding,
      onRenderItem: onRenderItem,
      headerPadding: headerPadding,
      showFirstRequestLoader: false,
      noContentWidget: noContentWidget,
      catchErrorMessage: 'Can\'t show stores',
      contentBeforeSearchBar: _contentBeforeSearchBar,
      margin: const EdgeInsets.symmetric(vertical: 16),
      loaderMargin: const EdgeInsets.symmetric(vertical: 16),
      onRequest: (page, searchWord) => requestStores(page, searchWord),
    );
  }
}

class FollowableStoreItem extends StatefulWidget {
  
  //  final User user;
  final int index;
  final ShoppableStore store;
  final bool isAssociatedAsCustomer;
  final bool isAssociatedAsRecentVisitor;

  const FollowableStoreItem({
    super.key,
    //  required this.user,
    required this.index,
    required this.store,
    required this.isAssociatedAsCustomer,
    required this.isAssociatedAsRecentVisitor
  });

  @override
  State<FollowableStoreItem> createState() => _FollowableStoreItemState();
}

class _FollowableStoreItemState extends State<FollowableStoreItem> {

  int get index => widget.index;
  ShoppableStore get store => widget.store;
  bool get isAssociatedAsCustomer => widget.isAssociatedAsCustomer;
  bool get isAssociatedAsRecentVisitor => widget.isAssociatedAsRecentVisitor;
  int get totalOrdersRequested => store.attributes.userStoreAssociation!.totalOrdersRequested!;
  UserStoreAssociation get userStoreAssociation => store.attributes.userStoreAssociation!;
  String get totalOrdersRequestedText => '$totalOrdersRequested ${totalOrdersRequested == 1 ? 'Order' : 'Orders'}';

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 4),
      width: MediaQuery.of(context).size.width * 0.5,
      child: GestureDetector(
        onTap: () {
          
          /// Navigate to the store page 
          StoreServices.navigateToStorePage(store);

        },
        child: CustomCard(
          margin: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                  
              /// Store Logo
              StoreLogo(store: store, radius: 24),
      
              /// Spacer
              const SizedBox(height: 8,),
                      
              /// Store Name
              CustomBodyText(store.name, overflow: TextOverflow.ellipsis, height: 1.4,),
      
              /// Spacer
              const SizedBox(height: 4,),
                      
              /// Total Orders Requested
              if(isAssociatedAsCustomer) CustomBodyText(totalOrdersRequestedText, lightShade: true,),
                      
              /// Last Seen
              if(isAssociatedAsRecentVisitor) CustomBodyText(timeago.format(userStoreAssociation.lastSeenAt!), lightShade: true,),
      
              /// Spacer
              const SizedBox(height: 4,),
      
              /// Follow / Unfollow Button
              FollowStoreButton(store: store)
      
            ],
          ),
        ),
      ),
    );

  }
}

class SelectableStoreItem extends StatefulWidget {
  
  //  final User user;
  final int index;
  final bool selected;
  final ShoppableStore store;
  final bool isAssociatedAsCustomer;
  final bool isAssociatedAsRecentVisitor;
  final Function(ShoppableStore) selectStore;

  const SelectableStoreItem({
    super.key,
    //  required this.user,
    required this.index,
    required this.store,
    required this.selected,
    required this.selectStore,
    required this.isAssociatedAsCustomer,
    required this.isAssociatedAsRecentVisitor
  });

  @override
  State<SelectableStoreItem> createState() => _SelectableStoreItemState();
}

class _SelectableStoreItemState extends State<SelectableStoreItem> {

  int get index => widget.index;
  bool get selected => widget.selected;
  ShoppableStore get store => widget.store;
  Function(ShoppableStore) get selectStore => widget.selectStore;
  bool get isAssociatedAsCustomer => widget.isAssociatedAsCustomer;
  bool get isAssociatedAsRecentVisitor => widget.isAssociatedAsRecentVisitor;
  int get totalOrdersRequested => store.attributes.userStoreAssociation!.totalOrdersRequested!;
  UserStoreAssociation get userStoreAssociation => store.attributes.userStoreAssociation!;
  String get totalOrdersRequestedText => '$totalOrdersRequested ${totalOrdersRequested == 1 ? 'Order' : 'Orders'}';

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 4),
      width: MediaQuery.of(context).size.width * 0.5,
      child: GestureDetector(
        onTap: () {
          
          /// Select the store
          selectStore(store);

        },
        child: CustomCard(
          margin: EdgeInsets.zero,
          borderColor: selected ? Colors.black : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                  
              /// Store Logo
              StoreLogo(store: store, radius: 24),
      
              /// Spacer
              const SizedBox(height: 8,),
                      
              /// Store Name
              CustomBodyText(store.name, overflow: TextOverflow.ellipsis, height: 1.4,),
      
              /// Spacer
              const SizedBox(height: 4,),
                      
              /// Total Orders Requested
              if(isAssociatedAsCustomer) CustomBodyText(totalOrdersRequestedText, lightShade: true,),
                      
              /// Last Seen
              if(isAssociatedAsRecentVisitor) CustomBodyText(timeago.format(userStoreAssociation.lastSeenAt!), lightShade: true,),
      
            ],
          ),
        ),
      ),
    );

  }
}