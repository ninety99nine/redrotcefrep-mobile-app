import '../../../user/widgets/team_member_profile/team_member_profile_avatar.dart';
import '../team_member_invitations_show/team_member_invitations_content.dart';
import '../../../../core/shared_widgets/buttons/custom_elevated_button.dart';
import '../../../../core/shared_widgets/text/custom_title_large_text.dart';
import '../team_member_send_invitation/team_member_send_invitation.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import 'team_members_in_vertical_list_view_infinite_scroll.dart';
import '../../../stores/providers/store_provider.dart';
import '../team_member_show/team_member_content.dart';
import '../../../stores/services/store_services.dart';
import '../../../stores/models/shoppable_store.dart';
import '../../models/team_members_invitations.dart';
import 'team_members_page/team_members_page.dart';
import '../../../../core/shared_models/user.dart';
import '../../enums/team_member_enums.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'team_member_filters.dart';

class TeamMembersContent extends StatefulWidget {
  
  final ShoppableStore store;
  final bool showingFullPage;

  const TeamMembersContent({
    super.key,
    required this.store,
    this.showingFullPage = false,
  });

  @override
  State<TeamMembersContent> createState() => _TeamMembersContentState();
}

class _TeamMembersContentState extends State<TeamMembersContent> {

  User? teamMember;
  String teamMemberFilter = 'Joined';
  bool disableFloatingActionButton = false;
  TeamMembersInvitations? teamMembersInvitations;
  TeamMemberContentView teamMemberContentView = TeamMemberContentView.viewingTeamMembers;
  
  /// This allows us to access the state of TeamMemberFilters widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  GlobalKey<TeamMemberFiltersState>? _teamMemberFiltersState;

  ShoppableStore get store => widget.store;
  double get topPadding => showingFullPage ? 32 : 0;
  bool get showingFullPage => widget.showingFullPage;
  String get title => isViewingInvitations ? 'Invitations' : 'Team Members';
  bool get isInviting => teamMemberContentView == TeamMemberContentView.inviting;
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  bool get canManageTeamMembers => StoreServices.hasPermissionsToManageTeamMembers(store);
  bool get isViewingTeamMember => teamMemberContentView == TeamMemberContentView.viewingTeamMember;
  bool get isViewingTeamMembers => teamMemberContentView == TeamMemberContentView.viewingTeamMembers;
  bool get isViewingInvitations => teamMemberContentView == TeamMemberContentView.viewingInvitations;

  String get subtitle {
    final bool leftTeam = teamMemberFilter.toLowerCase() == 'left';
    final bool joinedTeam = teamMemberFilter.toLowerCase() == 'joined';
    final bool invitedToJoinTeam = teamMemberFilter.toLowerCase() == 'invited';

    if(isViewingTeamMembers && joinedTeam) {
      return 'See when team members last stopped by';
    }else if(isViewingTeamMembers && leftTeam) {
      return 'See when past team members last stopped by';
    }else if(isViewingTeamMembers && invitedToJoinTeam) {
      return 'See when others were invited to be team members';
    }else if(isViewingInvitations) {
      return 'Check out your invitation list';
    }else{
      return 'Invite a friend to join store';
    }
  }

  @override
  void initState() {

    super.initState();

    /// If this user has permissions to manage team members
    /// then default to set the filter equal to "All" so 
    /// that we can show all team members
    if(canManageTeamMembers) teamMemberFilter = 'All';

    /// Set the "_teamMemberFiltersState" so that we can access the TeamMemberFilters widget state
    _teamMemberFiltersState = GlobalKey<TeamMemberFiltersState>();

  }

  /// Content to show based on the specified view
  Widget get content {

    /// If we want to view the team members content
    if(isViewingTeamMembers) {

      /// Show team members view
      return TeamMembersInVerticalListViewInfiniteScroll(
        store: store,
        teamMemberFilter: teamMemberFilter,
        onViewTeamMember: onViewTeamMember,
        onRemovedTeamMembers: onRemovedTeamMembers,
        onRemovingTeamMembers: onRemovingTeamMembers,
      );

    /// If we want to view the team member content
    }else if(isViewingTeamMember) {

      /// Show the invite team member view
      return TeamMemberContent(
        store: store,
        teamMember: teamMember!,
        onRemovedTeamMember: onRemovedTeamMember,
      );

    /// If we want to view the team member send invitation content
    }else if(isInviting) {

      /// Show the team member send invitation view
      return TeamMemberSendInvitation(
        store: store,
        onLoading: onLoadingInvite,
        onInviteTeamMembers: onInviteTeamMembers,
      );

    /// If we want to view the team member invitations content
    }else{

      /// Show team member invitations view
      return TeamMemberInvitationsContent(
        teamMembersInvitations: teamMembersInvitations!
      );

    }
    
  }

  /// Floating action button widget
  Widget get floatingActionButton {

    return CustomElevatedButton(
      width: 120,
      onPressed: floatingActionButtonOnPressed,
      isViewingTeamMembers ? 'Invite Team' : 'Back',
      color: isViewingTeamMembers ? Colors.green : Colors.grey,
      prefixIcon: isViewingTeamMembers ? Icons.add : Icons.keyboard_double_arrow_left,
    );

  }

  /// Action to be called when the floacting action button is pressed
  void floatingActionButtonOnPressed() {

    /// If we should disable the floating action button, then do nothing
    if(disableFloatingActionButton) return; 

    /// If we are viewing the team members content
    if(isViewingTeamMembers) {

      /// Change to the invite team member view
      changeTeamMemberContentView(TeamMemberContentView.inviting);

    /// If we are viewing the team member invitations content
    }else if(isViewingInvitations) {

      /// Set the team member filter to "Invited"
      onSelectedTeamMemberFilter('Invited');

      /// Change to the show team members view
      changeTeamMemberContentView(TeamMemberContentView.viewingTeamMembers);

    }else{
      
      /// Unset the team member
      teamMember = null;

      /// Change to the show team members view
      changeTeamMemberContentView(TeamMemberContentView.viewingTeamMembers);

    }

  }

  /// While inviting users disable the floating action 
  /// button so that it is no longer performs any
  /// actions when clicked
  void onLoadingInvite(bool status) => disableFloatingActionButton = status;

  /// Called so that we can show the team members invitations view after
  /// inviting one or many users to join the store as team members
  void onInviteTeamMembers(TeamMembersInvitations teamMembersInvitations) {
    this.teamMembersInvitations = teamMembersInvitations;
    changeTeamMemberContentView(TeamMemberContentView.viewingInvitations);
  }

  /// While removing team members disable the floating action 
  /// button so that it is no longer performs any actions
  /// when clicked
  void onRemovingTeamMembers(bool status) => disableFloatingActionButton = status;

  /// Called after removing a single team member so that we can
  /// update the filters with the latest totals of each filter
  void onRemovedTeamMember() {
    teamMember = null;
    changeTeamMemberContentView(TeamMemberContentView.viewingTeamMembers);
  }

  /// Called after removing multiple team members so that we can
  /// update the filters with the latest totals of each filter
  void onRemovedTeamMembers() {
    _teamMemberFiltersState!.currentState!.requestStoreTeamMemberFilters();
  }

  /// Called to change the view from viewing multiple team members
  /// to viewing one specific team member
  void onViewTeamMember(User teamMember) {
    this.teamMember = teamMember;
    changeTeamMemberContentView(TeamMemberContentView.viewingTeamMember);
  }

  /// Called when the order filter has been changed,
  /// such as changing from "Joined" to "Left"
  void onSelectedTeamMemberFilter(String teamMemberFilter) {
    setState(() => this.teamMemberFilter = teamMemberFilter);
  }

  /// Called to change the view to the specified view
  void changeTeamMemberContentView(TeamMemberContentView teamMemberContentView) {
    setState(() => this.teamMemberContentView = teamMemberContentView);
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
              key: ValueKey(teamMemberContentView.name),
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                
                /// Wrap Padding around the following:
                /// Title, Subtitle, Team Member Profile Avatar, Filters
                Padding(
                  padding: EdgeInsets.only(top: 20 + topPadding, left: (teamMember == null ? 32 : 16), bottom: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      if(teamMember == null) ...[
                
                        /// Title
                        CustomTitleLargeText(title, padding: const EdgeInsets.only(bottom: 8),),
                        
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

                      ],

                      /// Team Member Profile Avatar
                      if(teamMember != null) TeamMemberProfileAvatar(user: teamMember!),
                  
                      //  Filter
                      if(isViewingTeamMembers && canManageTeamMembers) TeamMemberFilters(
                        store: store,
                        key: _teamMemberFiltersState,
                        teamMemberFilter: teamMemberFilter,
                        onSelectedTeamMemberFilter: onSelectedTeamMemberFilter,
                      )
                      
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
                Navigator.of(context).pushNamed(TeamMembersPage.routeName);
              
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
  
          /// Floating Button (show when we can manage team members)
          if(canManageTeamMembers) AnimatedPositioned(
            right: 10,
            duration: const Duration(milliseconds: 500),
            top: (isViewingTeamMembers ? 116 : (isViewingTeamMember ? 72 : 60)) + topPadding,
            child: floatingActionButton
          )
        ],
      ),
    );
  }
}