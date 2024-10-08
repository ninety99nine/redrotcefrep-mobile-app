import 'package:perfect_order/features/followers/widgets/follower_invitations_show/follower_invitations_modal_bottom_sheet/follower_invitations_modal_bottom_sheet.dart';
import 'package:perfect_order/features/authentication/providers/auth_provider.dart';
import 'package:perfect_order/features/stores/models/check_store_invitations.dart';
import 'package:perfect_order/core/shared_widgets/banners/custom_banner.dart';
import 'package:perfect_order/features/stores/providers/store_provider.dart';
import 'package:get/get.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:perfect_order/core/utils/snackbar.dart';
import 'package:perfect_order/core/utils/pusher.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'dart:convert';

class InvitationsToFollowStoreBanner extends StatefulWidget {

  final bool canShow;

  const InvitationsToFollowStoreBanner({
    Key? key,
    required this.canShow
  }) : super(key: key);

  @override
  State<InvitationsToFollowStoreBanner> createState() => InvitationsToFollowStoreBannerState();
}

class InvitationsToFollowStoreBannerState extends State<InvitationsToFollowStoreBanner> {

  late bool canShow;
  bool isLoading = false;
  int totalInvitations = 0;
  PusherChannelsFlutter? pusher;
  late PusherProvider pusherProvider;
  CheckStoreInvitations? checkStoreInvitations;
  bool get hasInvitations => totalInvitations > 0;
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  String get bannerText => 'You have been invited to follow $totalInvitations ${totalInvitations == 1 ? 'store' : 'stores'}';

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
    pusherProvider.unsubscribeToAuthNotifications(identifier: 'InvitationsToFollowStoreBanner');
  }

  @override
  void didUpdateWidget(covariant InvitationsToFollowStoreBanner oldWidget) {
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

    print('*************** listenForNewInvitationAlerts');

    /// Subscribe to notification alerts
    pusherProvider.subscribeToAuthNotifications(
      identifier: 'InvitationsToFollowStoreBanner', 
      onEvent: onNotificationAlerts
    );
  
  }

  void onNotificationAlerts(event) {

    print('*************** InvitationsToFollowStoreBanner: onNotificationAlerts');

    if (event.eventName == "Illuminate\\Notifications\\Events\\BroadcastNotificationCreated") {

      /// Parse event.data into a Map
      Map<String, dynamic> eventData = jsonDecode(event.data);

      //  Get the event type
      String type = eventData['type'];

      print('InvitationsToFollowStoreBanner type: $type');
      
      ///  Check if this is an invitation to follow store
      if(type == 'App\\Notifications\\Users\\InvitationToFollowStoreCreated') {

        print('InvitationsToFollowStoreBanner # invites before: $totalInvitations');

        //// Increment the total invitations
        setTotalInvitations(totalInvitations + 1);

        print('InvitationsToFollowStoreBanner # invites after: $totalInvitations');
        
      }

    }

  }

  /// Check invitations
  void requestStoreInvitations() async {

    _startLoader();

    storeProvider.storeRepository.checkStoreInvitationsToFollow().then((dio.Response response) {

      if(!mounted) return response;

      if( response.statusCode == 200 ) {
          
        checkStoreInvitations = CheckStoreInvitations.fromJson(response.data);
    
        /// Set the total invitations
        setTotalInvitations(checkStoreInvitations!.totalInvitations);

      }

      return response;

    }).catchError((error) {

      printError(info: error.toString());

      SnackbarUtility.showErrorMessage(message: 'Can\'t check invitations');

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

    return FollowerInvitationsModalBottomSheet(
      trigger: (openBottomModalSheet) => CustomBanner(
        text: bannerText,
        isLoading: isLoading,
        canShow: canShow && hasInvitations,
        onRefresh: requestStoreInvitations,
      ),
    );

  }
}