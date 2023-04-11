import '../../../../../core/shared_widgets/bottom_modal_sheet/custom_bottom_modal_sheet.dart';
import '../../../../../core/shared_widgets/button/custom_elevated_button.dart';
import '../team_member_invitations_in_vertical_list_view_infinite_scroll.dart';
import '../../../../../core/shared_widgets/text/custom_title_medium_text.dart';
import '../../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../../stores/providers/store_provider.dart';
import '../../../../../core/utils/dialog.dart';
import '../../../../../core/utils/snackbar.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

class TeamMemberInvitationsModalPopup extends StatefulWidget {
  
  final Widget trigger;

  const TeamMemberInvitationsModalPopup({
    super.key,
    required this.trigger,
  });

  @override
  State<TeamMemberInvitationsModalPopup> createState() => _TeamMemberInvitationsModalPopupState();
}

class _TeamMemberInvitationsModalPopupState extends State<TeamMemberInvitationsModalPopup> {

  bool respondedToAnyInvitation = false;

  Widget get trigger => widget.trigger;
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);

  void onClose() {
    if(respondedToAnyInvitation && storeProvider.refreshStores != null) storeProvider.refreshStores!();
  }

  void onRespondedToInvitation() => respondedToAnyInvitation = true;

  @override
  Widget build(BuildContext context) {
    return CustomBottomModalSheet(
      onClose: onClose,
      /// Trigger to open the bottom modal sheet
      trigger: trigger,
      /// Content of the bottom modal sheet
      content: ModalContent(
        onRespondedToInvitation: onRespondedToInvitation
      ),
    );
  }
}

class ModalContent extends StatefulWidget {
  
  final Function() onRespondedToInvitation;

  const ModalContent({
    super.key,
    required this.onRespondedToInvitation,
  });

  @override
  State<ModalContent> createState() => _ModalContentState();
}

class _ModalContentState extends State<ModalContent> {

  bool isLoading = false;
  bool isAcceptingAll = false;
  bool isDecliningAll = false;
  bool canShowFloatingActionButtons = false;

  void _startLoader() => setState(() => isLoading = true);
  void _stopLoader() => setState(() => isLoading = false);
  Function() get onRespondedToInvitation => widget.onRespondedToInvitation;
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);

  Widget get content {

    /// Show invitations view
    return TeamMemberInvitationsInVerticalListViewInfiniteScroll(
      onRequest: onRequest,
      isAcceptingAll: isAcceptingAll,
      isDecliningAll: isDecliningAll,
      onRespondedToInvitation: onRespondedToInvitation
    );
    
  }

  /// Especially on the first request of the scrollabled content,
  /// we wan to know whether or not to show the Accept All or
  /// Decline All buttons. The onRequest returns that request
  /// of the Scrollable content so that we can make this
  /// decision.
  onRequest(Future<http.Response> request) {
    request.then((response) {

      final Map responseBody = jsonDecode(response.body);
      final int total = responseBody['total'];

      /// Determine whether to show floating actions button or not
      setState(() => canShowFloatingActionButtons = total > 0);

    });
  }
    

  Widget floatingActionButtonWrapper(FloatingActionButton? widget) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 500),
      child: AnimatedSwitcher(
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        duration: const Duration(milliseconds: 500),
        child: widget
      )
    );
  }

  Widget get floatingActionButton {

    return Row(
      children: [

        /// Accept All
        CustomElevatedButton(
          width: 100,
          color: Colors.green,
          prefixIcon: Icons.check_circle,
          isAcceptingAll ? '' : 'Accept All',
          isLoading: isLoading && isAcceptingAll,
          onPressed: requestAcceptAllInvitationsToJoinTeam,
        ),

        /// Spacer
        const SizedBox(width: 4,),

        /// Decline All
        CustomElevatedButton(
          width: 100,
          color: Colors.red,
          prefixIcon: Icons.check_circle,
          isAcceptingAll ? '' : 'Decline All',
          isLoading: isLoading && isDecliningAll,
          onPressed: requestDeclineAllInvitationsToJoinTeam,
        ),

      ],
    );

  }

  void requestAcceptAllInvitationsToJoinTeam() async {
    
    if(isLoading) return;

    final bool? confirmation = await confirmAction('Are you sure you want to accept all invitations');

    /// If we can accept all
    if(confirmation == true) {

      isAcceptingAll = true;
      isDecliningAll = false;

      _startLoader();

      storeProvider.storeRepository.acceptAllInvitationsToJoinTeam()
      .then((response) {

        final responseBody = jsonDecode(response.body);

        if(response.statusCode == 200) {

          SnackbarUtility.showSuccessMessage(message: responseBody['message']);

          /// Notify the parent that user responded to the invitations
          onRespondedToInvitation();

          /// Close the modal
          Navigator.of(context).pop();
          
        }

      }).catchError((error) {

        SnackbarUtility.showErrorMessage(message: 'Failed to accept invitations');

      }).whenComplete((){

        _stopLoader();

      });

    }
  }

  void requestDeclineAllInvitationsToJoinTeam() async {
    
    if(isLoading) return;

    final bool? confirmation = await confirmAction('Are you sure you want to decline all invitations');

    /// If we can decline all
    if(confirmation == true) {

      isAcceptingAll = false;
      isDecliningAll = true;

      _startLoader();

      storeProvider.storeRepository.declineAllInvitationsToJoinTeam()
      .then((response) {

        final responseBody = jsonDecode(response.body);

        if(response.statusCode == 200) {

          SnackbarUtility.showSuccessMessage(message: responseBody['message']);

          /// Notify the parent that user responded to the invitations
          onRespondedToInvitation();
          
          /// Close the modal
          Navigator.of(context).pop();
          
        }

      }).catchError((error) {

        SnackbarUtility.showErrorMessage(message: 'Failed to decline invitations');

      }).whenComplete((){

        _stopLoader();

      });

    }
  }

  Future<bool?> confirmAction(String message) {
    return DialogUtility.showConfirmDialog(
      content: message,
      context: context
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
          
              AnimatedSize(
                duration: const Duration(milliseconds: 500),
                child: Padding(
                  padding: EdgeInsets.only(top:20, left: 32, bottom: canShowFloatingActionButtons ? 28 : 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                
                      /// Title
                      CustomTitleMediumText('Invitations', padding: EdgeInsets.only(bottom: 8),),
                      
                      /// Subtitle
                      CustomBodyText('Invitations to join stores'),
                      
                    ],
                  ),
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
  
          /// Cancel Icon
          Positioned(
            top: 8,
            right: 10,
            child: IconButton(
              icon: Icon(Icons.cancel, size: 28, color: Theme.of(context).primaryColor,),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
  
          /// Floating Button
          Positioned(
            top: 72,
            right: 10,
            child: AnimatedSwitcher(
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              duration: const Duration(milliseconds: 500),
              child: canShowFloatingActionButtons ? floatingActionButton : null,
            ),
          )
        ],
      ),
    );
  }
}