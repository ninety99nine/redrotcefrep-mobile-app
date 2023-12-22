import '../../../../core/shared_widgets/infinite_scroll/custom_vertical_list_view_infinite_scroll.dart';
import '../../../../core/shared_widgets/text/custom_title_small_text.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../repositories/search_repository.dart';
import '../../../../core/shared_models/user.dart';
import '../../providers/search_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;

class SearchedFriendsInVerticalListViewInfiniteScroll extends StatefulWidget {
    
  final String searchWord;
  final Function(bool) onSearching;
  final Function(User) onSelectedFriend;

  const SearchedFriendsInVerticalListViewInfiniteScroll({
    super.key,
    required this.searchWord,
    required this.onSearching,
    required this.onSelectedFriend,
  });

  @override
  State<SearchedFriendsInVerticalListViewInfiniteScroll> createState() => _SearchedFriendsInVerticalListViewInfiniteScrollState();
}

class _SearchedFriendsInVerticalListViewInfiniteScrollState extends State<SearchedFriendsInVerticalListViewInfiniteScroll> {

  /// This allows us to access the state of CustomVerticalListViewInfiniteScroll widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomVerticalListViewInfiniteScrollState> _customVerticalListViewInfiniteScrollState = GlobalKey<CustomVerticalListViewInfiniteScrollState>();

  Function(bool) get onSearching => widget.onSearching;
  Function(User) get onSelectedFriend => widget.onSelectedFriend;
  SearchRepository get searchRepository => searchProvider.searchRepository;
  SearchProvider get searchProvider => Provider.of<SearchProvider>(context, listen: false);

  Widget onRenderItem(user, int index, List friends, bool isSelected, List selectedItems, bool hasSelectedItems, int totalSelectedItems) => FriendItem(
    user: (user as User),
    onSelectedFriend: onSelectedFriend
  );
  User onParseItem(user) => User.fromJson(user);
  Future<dio.Response> requestSearch(int page, String searchWord) {
    return searchRepository.searchFriends(
      searchWord: searchWord,
      page: page
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return CustomVerticalListViewInfiniteScroll(
      debounceSearch: true,
      showSearchBar: false,
      showNoMoreContent: false,
      onSearching: onSearching,
      onParseItem: onParseItem, 
      onRenderItem: onRenderItem,
      searchWord: widget.searchWord,
      key: _customVerticalListViewInfiniteScrollState,
      catchErrorMessage: 'Can\'t show friends',
      onRequest: (page, searchWord) => requestSearch(page, searchWord),
      headerPadding: const EdgeInsets.only(top: 40, bottom: 0, left: 16, right: 16),
    );
  }
}

class FriendItem extends StatefulWidget {
  
  final User user;
  final Function(User) onSelectedFriend;

  const FriendItem({
    super.key, 
    required this.user,
    required this.onSelectedFriend,
  });

  @override
  State<FriendItem> createState() => _FriendItemState();
}

class _FriendItemState extends State<FriendItem> {

  User get user => widget.user;
  Function(User) get onSelectedFriend => widget.onSelectedFriend;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey<int>(widget.user.id),
      direction: DismissDirection.horizontal,
      confirmDismiss: (DismissDirection direction) { 
        if(direction == DismissDirection.startToEnd) {

          /// Select this user item
          onSelectedFriend(user);

        }

        /// Do not dismiss this user item
        return Future.delayed(Duration.zero).then((value) => false);

      },
      child: ListTile(
        dense: true,

        onTap: () {

          /// Select this user item
          onSelectedFriend(user);

        },

        title: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [

            /// Avatar
            const CircleAvatar(
              child: Icon(Icons.person),
            ),

            /// Spacer
            const SizedBox(width: 8,),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// Name
                CustomTitleSmallText(user.attributes.name),

                /// Spacer
                const SizedBox(height: 4,),
          
                /// Mobile Number
                CustomBodyText(user.mobileNumber!.withoutExtension, lightShade: true,),

              ],
            )

          ],
        ),
      
      ),
    );
  }
}