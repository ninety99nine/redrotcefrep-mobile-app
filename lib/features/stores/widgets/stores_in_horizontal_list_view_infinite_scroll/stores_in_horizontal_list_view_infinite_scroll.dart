import '../../../../core/shared_widgets/infinite_scroll/custom_horizontal_list_view_infinite_scroll.dart';
import 'package:bonako_demo/features/authentication/providers/auth_provider.dart';
import '../../../../core/shared_widgets/text/custom_title_small_text.dart';
import '../store_cards/store_card/primary_section_content/store_logo.dart';
import 'package:bonako_demo/features/stores/services/store_services.dart';
import '../../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../../core/shared_models/user_store_association.dart';
import '../../../../../core/shared_widgets/cards/custom_card.dart';
import '../../../../core/shared_models/user.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../follow_store/follow_store_button.dart';
import '../../providers/store_provider.dart';
import '../../models/shoppable_store.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../../enums/store_enums.dart';
import 'dart:convert';

class StoresInHorizontalListViewInfiniteScroll extends StatefulWidget {
  
  final User? user;
  final UserAssociation userAssociation;

  const StoresInHorizontalListViewInfiniteScroll({
    Key? key,
    this.user,
    required this.userAssociation
  }) : super(key: key);

  @override
  State<StoresInHorizontalListViewInfiniteScroll> createState() => StoresInHorizontalListViewInfiniteScrollState();
}

class StoresInHorizontalListViewInfiniteScrollState extends State<StoresInHorizontalListViewInfiniteScroll> {

  bool hasStores = false;
  User? get user => widget.user;
  UserAssociation get userAssociation => widget.userAssociation;
  bool get isAssociatedAsCustomer => userAssociation == UserAssociation.customer;
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  bool get isAssociatedAsRecentVisitor => userAssociation == UserAssociation.recentVisitor;

  /// Render each request item as an StoreItem
  Widget onRenderItem(store, int index, List stores) => StoreItem(
    isAssociatedAsRecentVisitor: isAssociatedAsRecentVisitor,
    isAssociatedAsCustomer: isAssociatedAsCustomer,
    store: (store as ShoppableStore),
    index: index,
    //  user: user,
  );

  /// Render each request item as an Store
  ShoppableStore onParseItem(store) => ShoppableStore.fromJson(store);
  Future<http.Response> requestStores(int page, String searchWord) {

    return storeProvider.storeRepository.showUserStores(
      userAssociation: userAssociation,
      user: authProvider.user!,
      searchWord: searchWord,
      page: page
    ).then((response) {

      if( response.statusCode == 200 ) {

        setState(() {
          
          /// Get the response body
          final responseBody = jsonDecode(response.body);

          /// Determine if we have any stores
          hasStores = responseBody['total'] > 0;

        });
        
      }

      return response;

    });
  }

  Widget get contentBeforeSearchBar {
    
    String title = 'Title';
    String subtitle = 'Subtitle';

    if(isAssociatedAsCustomer) {
      
      title = 'Support Local';
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
  
  @override
  Widget build(BuildContext context) {

    return CustomHorizontalListViewInfiniteScroll(
      height: 194,
      showSearchBar: false,
      debounceSearch: true,
      showNoMoreContent: false,
      onParseItem: onParseItem, 
      onRenderItem: onRenderItem,
      showFirstRequestLoader: false,
      noContentWidget: noContentWidget,
      catchErrorMessage: 'Can\'t show stores',
      contentBeforeSearchBar: contentBeforeSearchBar,
      margin: const EdgeInsets.symmetric(vertical: 16),
      loaderMargin: const EdgeInsets.symmetric(vertical: 16),
      listPadding: const EdgeInsets.symmetric(horizontal: 16),
      onRequest: (page, searchWord) => requestStores(page, searchWord),
      headerPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
    );
  }
}

class StoreItem extends StatefulWidget {
  
  //  final User user;
  final int index;
  final ShoppableStore store;
  final bool isAssociatedAsCustomer;
  final bool isAssociatedAsRecentVisitor;

  const StoreItem({
    super.key,
    //  required this.user,
    required this.index,
    required this.store,
    required this.isAssociatedAsCustomer,
    required this.isAssociatedAsRecentVisitor
  });

  @override
  State<StoreItem> createState() => _StoreItemState();
}

class _StoreItemState extends State<StoreItem> {

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
      margin: const EdgeInsets.only(right: 8),
      width: MediaQuery.of(context).size.width * 0.5,
      child: GestureDetector(
        onTap: () {
          
          /// Navigate to the store page 
          StoreServices.navigateToStorePage(store);

        },
        child: CustomCard(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
      
              /// Store Logo
              StoreLogo(store: store),
      
              /// Spacer
              const SizedBox(height: 8,),
                      
              /// Store Name
              CustomBodyText(store.name),
      
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