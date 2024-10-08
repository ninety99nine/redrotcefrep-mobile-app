import '../../../../core/shared_widgets/message_alert/custom_message_alert.dart';
import '../../../../core/shared_widgets/button/custom_elevated_button.dart';
import '../../../../core/shared_widgets/text/custom_title_medium_text.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../authentication/providers/auth_provider.dart';
import 'package:perfect_order/core/utils/error_utility.dart';
import '../../../../core/shared_models/permission.dart';
import '../../../stores/providers/store_provider.dart';
import '../../../stores/models/shoppable_store.dart';
import '../../../../core/shared_models/user.dart';
import '../../../../core/utils/snackbar.dart';
import '../../../../core/utils/dialog.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'team_permissions.dart';
import 'package:get/get.dart';

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
  bool isUpdating = false;
  bool isRemoving = false;
  List<Permission> selectedPermissions = [];

  void _startUpdateLoader() => setState(() => isUpdating = true);
  void _stopUpdateLoader() => setState(() => isUpdating = false);

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
  bool get canManageTeamMembers => store.attributes.userStoreAssociation!.canManageTeamMembers;
  String get permissionsError => serverErrors.containsKey('permissions') ? serverErrors['permissions'] : '';
  List<Permission> get teamMemberPermissions => teamMember.attributes.userStoreAssociation!.teamMemberPermissions;
  bool get teamMemberIsCreator => teamMember.attributes.userStoreAssociation!.teamMemberRole!.toLowerCase() == 'creator';
  
  String get removeTeamMemberFirstName {

    if(teamMember.attributes.userStoreAssociation!.mobileNumber == null) {
      return teamMember.firstName;
    }else{
      return teamMember.attributes.userStoreAssociation!.mobileNumber!.withoutExtension;
    }

  }

  String get removeTeamMemberName {

    if(teamMember.attributes.userStoreAssociation!.mobileNumber == null) {
      return teamMember.attributes.name;
    }else{
      return teamMember.attributes.userStoreAssociation!.mobileNumber!.withoutExtension;
    }

  }

  void _requestUpdateTeamMemberPermissions() {

    if(isUpdating) return;

    if(selectedPermissions.isNotEmpty) {

      _resetServerErrors();
      _startUpdateLoader();

      storeProvider.setStore(store).storeRepository.updateTeamMemberPermissions(
        permissions: selectedPermissions,
        teamMember: teamMember,
      ).then((response) async {

        if(response.statusCode == 200) {

          SnackbarUtility.showSuccessMessage(message: response.data['message']);
          
        }

      }).onError((dio.DioException exception, stackTrace) {

        ErrorUtility.setServerValidationErrors(setState, serverErrors, exception);

      }).catchError((error) {

        printError(info: error.toString());

        SnackbarUtility.showErrorMessage(message: 'Failed to update permissions');

      }).whenComplete(() {

        _stopUpdateLoader();

      });

    }else{

      SnackbarUtility.showErrorMessage(message: 'Select permissions for your team member');

    }
  }

  void _requestRemoveTeamMember() async {

    if(isRemoving) return;

    final bool? confirmation = await confirmRemove();

    /// If we can remove
    if(confirmation == true) {

      _resetServerErrors();
      _startRemoveLoader();

      storeProvider.setStore(store).storeRepository.removeTeamMembers(
        teamMembers: [teamMember],
      ).then((response) async {

        if(response.statusCode == 200) {

          SnackbarUtility.showSuccessMessage(message: response.data['message']);
          
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
          store: store,
          onTogglePermissions: onTogglePermissions,
          teamMemberPermissions: teamMemberPermissions,
          disabled: isUpdating || teamMemberIsYou || teamMemberIsCreator || cannotManageTeamMembers,
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
          disabled: isRemoving,
          isLoading: isUpdating,
          alignment: Alignment.center,
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
              const CustomTitleMediumText('Remove', margin: EdgeInsets.only(bottom: 4),),

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
                isError: true,
                'Remove Team Member',
                isLoading: isRemoving,
                alignment: Alignment.center,
                onPressed: _requestRemoveTeamMember,
                disabled: teamMemberIsYou || teamMemberIsCreator || cannotManageTeamMembers || isUpdating,
              ),

            ],
          ),
        ),
      ],
    );
  }
}