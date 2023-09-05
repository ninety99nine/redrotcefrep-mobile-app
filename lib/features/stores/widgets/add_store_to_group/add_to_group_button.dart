import '../../../friend_groups/widgets/friend_groups_show/friend_groups_modal_bottom_sheet/friend_groups_modal_bottom_sheet.dart';
import '../../../../core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import '../../../../core/shared_widgets/button/custom_text_button.dart';
import '../../../friend_groups/enums/friend_group_enums.dart';
import '../../../friend_groups/models/friend_group.dart';
import '../../providers/store_provider.dart';
import '../../../../core/utils/snackbar.dart';
import '../../models/shoppable_store.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';

class AddStoreToGroupButton extends StatefulWidget {

  final Widget? trigger;
  final bool canShowLoader;
  final ShoppableStore store;
  final Function? onAddedStoreToFriendGroups;

  const AddStoreToGroupButton({
    super.key,
    this.trigger,
    required this.store,
    this.canShowLoader = true,
    this.onAddedStoreToFriendGroups,
  });

  @override
  State<AddStoreToGroupButton> createState() => _AddStoreToGroupButtonState();
}

class _AddStoreToGroupButtonState extends State<AddStoreToGroupButton> {
  
  bool isLoading = false;

  void _startLoader() => setState(() => isLoading = true);
  void _stopLoader() => setState(() => isLoading = false);

  Widget? get _trigger => widget.trigger;
  ShoppableStore get store => widget.store;
  bool get canShowLoader => widget.canShowLoader;
  Function? get onAddedStoreToFriendGroups => widget.onAddedStoreToFriendGroups;
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);

  /// Content to show based on the specified view
  Widget get content {

    Widget trigger;

    if(_trigger == null) {

      trigger = CustomTextButton( 
        '',
        onPressed: null,
        color: Colors.grey.shade400,
        prefixIcon: Icons.group_add_outlined
      );
    
    }else {

      /// Set the provided trigger
      trigger = _trigger!;

    }

    return FriendGroupsModalBottomSheet(
      trigger: trigger,
      enableBulkSelection: true,
      purpose: Purpose.addStoreToFriendGroups,
      onDoneSelectingFriendGroups: requestAddStoreToFriendGroups,
    );
    
  }

  Widget get loader {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: CustomCircularProgressIndicator(
        size: 8, 
        strokeWidth: 1,
        alignment: Alignment.center,
      ),
    );
  }

  void requestAddStoreToFriendGroups(List<FriendGroup> friendGroups) {
    
    _startLoader();

    storeProvider.setStore(store).storeRepository.addStoreToFriendGroups(
      friendGroups: friendGroups,
    ).then((response) {

      if(response.statusCode == 200) {

        /// Notify the parent that this store has been added to friend groups
        if(onAddedStoreToFriendGroups != null) onAddedStoreToFriendGroups!();

        /**
         *  Close the modal bottom sheet
         * 
         *  This must be placed before the SnackbarUtility.showSuccessMessage()
         *  since placing it after will hide the Snackbar message instead of
         *  the modal bottom sheet
         */
        Get.back();

        SnackbarUtility.showSuccessMessage(message: response.data['message']);

      }

    }).catchError((error) {

      printError(info: error.toString());
      
      SnackbarUtility.showErrorMessage(message: 'Failed to add to group');

    }).whenComplete(() {

      _stopLoader();

    });
    
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 500),
      child: AnimatedSwitcher(
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        duration: const Duration(milliseconds: 500),
        child: canShowLoader && isLoading ? loader : content
      )
    );
  }
}