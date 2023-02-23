import '../../../../core/shared_widgets/infinite_scroll/custom_vertical_list_view_infinite_scroll.dart';
import '../../../../core/shared_widgets/text/custom_title_small_text.dart';
import '../../../../core/shared_models/user_and_store_association.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../../core/shared_models/mobile_number.dart';
import '../../../stores/providers/store_provider.dart';
import '../../../stores/models/shoppable_store.dart';
import '../../../../core/shared_models/user.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class FollowersInVerticalListViewInfiniteScroll extends StatefulWidget {
  
  final ShoppableStore store;
  final String followerFilter;

  const FollowersInVerticalListViewInfiniteScroll({
    super.key,
    required this.store,
    required this.followerFilter,
  });

  @override
  State<FollowersInVerticalListViewInfiniteScroll> createState() => _FollowersInVerticalListViewInfiniteScrollState();
}

class _FollowersInVerticalListViewInfiniteScrollState extends State<FollowersInVerticalListViewInfiniteScroll> {

  /// This allows us to access the state of CustomVerticalListViewInfiniteScroll widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomVerticalInfiniteScrollState> _customVerticalListViewInfiniteScrollState = GlobalKey<CustomVerticalInfiniteScrollState>();

  ShoppableStore get store => widget.store;
  String get followerFilter => widget.followerFilter;
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);

  /// Render each request item as an FollowerItem
  Widget onRenderItem(user, int index, List users, bool isSelected, List selectedItems, bool hasSelectedItems, int totalSelectedItems) => FollowerItem(user: (user as User), index: index);
  
  /// Render each request item as an User
  User onParseItem(user) => User.fromJson(user);
  Future<http.Response> requestStoreFollowers(int page, String searchWord) {
    return storeProvider.setStore(store).storeRepository.showFollowers(
      /// Filter by the follower filter specified (followerFilter)
      filter: followerFilter,
      searchWord: searchWord,
      page: page
    );
  }

  @override
  void didUpdateWidget(covariant FollowersInVerticalListViewInfiniteScroll oldWidget) {
    super.didUpdateWidget(oldWidget);

    /// If the user following filter changed
    if(followerFilter != oldWidget.followerFilter) {

      /// Start a new request
      _customVerticalListViewInfiniteScrollState.currentState!.startRequest();

    }
  }
  
  @override
  Widget build(BuildContext context) {
    return CustomVerticalListViewInfiniteScroll(
      debounceSearch: true,
      onParseItem: onParseItem, 
      onRenderItem: onRenderItem,
      key: _customVerticalListViewInfiniteScrollState,
      catchErrorMessage: 'Can\'t show followers',
      onRequest: (page, searchWord) => requestStoreFollowers(page, searchWord),
      headerPadding: const EdgeInsets.only(top: 40, bottom: 0, left: 16, right: 16),
    );
  }
}

class FollowerItem extends StatelessWidget {
  
  final User user;
  final int index;

  const FollowerItem({super.key, required this.user, required this.index});

  String get dateType => invited ? 'invited' : 'last seen';
  DateTime get createdAt => userAndStoreAssociation.createdAt;
  DateTime? get lastSeenAt => userAndStoreAssociation.lastSeenAt;
  MobileNumber? get mobileNumber => userAndStoreAssociation.mobileNumber;
  String get date => invited ? timeago.format(createdAt) : timeago.format(lastSeenAt!);
  bool get invited => userAndStoreAssociation.followerStatus.toLowerCase() == 'invited';
  String get title => mobileNumber == null ? user.attributes.name : mobileNumber!.withoutExtension;
  UserAndStoreAssociation get userAndStoreAssociation => user.attributes.userAndStoreAssociation!;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      key: ValueKey<int>(user.id),
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),

      /// Name / Mobile Number
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          /// Title (Name / Mobile Number)
          CustomTitleSmallText(title),

          /// Datetime (Created At / Last Seen)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [

              /// Date Type (last seen / invited)
              CustomBodyText(dateType, lightShade: true,),

              /// Spacer
              const SizedBox(height: 4,),

              /// Date (10 days ago)
              CustomBodyText(date)
              
            ],
          )
        ],
      )
      
    );
  }
}