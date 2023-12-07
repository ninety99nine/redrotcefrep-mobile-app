import '../../../../core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import '../../../../core/shared_widgets/text/custom_title_medium_text.dart';
import '../../../../core/shared_widgets/text/custom_title_small_text.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import '../../../../core/shared_widgets/checkbox/custom_checkbox.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../../core/shared_models/permission.dart';
import '../../../stores/providers/store_provider.dart';
import '../../../../core/utils/snackbar.dart';
import 'package:collection/collection.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TeamPermissions extends StatefulWidget {
  
  final bool disabled;
  final ShoppableStore store;
  final List<Permission> teamMemberPermissions;
  final void Function(List<Permission>) onTogglePermissions;

  const TeamPermissions({
    super.key,
    required this.store,
    this.disabled = false,
    required this.onTogglePermissions,
    this.teamMemberPermissions = const [],
  });

  @override
  State<TeamPermissions> createState() => _TeamPermissionstate();
}

class _TeamPermissionstate extends State<TeamPermissions> {
  
  bool isUpdating = false;
  bool selectedAll = false;
  List<Permission> permissions = [];
  List<Permission> selectedPermissions = [];

  bool get disabled => widget.disabled;
  ShoppableStore get store => widget.store;
  bool get hasTeamMemberPermissions => teamMemberPermissions.isNotEmpty;
  List<Permission> get teamMemberPermissions => widget.teamMemberPermissions;
  void Function(List<Permission>) get onTogglePermissions => widget.onTogglePermissions;
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  String get subtitle => hasTeamMemberPermissions ? 'Change team member permissions' : 'Select permissions for your team';

  void _startUpdateLoader() => setState(() => isUpdating = true);
  void _stopUpdateLoader() => setState(() => isUpdating = false);

  @override
  void initState() {
    super.initState();
    _requestShowAllTeamPermissions();
  }

  /// Request the show all team permissions
  void _requestShowAllTeamPermissions() {

    if(isUpdating) return;

    _startUpdateLoader();

    storeProvider.setStore(store).storeRepository.showAllTeamMemberPermissions()
    .then((response) async {

      if(response.statusCode == 200) {

        setState(() {
          permissions = (response.data as List).map((permission) {
            return Permission.fromJson(permission);
          }).toList();
        });

        _selectSpecifiedPermissions(teamMemberPermissions);

      }

    }).catchError((error) {

      printError(info: error.toString());

      /// Show the error message
      SnackbarUtility.showErrorMessage(message: 'Failed to show team permissions');

    }).whenComplete((){

      _stopUpdateLoader();

    });

  }

  /// Select the specified permissions
  void _selectSpecifiedPermissions(List<Permission> specifiedPermissions) {
    for (var i = 0; i < specifiedPermissions.length; i++) {
      _togglePermission(true, specifiedPermissions[i]);
    }
  }

  /// Check if this permission is selected
  bool _isPermissionSelected(Permission permission) {
    return selectedPermissions.map((permission) => permission.name).contains(permission.name);
  }

  /// Select or deselect this permission
  void _togglePermission(bool isSelected, Permission permission) {

    setState(() {
      if(isSelected) {
        selectedPermissions.add(permission);
      }else{
        selectedPermissions.removeWhere((selectedPermission) {
          return selectedPermission.name == permission.name;
        });
      }
      
      selectedAll = permissions.length == selectedPermissions.length;

      onTogglePermissions(selectedPermissions);

    });
  }

  /// Show the select all checkbox
  Widget get selectAllCheckbox {
    return CustomCheckbox(
      text: 'Give all permissions',
      value: selectedAll,
      disabled: isUpdating || disabled,
      onChanged: (status) {

        setState(() {
          selectedAll = false;
          selectedPermissions = [];
        });
        
        if(status == true) {

          /// Select every permission available
          _selectSpecifiedPermissions(permissions);

        }else{

          onTogglePermissions(selectedPermissions);

        }
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 20),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.teal.shade200
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// Title
          const CustomTitleMediumText('Permissions', margin: EdgeInsets.only(left: 16, bottom: 4),),

          /// Subtitle
          CustomBodyText(subtitle, margin: const EdgeInsets.only(left: 16),),

          /// Select All Checkbox
          selectAllCheckbox,

          /// Spacer
          const SizedBox(height: 8,),

          /// Permissions
          Container(
            color: Colors.teal.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// Spacer
                SizedBox(height: isUpdating ? 16 : 8,),

                /// Loader
                if(isUpdating) const CustomCircularProgressIndicator(), 

                /// Permissions List
                ...permissions.mapIndexed((index, permission) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        /// Permission Checkbox
                        CustomCheckbox(
                          text: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTitleSmallText(permission.name),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.75,
                                child: CustomBodyText(permission.description)
                              ),
                            ],
                          ),
                          disabled: isUpdating || disabled,
                          value: _isPermissionSelected(permission), 
                          onChanged: (isSelected) {
                            _togglePermission(isSelected ?? false, permission);
                          },
                        )

                      ],
                    );
                  }
                ),

                /// Spacer
                const SizedBox(height: 20,),

              ]
            ),
          ),
        ],
      ),
    );
  }
}