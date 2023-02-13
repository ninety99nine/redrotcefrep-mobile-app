import '../../../../core/shared_widgets/multiple_mobile_number_form/custom_multiple_mobile_number_form.dart';
import '../../../../core/shared_models/permission.dart';
import '../../../stores/providers/store_provider.dart';
import '../../../stores/models/shoppable_store.dart';
import '../team_member_show/team_permissions.dart';
import '../../models/team_members_invitations.dart';
import '../../../../core/utils/snackbar.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class TeamMemberSendInvitation extends StatefulWidget {
  
  final ShoppableStore store;
  final void Function(bool) onLoading;
  final void Function(TeamMembersInvitations) onInviteTeamMembers;

  const TeamMemberSendInvitation({
    super.key,
    required this.store,
    required this.onLoading,
    required this.onInviteTeamMembers,
  });

  @override
  State<TeamMemberSendInvitation> createState() => _TeamMemberSendInvitationState();
}

class _TeamMemberSendInvitationState extends State<TeamMemberSendInvitation> {
  
  ShoppableStore get store => widget.store;
  List<Permission> selectedPermissions = [];
  TeamMembersInvitations? teamMembersInvitations;

  void Function(bool) get onLoading => widget.onLoading;
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  void Function(TeamMembersInvitations) get onInviteTeamMembers => widget.onInviteTeamMembers;

  /// Request to invite team members
  Future<http.Response> _requestInviteTeamMembers(List<String> mobileNumbers) {

    return storeProvider.setStore(store).storeRepository.inviteTeamMembers(
      permissions: selectedPermissions,
      mobileNumbers: mobileNumbers,
      context: context,
    ).then((response) async {

      final responseBody = jsonDecode(response.body);

      if(response.statusCode == 200) {

        SnackbarUtility.showSuccessMessage(message: responseBody['message'], duration: 4, context: context);

        teamMembersInvitations = TeamMembersInvitations.fromJson(responseBody['invitations']);

        onInviteTeamMembers(teamMembersInvitations!);

      }

      return response;

    }).catchError((error) {

      SnackbarUtility.showErrorMessage(message: 'Failed to invite friends', context: context);

    });

  }

  /// Validate permissions before making a request
  bool onValidate() {
    if(selectedPermissions.isEmpty) SnackbarUtility.showErrorMessage(message: 'Select permissions for your team', context: context);
    return selectedPermissions.isNotEmpty;
  }

  /// Set selected permissions
  void onTogglePermissions(List<Permission> selectedPermissions) {
    this.selectedPermissions = selectedPermissions;
  }

  /// Return permissions as content to show after the mobile number fields
  Widget contentAfterMobileNumbers(bool isLoading) {

    /// Permissions
    return TeamPermissions(
      disabled: isLoading,
      onTogglePermissions: onTogglePermissions
    );

  }

  @override
  Widget build(BuildContext context) {
    return CustomMultipleMobileNumberForm(
      instruction: 'you would like to invite to join this store',
      contentAfterMobileNumbers: contentAfterMobileNumbers,
      onRequest: _requestInviteTeamMembers,
      onValidate: onValidate,
      onLoading: onLoading
    );
  }
}