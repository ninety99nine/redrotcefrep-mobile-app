import 'package:bonako_demo/features/followers/widgets/follower_invitations_show/follower_invitations_modal_bottom_sheet/follower_invitations_modal_bottom_sheet.dart';
import 'package:bonako_demo/features/stores/models/check_store_invitations.dart';
import 'package:bonako_demo/core/shared_widgets/banners/custom_banner.dart';
import 'package:bonako_demo/features/stores/providers/store_provider.dart';
import 'package:bonako_demo/core/utils/snackbar.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
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
  String? bannerText;
  bool isLoading = false;
  CheckStoreInvitations? checkStoreInvitations;
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);

  void _startLoader() => setState(() => isLoading = true);
  void _stopLoader() => setState(() => isLoading = false);

  @override
  void initState() {
    super.initState();

    /// Set the parent canShow status as the initial canShow value
    canShow = widget.canShow;

    /// Request the store invitations
    requestStoreInvitations();
  }

  @override
  void didUpdateWidget(covariant InvitationsToFollowStoreBanner oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if the 'canShow' property of the current widget is different from the old widget
    if (canShow != oldWidget.canShow) {
      
      /// If there has been a change in 'canShow', update the widget's state
      /// This will hide or show the banner content based on the canShow 
      /// updated state
      setState(() => canShow = oldWidget.canShow);

    }

    /// If the banner text has not been set and we are not loading
    if(bannerText == null && !isLoading) {

      /// Request the store invitations again
      if(bannerText == null) requestStoreInvitations();

    }
  }


  /// Check invitations
  void requestStoreInvitations() async {

    _startLoader();

    storeProvider.storeRepository.checkStoreInvitationsToFollow().then((http.Response response) {

      if(!mounted) return response;

      if( response.statusCode == 200 ) {

        final responseBody = jsonDecode(response.body);
        
        setState(() {
          
          checkStoreInvitations = CheckStoreInvitations.fromJson(responseBody);

          if(checkStoreInvitations!.totalInvitations > 0) {

            bannerText = 'You have been invited to follow ${checkStoreInvitations!.totalInvitations} ${checkStoreInvitations!.totalInvitations == 1 ? 'store' : 'stores'}';

          }else{
      
            /// Hide the banner content since we don't have any content to show
            setState(() {

              bannerText = null;
              canShow = false;

            });

          }

        });


      }

      return response;

    }).catchError((error) {

      /// Show the error message
      SnackbarUtility.showErrorMessage(message: 'Can\'t check invitations');

    }).whenComplete(() {

      _stopLoader();
      
    });

  }

  @override
  Widget build(BuildContext context) {

    return FollowerInvitationsModalBottomSheet(
      trigger: CustomBanner(
        text: bannerText,
        canShow: canShow,
        isLoading: isLoading,
        onRefresh: requestStoreInvitations,
      ),
    );

  }
}