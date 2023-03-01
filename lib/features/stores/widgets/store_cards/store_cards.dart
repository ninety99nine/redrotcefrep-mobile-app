import '../../../followers/widgets/follower_invitations_show/follower_invitations_modal_bottom_sheet/follower_invitations_modal_bottom_sheet.dart';
import '../../../team_members/widgets/team_member_invitations_show/team_member_invitations_modal_popup/team_member_invitations_modal_popup.dart';
import '../../../../core/shared_widgets/infinite_scroll/custom_vertical_list_view_infinite_scroll.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../friend_groups/models/friend_group.dart';
import '../../models/check_store_invitations.dart';
import '../../../../../core/utils/snackbar.dart';
import '../../providers/store_provider.dart';
import '../../models/shoppable_store.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../enums/store_enums.dart';
import 'store_card/store_card.dart';
import 'dart:convert';

class StoreCards extends StatefulWidget {

  final FriendGroup? friendGroup;
  final Widget? contentBeforeSearchBar;
  final UserAssociation userAssociation;

  const StoreCards({
    Key? key,
    this.friendGroup,
    required this.userAssociation,
    required this.contentBeforeSearchBar,
  }) : super(key: key);

  @override
  State<StoreCards> createState() => StoreCardsState();
}

class StoreCardsState extends State<StoreCards> {

  CheckStoreInvitations? checkStoreInvitations;
  FriendGroup? get friendGroup => widget.friendGroup;
  UserAssociation get userAssociation => widget.userAssociation;
  Widget? get contentBeforeSearchBar => widget.contentBeforeSearchBar;
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  
  final GlobalKey<CustomVerticalInfiniteScrollState> _customVerticalListViewInfiniteScrollState = GlobalKey<CustomVerticalInfiniteScrollState>();
  
  bool get showInvitationsBanner => scrolledToTop && checkStoreInvitations != null && checkStoreInvitations!.hasInvitations;
  
  String get invitationsBannerText {
    if(checkStoreInvitations != null) {
      if(userAssociation == UserAssociation.teamMember) {
        return 'You have been invited to join ${checkStoreInvitations!.totalInvitations} ${checkStoreInvitations!.totalInvitations == 1 ? 'store' : 'stores'}';
      }else{
        return 'You have been invited to follow ${checkStoreInvitations!.totalInvitations} ${checkStoreInvitations!.totalInvitations == 1 ? 'store' : 'stores'}';
      }
    }else{
      return '';
    }
  }

  @override
  void initState() {
    super.initState();
    requestStoreInvitations();

    /// Set the refresh method on the store provider so that we can easily refresh the
    /// stores from anyway in the application. This way we don't have to keep passing
    /// the refreshStores() method on multiple nested child widgets.
    storeProvider.refreshStores = refreshStores;
  }

  @override
  void didUpdateWidget(covariant StoreCards oldWidget) {

    super.didUpdateWidget(oldWidget);

    /// If the friend group id has changed.
    /// This happends if we are switching the friend group
    if(friendGroup?.id != oldWidget.friendGroup?.id) {

      /// Start a new request (so that we can filter stores by the specified friend group id)
      startRequest();

    }

  }

  void startRequest() {

    if(_customVerticalListViewInfiniteScrollState.currentState != null) {

      _customVerticalListViewInfiniteScrollState.currentState!.startRequest();

    }

  }

  Widget onRenderItem(store, int index, List stores, bool isSelected, List selectedItems, bool hasSelectedItems, int totalSelectedItems) => StoreCard(
    store: (store as ShoppableStore)
  );
  ShoppableStore onParseItem(store) => ShoppableStore.fromJson(store);
  Future<http.Response> requestShowStores(int page, String searchWord) {
    return storeProvider.storeRepository.showStores(
      withCountActiveSubscriptions: true,
      withAuthActiveSubscription: true,
      userAssociation: userAssociation,
      withCountTeamMembers: true,
      withVisitShortcode: true,
      friendGroup: friendGroup,
      withCountFollowers: true,
      withCountReviews: true,
      searchWord: searchWord,
      withCountCoupons: true,
      withCountOrders: true,
      withProducts: true,
      withRating: true,
      page: page
    );
  }

  /// Check invitations
  void requestStoreInvitations() async {

    final Future<http.Response> request;

    if(userAssociation == UserAssociation.teamMember) {
      request = requestStoreInvitationsToJoinTeam();
    }else{
      request = requestStoreInvitationsToFollow();
    }

    request.then((http.Response response) {

      if(!mounted) return response;

      if( response.statusCode == 200 ) {

        final responseBody = jsonDecode(response.body);
        
        setState(() => checkStoreInvitations = CheckStoreInvitations.fromJson(responseBody));

      }

      return response;

    }).catchError((error) {

      /// Show the error message
      SnackbarUtility.showErrorMessage(message: 'Can\'t check invitations');

    });

  }

  /// Check the invitations to join teams
  Future<http.Response> requestStoreInvitationsToJoinTeam() {
    return storeProvider.storeRepository.checkStoreInvitationsToJoinTeam();
  }

  /// Check the invitations to follow
  Future<http.Response> requestStoreInvitationsToFollow() {
    return storeProvider.storeRepository.checkStoreInvitationsToFollow();
  }

  Widget get invitationsBanner {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      height: showInvitationsBanner ? null : 0,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          /// Invitation banner text
          if(showInvitationsBanner) CustomBodyText(invitationsBannerText),
          
          /// Open Button
          const CustomBodyText('Open', isLink: true,)

        ],
      ),
    );
  }

  Widget get invitationsModalBanner {
          
    if(userAssociation == UserAssociation.teamMember) {

      /// Modal Popup to show invitations to join team
      return TeamMemberInvitationsModalPopup(
        trigger: invitationsBanner,
      );

    }else{

      /// Modal Popup to show invitations to follow store
      return FollowerInvitationsModalBottomSheet(
        trigger: invitationsBanner,
      );

    }

  }

  void refreshStores() {

    /// Reset the invitations checker
    setState(() => checkStoreInvitations = null);

    /// Refresh the store invitations
    requestStoreInvitations();

    /// Refresh the store cards
    _customVerticalListViewInfiniteScrollState.currentState!.startRequest();

  }

  Widget get storeCards {
    return CustomVerticalListViewInfiniteScroll(
      showSeparater: false,
      debounceSearch: true,
      onParseItem: onParseItem,
      onRenderItem: onRenderItem,
      catchErrorMessage: 'Can\'t show stores',
      contentBeforeSearchBar: contentBeforeSearchBar,
      key: _customVerticalListViewInfiniteScrollState,
      onRequest: (page, searchWord) => requestShowStores(page, searchWord), 
      headerPadding: friendGroup == null ? const EdgeInsets.only(top: 8, bottom: 0, left: 16, right: 16) : EdgeInsets.zero,
    );
  }

  bool get scrolledToTop {

    return true;

    print(_customVerticalListViewInfiniteScrollState.currentState);

    if(_customVerticalListViewInfiniteScrollState.currentState == null ) return false;

    ScrollController controller = _customVerticalListViewInfiniteScrollState.currentState!.controller;
    
    /// If we have scrolled half-way through, then check if we can start loading more content
    return controller.offset > 100;

  }

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        
        /// Invitations Modal Banner
        if(friendGroup == null) invitationsModalBanner,
        
        /// Store cards
        Expanded(
          child: storeCards
        ),

      ],
    );
  }
}