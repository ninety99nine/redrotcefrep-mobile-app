import 'package:bonako_demo/features/authentication/providers/auth_provider.dart';
import 'package:bonako_demo/features/team_members/widgets/team_member_invitations_show/team_member_invitations_modal_bottom_sheet/team_member_invitations_modal_bottom_sheet.dart';
import 'package:bonako_demo/features/stores/models/check_store_invitations.dart';
import 'package:bonako_demo/core/shared_widgets/banners/custom_banner.dart';
import 'package:bonako_demo/features/stores/providers/store_provider.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:bonako_demo/core/utils/snackbar.dart';
import 'package:bonako_demo/core/utils/pusher.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class InvitationsToJoinStoreBanner extends StatefulWidget {

  final bool canShow;

  const InvitationsToJoinStoreBanner({
    Key? key,
    required this.canShow
  }) : super(key: key);

  @override
  State<InvitationsToJoinStoreBanner> createState() => InvitationsToJoinStoreBannerState();
}

class InvitationsToJoinStoreBannerState extends State<InvitationsToJoinStoreBanner> {

  late bool canShow;
  bool isLoading = false;
  int totalInvitations = 0;
  PusherChannelsFlutter? pusher;
  late PusherProvider pusherProvider;
  CheckStoreInvitations? checkStoreInvitations;
  bool get hasInvitations => totalInvitations > 0;
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  String get bannerText => 'You have been invited to join $totalInvitations ${totalInvitations == 1 ? 'store' : 'stores'}';

  void _startLoader() => setState(() => isLoading = true);
  void _stopLoader() => setState(() => isLoading = false);

  @override
  void initState() {
    super.initState();
    
    /// Set the Pusher Provider
    pusherProvider = Provider.of<PusherProvider>(context, listen: false);

    /// Set the parent canShow status as the initial canShow value
    canShow = widget.canShow;

    /// Request the store invitations
    requestStoreInvitations();

    /// Listen for new invitation alerts
    listenForNewInvitationAlerts();
  }

  @override
  void dispose() {
    super.dispose();
    /// Unsubscribe from this specified event on this channel
    pusherProvider.unsubscribeToAuthNotifications(identifier: 'InvitationsToJoinStoreBanner');
  }

  @override
  void didUpdateWidget(covariant InvitationsToJoinStoreBanner oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if the 'canShow' property of the current widget is different from the old widget
    if (canShow != oldWidget.canShow) {
      
      /// If there has been a change in 'canShow', update the widget's state
      /// This will show or hide the banner content based on the canShow updated state
      setState(() {
        if(hasInvitations) {
          canShow = oldWidget.canShow;
        }
      });

    }
  }

  void listenForNewInvitationAlerts() async {

    /// Subscribe to notification alerts
    pusherProvider.subscribeToAuthNotifications(
      identifier: 'InvitationsToJoinStoreBanner', 
      onEvent: onNotificationAlerts
    );
  
  }

  void onNotificationAlerts(event) {

    if (event.eventName == "Illuminate\\Notifications\\Events\\BroadcastNotificationCreated") {

      /// Parse event.data into a Map
      Map<String, dynamic> eventData = jsonDecode(event.data);

      //  Get the event type
      String type = eventData['type'];

      ///  Check if this is an invitation to join store team
      if(type == 'App\\Notifications\\Users\\InvitationToJoinStoreTeamCreated') {

        //// Increment the total invitations
        setTotalInvitations(totalInvitations + 1);
        
      }

    }

  }

  /// Check invitations
  void requestStoreInvitations() async {

    _startLoader();

    storeProvider.storeRepository.checkStoreInvitationsToJoinTeam().then((http.Response response) {

      if(!mounted) return response;

      if( response.statusCode == 200 ) {

        final responseBody = jsonDecode(response.body);
          
        checkStoreInvitations = CheckStoreInvitations.fromJson(responseBody);
    
        /// Set the total invitations
        setTotalInvitations(checkStoreInvitations!.totalInvitations);

      }

      return response;

    }).catchError((error) {

      /// Show the error message
      SnackbarUtility.showErrorMessage(message: 'Can\'t check invitations');

      return error;

    }).whenComplete(() {

      _stopLoader();
      
    });

  }

  void setTotalInvitations(totalInvitations) {
    if(this.totalInvitations != totalInvitations) {
      setState(() {
        this.totalInvitations = totalInvitations;
        canShow = hasInvitations;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return TeamMemberInvitationsModalBottomSheet(
      trigger: CustomBanner(
        text: bannerText,
        isLoading: isLoading,
        canShow: canShow && hasInvitations,
        onRefresh: requestStoreInvitations,
      ),
    );

  }
}