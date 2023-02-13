import '../../../../core/shared_widgets/message_alerts/custom_message_alert.dart';
import '../../../../core/shared_widgets/buttons/custom_elevated_button.dart';
import '../../../../core/shared_widgets/text/custom_title_large_text.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../authentication/providers/auth_provider.dart';
import '../../../../core/shared_models/permission.dart';
import '../../../stores/providers/store_provider.dart';
import '../../../stores/services/store_services.dart';
import '../../../stores/models/shoppable_store.dart';
import '../../../../core/shared_models/user.dart';
import '../../../../core/utils/snackbar.dart';
import '../../../../core/utils/dialog.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'team_permissions.dart';
import 'dart:convert';

class TeamMemberContent extends StatefulWidget {
  
  final User teamMember;
  final ShoppableStore store;
  final Function onRemovedTeamMember;

  const TeamMemberContent({
    super.key,
    required this.store,
    required this.teamMember,
    required this.onRemovedTeamMember,
  });

  @override
  State<TeamMemberContent> createState() => _TeamMemberContentState();
}

class _TeamMemberContentState extends State<TeamMemberContent> {

  ShoppableStore get store => widget.store;
  User get teamMember => widget.teamMember;
  Function get onRemovedTeamMember => widget.onRemovedTeamMember;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0,),
        child: Column(
          children: [

            /// Permissions
            Permissions(
              store: store,
              teamMember: teamMember,
              onRemovedTeamMember: onRemovedTeamMember,
            ),

            /// Spacer
            const SizedBox(height: 100)

          ],
        ),
      ),
    );
  }
}

class Permissions extends StatefulWidget {

  final User teamMember;
  final ShoppableStore store;
  final Function onRemovedTeamMember;

  const Permissions({
    super.key,
    required this.store,
    required this.teamMember,
    required this.onRemovedTeamMember,
  });

  @override
  State<Permissions> createState() => _PermissionsState();
}

class _PermissionsState extends State<Permissions> {

  Map serverErrors = {};
  bool isLoading = false;
  bool isRemoving = false;
  List<Permission> selectedPermissions = [];

  void _startLoader() => setState(() => isLoading = true);
  void _stopLoader() => setState(() => isLoading = false);

  void _startRemoveLoader() => setState(() => isRemoving = true);
  void _stopRemoveLoader() => setState(() => isRemoving = false);
  
  User get teamMember => widget.teamMember;
  ShoppableStore get store => widget.store;
  bool get teamMemberIsNotYou => !teamMemberIsYou;
  bool get teamMemberIsNotCreator => !teamMemberIsCreator;
  bool get cannotManageTeamMembers => !canManageTeamMembers;
  Function get onRemovedTeamMember => widget.onRemovedTeamMember;
  bool get teamMemberIsYou => teamMember.id == authProvider.user!.id;
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  bool get canManageTeamMembers => StoreServices.hasPermissionsToManageTeamMembers(store);
  String get permissionsError => serverErrors.containsKey('permissions') ? serverErrors['permissions'] : '';
  List<Permission> get teamMemberPermissions => teamMember.attributes.userAssociationAsTeamMember!.permissions;
  bool get teamMemberIsCreator => teamMember.attributes.userAssociationAsTeamMember!.role.toLowerCase() == 'creator';
  
  String get removeTeamMemberFirstName {

    if(teamMember.attributes.userAssociationAsTeamMember!.mobileNumber == null) {
      return teamMember.firstName;
    }else{
      return teamMember.attributes.userAssociationAsTeamMember!.mobileNumber!.withoutExtension;
    }

  }

  String get removeTeamMemberName {

    if(teamMember.attributes.userAssociationAsTeamMember!.mobileNumber == null) {
      return teamMember.attributes.name;
    }else{
      return teamMember.attributes.userAssociationAsTeamMember!.mobileNumber!.withoutExtension;
    }

  }

  void _requestUpdateTeamMemberPermissions() {

    if(selectedPermissions.isNotEmpty) {

      _resetServerErrors();
      _startLoader();

      storeProvider.setStore(store).storeRepository.updateTeamMemberPermissions(
        permissions: selectedPermissions,
        teamMember: teamMember,
        context: context,
      ).then((response) async {

        final responseBody = jsonDecode(response.body);

        if(response.statusCode == 200) {

          SnackbarUtility.showSuccessMessage(message: responseBody['message'], context: context);
          
        }else if(response.statusCode == 422) {

          handleServerValidation(responseBody['errors']);
          
        }

      }).catchError((error) {

        SnackbarUtility.showErrorMessage(message: 'Failed to update permissions', context: context);

      }).whenComplete((){

        _stopLoader();

      });


    }else{

      SnackbarUtility.showErrorMessage(message: 'Select permissions for your team member', context: context);

    }
  }

  void _requestRemoveTeamMember() async {

    final bool? confirmation = await confirmRemove();

    /// If we can remove
    if(confirmation == true) {

      _resetServerErrors();
      _startRemoveLoader();

      storeProvider.setStore(store).storeRepository.removeTeamMembers(
        teamMembers: [teamMember],
        context: context,
      ).then((response) async {

        final responseBody = jsonDecode(response.body);

        if(response.statusCode == 200) {

          SnackbarUtility.showSuccessMessage(message: responseBody['message'], context: context);
          
          //  Notify the parent on team member being removed
          onRemovedTeamMember();

        }

      }).whenComplete((){

        _stopRemoveLoader();

      });

    }

  }

  Future<bool?> confirmRemove() {
    return DialogUtility.showConfirmDialog(
      content: 'Are you sure you want to remove $removeTeamMemberFirstName?',
      context: context
    );
  }

  void handleServerValidation(Map errors) {

    /**
     *  errors = {
     *    mobileNumbers0: [The mobile number must start with one of the following: 267.]
     * }
     */
    setState(() {
      errors.forEach((key, value) {
        serverErrors[key] = value[0];
      });
    });

  }

  void _resetServerErrors() {
    setState(() => serverErrors = {});
  }

  void onTogglePermissions(List<Permission> selectedPermissions) {
    _resetServerErrors();
    this.selectedPermissions = selectedPermissions;
  }

  Widget get cannotModifyPermissionsInformation {
    return Column(
      children: [

        /// Spacer
        const SizedBox(height: 8),

        /// If this is the current user's profile
        if(teamMemberIsYou) const CustomMessageAlert(
          type: AlertMessageType.warning,
          'You cannot change your own permissions'
        ),
        
        /// If this is a creator
        if(teamMemberIsNotYou && teamMemberIsCreator) const CustomMessageAlert(
          type: AlertMessageType.warning,
          'You cannot modify the creators permissions'
        ),

        /// If this is not you or a creator but you do not have permissions
        if(teamMemberIsNotYou && teamMemberIsNotCreator && cannotManageTeamMembers) const CustomMessageAlert(
          type: AlertMessageType.warning,
          'You do not have the permissions to make changes on this team member'
        ),

        /// Spacer
        if(teamMemberIsYou || teamMemberIsCreator || cannotManageTeamMembers) const SizedBox(height: 16),
      
      ],
    );
  }

  Widget get cannotRemoveInformation {
    return Column(
      children: [

        /// Spacer
        const SizedBox(height: 8),

        /// If this is the current user's profile
        if(teamMemberIsYou) const CustomMessageAlert(
          type: AlertMessageType.warning,
          'You cannot remove yourself'
        ),
        
        /// If this is a creator
        if(teamMemberIsNotYou && teamMemberIsCreator) const CustomMessageAlert(
          type: AlertMessageType.warning,
          'You cannot remove the creator'
        ),

        /// If this is not you or a creator but you do not have permissions
        if(teamMemberIsNotYou && teamMemberIsNotCreator && cannotManageTeamMembers) const CustomMessageAlert(
          type: AlertMessageType.warning,
          'You do not have the permissions to remove this team member'
        ),

        /// Spacer
        if(teamMemberIsYou || teamMemberIsCreator || cannotManageTeamMembers) const SizedBox(height: 16),
      
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        /// Cannot Modify Creator permissions
        cannotModifyPermissionsInformation,

        /// Team Member Permissions
        TeamPermissions(
          onTogglePermissions: onTogglePermissions,
          teamMemberPermissions: teamMemberPermissions,
          disabled: isLoading || teamMemberIsYou || teamMemberIsCreator || cannotManageTeamMembers,
        ),

        /// Permissions Server Error
        if(permissionsError.isNotEmpty) CustomBodyText(
          isError: true,
          permissionsError, 
          margin: const EdgeInsets.only(top: 20)
        ),

        /// Spacer
        const SizedBox(height: 16),
        
        /// Save Changes Button
        if(teamMemberIsNotCreator && canManageTeamMembers) CustomElevatedButton(
          'Save Changes',
          isLoading: isLoading,
          alignment: Alignment.center,
          disabled: isLoading || isRemoving,
          onPressed: _requestUpdateTeamMemberPermissions,
        ),

        const Divider(height: 32),

        /// Cannot Delete
        cannotRemoveInformation,

        Container(
          padding: const EdgeInsets.all(16),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.red.shade50
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              /// Title
              const CustomTitleLargeText('Remove', margin: EdgeInsets.only(bottom: 4),),

              /// Divider
              const Divider(),
              
              /// Remove Team Member Instructions
              RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.normal,
                    height: 1.4
                  ),
                  text: 'Remove ',
                  children: [
                    TextSpan(text: removeTeamMemberName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const TextSpan(text: ' from being a team member of '),
                    TextSpan(text: store.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const TextSpan(text: '. Once this team member is removed, '),
                    TextSpan(text: removeTeamMemberFirstName),
                    const TextSpan(text: ' will not have access to this store (even with an active subscription) unless invited again'),
                  ]
                ),
              ),

              /// Spacer
              const SizedBox(height: 8,),

              /// Remove Button
              CustomElevatedButton(
                width: 180,
                'Remove Team Member',
                isError: true,
                isLoading: isRemoving,
                alignment: Alignment.center,
                onPressed: _requestRemoveTeamMember,
                disabled: teamMemberIsYou || teamMemberIsCreator || cannotManageTeamMembers || isLoading || isRemoving,
              ),

            ],
          ),
        ),
      ],
    );
  }
}