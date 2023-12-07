import 'package:get/get.dart';

import '../../../../core/shared_widgets/infinite_scroll/custom_vertical_list_view_infinite_scroll.dart';
import '../../../../core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import 'package:bonako_demo/features/authentication/providers/auth_provider.dart';
import '../../../../core/shared_widgets/text/custom_title_small_text.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../stores/providers/store_provider.dart';
import '../../../stores/models/shoppable_store.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../stores/enums/store_enums.dart';
import '../../../../core/utils/snackbar.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;

class FollowerInvitationsInVerticalListViewInfiniteScroll extends StatefulWidget {
  
  final bool? isAcceptingAll;
  final bool? isDecliningAll;
  final Function() onRespondedToInvitation;
  final Function(Future<dio.Response>) onRequest;

  const FollowerInvitationsInVerticalListViewInfiniteScroll({
    super.key,
    this.isAcceptingAll,
    this.isDecliningAll,
    required this.onRequest,
    required this.onRespondedToInvitation,
  });

  @override
  State<FollowerInvitationsInVerticalListViewInfiniteScroll> createState() => _FollowerInvitationsInVerticalListViewInfiniteScrollState();
}

class _FollowerInvitationsInVerticalListViewInfiniteScrollState extends State<FollowerInvitationsInVerticalListViewInfiniteScroll> {

  /// This allows us to access the state of CustomVerticalListViewInfiniteScroll widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomVerticalInfiniteScrollState> _customVerticalListViewInfiniteScrollState = GlobalKey<CustomVerticalInfiniteScrollState>();

  bool? get isAcceptingAll => widget.isAcceptingAll;
  bool? get isDecliningAll => widget.isDecliningAll;
  Function(Future<dio.Response>) get onRequest => widget.onRequest;
  Function() get onRespondedToInvitation => widget.onRespondedToInvitation;
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);

  /// Render each request item as an InvitationItem
  Widget onRenderItem(store, int index, List users, bool isSelected, List selectedItems, bool hasSelectedItems, int totalSelectedItems) => InvitationItem(
    customVerticalListViewInfiniteScrollState: _customVerticalListViewInfiniteScrollState,
    onRespondedToInvitation: onRespondedToInvitation,
    store: (store as ShoppableStore), 
    isAcceptingAll: isAcceptingAll,
    isDecliningAll: isDecliningAll,
    index: index
  );

  /// Render each request item as an ShoppableStore
  ShoppableStore onParseItem(store) => ShoppableStore.fromJson(store);
  Future<dio.Response> requestInvitedStores(int page, String searchWord) {
    
    Future<dio.Response> response = storeProvider.storeRepository.showUserStores(
      /// Return stores were the user is invited to follow
      userAssociation: UserAssociation.invitedToFollow,
      user: authProvider.user!,
      searchWord: searchWord,
      page: page
    );

    /// Notify parent 
    onRequest(response);

    return response;

  }
  
  @override
  Widget build(BuildContext context) {
    return CustomVerticalListViewInfiniteScroll(
      debounceSearch: true,
      onParseItem: onParseItem, 
      onRenderItem: onRenderItem,
      key: _customVerticalListViewInfiniteScrollState,
      onRequest: (page, searchWord) => requestInvitedStores(page, searchWord),
      headerPadding: const EdgeInsets.only(top: 40, bottom: 0, left: 16, right: 16),
      catchErrorMessage: 'Can\'t show invitations'
    );
  }
}

class InvitationItem extends StatefulWidget {
  
  final int index;
  final bool? isAcceptingAll;
  final bool? isDecliningAll;
  final ShoppableStore store;
  final Function() onRespondedToInvitation;
  
  final GlobalKey<CustomVerticalInfiniteScrollState> customVerticalListViewInfiniteScrollState;

  const InvitationItem({
    super.key, 
    required this.store, 
    required this.index,
    this.isAcceptingAll,
    this.isDecliningAll,
    required this.onRespondedToInvitation,
    required this.customVerticalListViewInfiniteScrollState,
  });

  @override
  State<InvitationItem> createState() => _InvitationItemState();
}

class _InvitationItemState extends State<InvitationItem> {

  bool isLoading = false;

  int get index => widget.index;
  ShoppableStore get store => widget.store;
  bool? get isAcceptingAll => widget.isAcceptingAll;
  bool? get isDecliningAll => widget.isDecliningAll;
  void _startLoader() => setState(() => isLoading = true);
  void _stopLoader() => setState(() => isLoading = false);
  Function() get onRespondedToInvitation => widget.onRespondedToInvitation;
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);

  /// Request to accept invitation to follow store
  Future<bool> requestAcceptInvitationToFollow() {
    
    _startLoader();

    return storeProvider.setStore(store).storeRepository.acceptInvitationToFollow()
    .then((response) {

      if(response.statusCode == 200) {

        SnackbarUtility.showSuccessMessage(message: response.data['message']);

        /// Notify the parent that user responded to the invitation
        onRespondedToInvitation();

        return true;

      }

      return false;

    }).catchError((error) {

      printError(info: error.toString());

      SnackbarUtility.showErrorMessage(message: 'Failed to accept invitation');

    }).whenComplete(() {

      _stopLoader();

    });

  }

  /// Request to decline invitation to follow store
  Future<bool> requestDeclineInvitationToFollow() async {
    
    _startLoader();

    return storeProvider.setStore(store).storeRepository.declineInvitationToFollow()
    .then((response) {

      if(response.statusCode == 200) {

        SnackbarUtility.showSuccessMessage(message: response.data['message']);

        /// Notify the parent that user responded to the invitation
        onRespondedToInvitation();

        return true;

      }

      return false;

    }).catchError((error) {

      printError(info: error.toString());

      SnackbarUtility.showErrorMessage(message: 'Failed to decline invitation');

    }).whenComplete(() {

      _stopLoader();

    });
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey<int>(widget.store.id),
      direction: DismissDirection.horizontal,
      onDismissed: (DismissDirection direction) {
        final totalItemsLeft = widget.customVerticalListViewInfiniteScrollState.currentState!.removeItemAt(index);

        /// If we don't have any items left
        if(totalItemsLeft == 0) {

          /// Close the modal (Return false to notify the parent to refresh)
          Get.back(result: true);

        }
      },
      confirmDismiss: (DismissDirection direction) {
        if(isAcceptingAll == true || isDecliningAll == true) {
          
          /// Do not permit any actions when accepting or declining all
          return Future.delayed(Duration.zero).then((_) => false);

        }else{
          
          if(direction == DismissDirection.startToEnd) {
            return requestAcceptInvitationToFollow();
          }else {
            return requestDeclineInvitationToFollow();
          }

        }
      },
      background: Container(
        color: Colors.grey.shade100,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: isLoading ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
          children: [

            /// Loader
            if(isLoading) const CustomCircularProgressIndicator(),

            /// Check Mark
            if(!isLoading) const Icon(Icons.check_circle_rounded, color: Colors.green),
            
            /// Cancel Mark
            if(!isLoading) const Icon(Icons.remove_circle_rounded, color: Colors.red)
          
          ],
        ),
      ),
      child: ListTile(
        dense: true,

        /// Store name
        title: CustomTitleSmallText(widget.store.name),

        /// Store Created At
        trailing: CustomBodyText(timeago.format(widget.store.createdAt)),
      
      ),
    );
  }
}