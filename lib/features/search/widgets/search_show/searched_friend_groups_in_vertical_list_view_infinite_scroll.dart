import '../../../../core/shared_widgets/infinite_scroll/custom_vertical_list_view_infinite_scroll.dart';
import '../../../../core/shared_widgets/text/custom_title_small_text.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../friend_groups/models/friend_group.dart';
import '../../repositories/search_repository.dart';
import '../../providers/search_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;

class SearchedFriendGroupsInVerticalListViewInfiniteScroll extends StatefulWidget {
  
  final String searchWord;
  final Function(bool) onSearching;
  final Function(FriendGroup) onSelectedFriendGroup;

  const SearchedFriendGroupsInVerticalListViewInfiniteScroll({
    super.key,
    required this.searchWord,
    required this.onSearching,
    required this.onSelectedFriendGroup,
  });

  @override
  State<SearchedFriendGroupsInVerticalListViewInfiniteScroll> createState() => _SearchedFriendGroupsInVerticalListViewInfiniteScrollState();
}

class _SearchedFriendGroupsInVerticalListViewInfiniteScrollState extends State<SearchedFriendGroupsInVerticalListViewInfiniteScroll> {

  /// This allows us to access the state of CustomVerticalListViewInfiniteScroll widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomVerticalInfiniteScrollState> _customVerticalListViewInfiniteScrollState = GlobalKey<CustomVerticalInfiniteScrollState>();

  Function(bool) get onSearching => widget.onSearching;
  SearchRepository get searchRepository => searchProvider.searchRepository;
  Function(FriendGroup) get onSelectedFriendGroup => widget.onSelectedFriendGroup;
  SearchProvider get searchProvider => Provider.of<SearchProvider>(context, listen: false);

  Widget onRenderItem(friendGroup, int index, List friends, bool isSelected, List selectedItems, bool hasSelectedItems, int totalSelectedItems) => FriendGroupItem(
    friendGroup: (friendGroup as FriendGroup),
    onSelectedFriendGroup: onSelectedFriendGroup
  );
  FriendGroup onParseItem(friendGroup) => FriendGroup.fromJson(friendGroup);
  Future<dio.Response> requestSearch(int page, String searchWord) {
    return searchRepository.searchFriendGroups(
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
      catchErrorMessage: 'Can\'t show groups',
      key: _customVerticalListViewInfiniteScrollState,
      onRequest: (page, searchWord) => requestSearch(page, searchWord),
      headerPadding: const EdgeInsets.only(top: 40, bottom: 0, left: 16, right: 16),
    );
  }
}

class FriendGroupItem extends StatefulWidget {
  
  final FriendGroup friendGroup;
  final Function(FriendGroup) onSelectedFriendGroup;

  const FriendGroupItem({
    super.key, 
    required this.friendGroup,
    required this.onSelectedFriendGroup,
  });

  @override
  State<FriendGroupItem> createState() => _FriendGroupItemState();
}

class _FriendGroupItemState extends State<FriendGroupItem> {

  FriendGroup get friendGroup => widget.friendGroup;
  Function(FriendGroup) get onSelectedFriendGroup => widget.onSelectedFriendGroup;

  int get totalFriends => friendGroup.friendsCount!;
  String get totalFriendsText => '$totalFriends ${totalFriends == 1 ? 'Friend' : 'Friends'}';

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey<int>(widget.friendGroup.id),
      direction: DismissDirection.horizontal,
      confirmDismiss: (DismissDirection direction) { 
        if(direction == DismissDirection.startToEnd) {

          /// Select this friendGroup item
          onSelectedFriendGroup(friendGroup);

        }

        /// Do not dismiss this friendGroup item
        return Future.delayed(Duration.zero).then((value) => false);

      },
      child: ListTile(
        dense: true,

        onTap: () {

          /// Select this friendGroup item
          onSelectedFriendGroup(friendGroup);

        },

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Name
            CustomTitleSmallText(friendGroup.name),

            /// Spacer
            const SizedBox(height: 4,),

            Row(
              children: [
      
                /// Total Friends
                CustomBodyText(totalFriendsText, lightShade: true,),

              ],
            ),

          ],
        )
      
      ),
    );
  }
}