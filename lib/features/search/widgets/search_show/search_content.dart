import 'package:bonako_demo/features/search/widgets/search_show/searched_friend_groups_in_vertical_list_view_infinite_scroll.dart';
import 'package:bonako_demo/features/search/widgets/search_show/searched_friends_in_vertical_list_view_infinite_scroll.dart';
import 'package:bonako_demo/features/search/widgets/search_show/searched_stores_in_vertical_list_view_infinite_scroll.dart';
import 'package:bonako_demo/core/shared_widgets/text_form_field/custom_search_text_form_field.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import 'package:bonako_demo/features/stores/services/store_services.dart';
import 'package:bonako_demo/features/stores/widgets/store_page/store_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../enums/search_enums.dart';
import 'search_page/search_page.dart';
import 'search_menus.dart';

class SearchContent extends StatefulWidget {
  
  final bool showingFullPage;

  const SearchContent({
    super.key,
    this.showingFullPage = false
  });

  @override
  State<SearchContent> createState() => _SearchContentState();
}

class _SearchContentState extends State<SearchContent> {

  String searchWord = '';
  bool isSearching = false;
  Menu selectedMenu = Menu.stores;
  bool disableFloatingActionButton = false;

  double get topPadding => showingFullPage ? 32 : 0;
  bool get showingFullPage => widget.showingFullPage;
  bool get hasSelectedStoresMenu => selectedMenu == Menu.stores;
  bool get hasSelectedFriendsMenu => selectedMenu == Menu.friends;
  bool get hasSelectedFriendGroupsMenu => selectedMenu == Menu.friendGroups;

  /// Content to show based on the specified view
  Widget get content {

    /// If we want to view the store search results content
    if(hasSelectedStoresMenu) {
      
      return SearchedStoresInVerticalListViewInfiniteScroll(
        onSelectedStore: onSelectedStore,
        onSearching: onSearching,
        searchWord: searchWord,
      );

    }else if(hasSelectedFriendsMenu) {
      
      return SearchedFriendsInVerticalListViewInfiniteScroll(
        onSelectedFriend: (_) {},
        onSearching: onSearching,
        searchWord: searchWord,
      );

    }else{
      
      return SearchedFriendGroupsInVerticalListViewInfiniteScroll(
        onSelectedFriendGroup: (_) {},
        onSearching: onSearching,
        searchWord: searchWord,
      );

      


    }
    
  }

  /// Search bar to input the search word
  Widget get searchInputField {  
    return Container(
      width: MediaQuery.of(context).size.width * 0.70,
      margin: const EdgeInsets.only(bottom: 8),
      child: CustomSearchTextFormField(
        initialValue: searchWord,
        isLoading: isSearching,
        onChanged: (value) {
          /// Set the search word
          setState(() => searchWord = value);
        }
      ),
    );
  }

  /// Called when we are making a search request
  void onSearching(bool isSearching) {

      /** 
       *  Note: Future.delayed() is used to prevent the following error:
       * 
       *  This SearchContent widget cannot be marked as needing to build 
       *  because the framework is already in the process of building 
       *  widgets. A widget can be marked as needing to be built 
       *  during the build phase only if one of its ancestors is 
       *  currently building. This exception is allowed because 
       *  the framework builds parent widgets before children, 
       *  which means a dirty descendant will always be built
       */
      Future.delayed(Duration.zero).then((value) {
        
        setState(() => this.isSearching = isSearching);

      });

  }

  /// Called after selecting a store
  void onSelectedStore(ShoppableStore store) {
    
    /// Close the modal bottom sheet
    Get.back();

    /// Navigate to the store page 
    StoreServices.navigateToStorePage(store);
  
  }

  /// Called when the primary content view has been changed,
  /// such as changing from "Stores" to "Friends"
  void onSelectedMenu(Menu selectedMenu) {
    setState(() => this.selectedMenu = selectedMenu);
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
                  padding: EdgeInsets.only(top: 20 + topPadding, left: 16, right: 16, bottom: 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// Search Input Field
                      searchInputField,
                      
                      //  Menus
                      SearchMenus(
                        selectedMenu: selectedMenu,
                        onSelectedMenu: onSelectedMenu
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
                
                /// Navigate to the page
                Navigator.of(context).pushNamed(SearchPage.routeName);
              
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