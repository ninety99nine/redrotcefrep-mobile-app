import '../../../../core/shared_widgets/buttons/custom_elevated_button.dart';
import '../../../../core/shared_widgets/text/custom_title_medium_text.dart';
import '../follower_invitations_show/follower_invitations_content.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import '../follower_send_invitation/follower_send_invitation.dart';
import 'followers_in_vertical_list_view_infinite_scroll.dart';
import '../../../stores/providers/store_provider.dart';
import '../../../stores/models/shoppable_store.dart';
import '../../models/followers_invitations.dart';
import 'followers_page/followers_page.dart';
import '../../enums/follower_enums.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'follower_filters.dart';

class FollowersContent extends StatefulWidget {
  
  final ShoppableStore store;
  final bool showingFullPage;

  const FollowersContent({
    super.key,
    required this.store,
    this.showingFullPage = false
  });

  @override
  State<FollowersContent> createState() => _FollowersContentState();
}

class _FollowersContentState extends State<FollowersContent> {

  String followerFilter = 'Following';
  bool disableFloatingActionButton = false;
  FollowersInvitations? followersInvitations;
  FollowerContentView followerContentView = FollowerContentView.viewingFollowers;

  ShoppableStore get store => widget.store;
  double get topPadding => showingFullPage ? 32 : 0;
  bool get showingFullPage => widget.showingFullPage;
  bool get isInviting => followerContentView == FollowerContentView.inviting;
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  bool get isViewingFollowers => followerContentView == FollowerContentView.viewingFollowers;
  bool get isViewingInvitations => followerContentView == FollowerContentView.viewingInvitations;
  String get subtitle {
    final bool following = followerFilter.toLowerCase() == 'following';
    final bool unFollowed = followerFilter.toLowerCase() == 'unfollowed';
    final bool invited = followerFilter.toLowerCase() == 'invited';
    
    if(isViewingFollowers && following) {
      return 'See when followers last stopped by';
    }else if(isViewingFollowers && unFollowed) {
      return 'See when past followers last stopped by';
    }else if(isViewingFollowers && invited) {
      return 'See when others were invited to be followers';
    }else if(isViewingInvitations) {
      return 'Check out your invitation list';
    }else{
      return 'Invite your friend to our store';
    }
  }

  /// Content to show based on the specified view
  Widget get content {

    /// If we want to view the followers content
    if(isViewingFollowers) {

      /// Show followers view
      return FollowersInVerticalListViewInfiniteScroll(
        store: store,
        followerFilter: followerFilter
      );

    /// If we want to view the follower send invitation content
    }else if(isInviting) {

      /// Show the follower send invitation view
      return FollowerSendInvitation(
        store: store,
        onLoading: onLoadingInvite,
        onInviteFollowers: onInviteFollowers,
      );

    }else{

      /// Show followers view
      return FollowerInvitationsContent(
        followersInvitations: followersInvitations!
      );

    }
    
  }

  /// Floating action button widget
  Widget get floatingActionButton {

    return CustomElevatedButton(
      width: 120,
      onPressed: floatingActionButtonOnPressed,
      isViewingFollowers ? 'Invite Friends' : 'Back',
      color: isViewingFollowers ? Colors.green : Colors.grey,
      prefixIcon: isViewingFollowers ? Icons.add : Icons.keyboard_double_arrow_left,
    );

  }

  /// Action to be called when the floating action button is pressed
  void floatingActionButtonOnPressed() {

    /// If we should disable the floating action button, then do nothing
    if(disableFloatingActionButton) return; 

    /// If we are viewing the followers content
    if(isViewingFollowers) {

      /// Change to the invite follower view
      changeFollowerContentView(FollowerContentView.inviting);

    /// If we are viewing the follower invitations content
    }else if(isViewingInvitations) {

      /// Set the follower filter to "Invited"
      onSelectedFollowerFilter('Invited');

      /// Change to the show followers view
      changeFollowerContentView(FollowerContentView.viewingFollowers);

    }else{

      /// Change to the show followers view
      changeFollowerContentView(FollowerContentView.viewingFollowers);

    }

  }

  /// While inviting users disable the floating action 
  /// button so that it is no longer performs any
  /// actions when clicked
  void onLoadingInvite(bool status) => disableFloatingActionButton = status;

  /// Called so that we can show the followers invitations view after
  /// inviting one or many users to join the store as followers
  void onInviteFollowers(FollowersInvitations followersInvitations) {
    this.followersInvitations = followersInvitations;
    changeFollowerContentView(FollowerContentView.viewingInvitations);
  }

  /// Called when the order filter has been changed,
  /// such as changing from "Joined" to "Left"
  void onSelectedFollowerFilter(String followerFilter) {
    setState(() => this.followerFilter = followerFilter);
  }

  /// Called to change the view to the specified view
  void changeFollowerContentView(FollowerContentView followerContentView) {
    setState(() => this.followerContentView = followerContentView);
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
              key: ValueKey(followerContentView.name),
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
                    children: [
                
                      /// Title
                      const CustomTitleMediumText('Followers', padding: EdgeInsets.only(bottom: 8),),
                      
                      /// Subtitle
                      AnimatedSwitcher(
                        switchInCurve: Curves.easeIn,
                        switchOutCurve: Curves.easeOut,
                        duration: const Duration(milliseconds: 500),
                        child: Align(
                          key: ValueKey(subtitle),
                          alignment: Alignment.centerLeft,
                          child: CustomBodyText(subtitle),
                        )
                      ),
                  
                      //  Filter
                      if(isViewingFollowers) FollowerFilters(
                        store: store,
                        followerFilter: followerFilter,
                        onSelectedFollowerFilter: onSelectedFollowerFilter,
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

                /// Set the store
                storeProvider.setStore(store);
                
                /// Navigate to the page
                Navigator.of(context).pushNamed(FollowersPage.routeName);
              
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
  
          /// Floating Button (show if provided)
          AnimatedPositioned(
            right: 10,
            duration: const Duration(milliseconds: 500),
            top: (isViewingFollowers ? 112 : 60) + topPadding,
            child: floatingActionButton,
          )
        ],
      ),
    );
  }
}