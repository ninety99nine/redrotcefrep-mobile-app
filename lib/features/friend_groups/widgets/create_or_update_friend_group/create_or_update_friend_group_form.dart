import 'package:perfect_order/core/shared_widgets/text/custom_title_medium_text.dart';
import 'package:perfect_order/core/utils/dialog.dart';
import 'package:perfect_order/features/friend_groups/repositories/friend_group_repository.dart';
import 'package:perfect_order/features/friend_groups/providers/friend_group_provider.dart';
import '../../../../core/shared_widgets/text_form_field/custom_text_form_field.dart';
import 'package:perfect_order/features/authentication/providers/auth_provider.dart';
import 'package:perfect_order/core/shared_widgets/checkbox/custom_checkbox.dart';
import 'package:perfect_order/features/friend_groups/models/friend_group.dart';
import '../../../../core/shared_widgets/button/custom_elevated_button.dart';
import '../friend_group_emoji_picker/friend_group_emoji_picker.dart';
import 'package:flutter_shake_animated/flutter_shake_animated.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:perfect_order/core/utils/error_utility.dart';
import 'package:perfect_order/core/utils/shake_utility.dart';
import '../../../../core/utils/snackbar.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';

class CreateOrUpdateFriendGroupForm extends StatefulWidget {

  final FriendGroup? friendGroup;
  final void Function(bool)? onCreating;
  final void Function(bool)? onUpdating;
  final void Function(bool)? onDeleting;
  final void Function(FriendGroup)? onCreatedFriendGroup;
  final void Function(FriendGroup)? onUpdatedFriendGroup;
  final void Function(FriendGroup)? onDeletedFriendGroup;

  const CreateOrUpdateFriendGroupForm({
    super.key,
    this.onCreating,
    this.onUpdating,
    this.onDeleting,
    this.friendGroup,
    this.onUpdatedFriendGroup,
    this.onCreatedFriendGroup,
    this.onDeletedFriendGroup,
  });

  @override
  State<CreateOrUpdateFriendGroupForm> createState() => _CreateOrUpdateFriendGroupFormState();
}

class _CreateOrUpdateFriendGroupFormState extends State<CreateOrUpdateFriendGroupForm> {
  
  String name = '';
  bool shared = true;
  String? description;
  Emoji? selectedEmoji;
  Map serverErrors = {};
  bool isDeleting = false;
  bool canAddFriends = true;
  bool isSubmitting = false;
  ShakeUtility shakeName = ShakeUtility();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emojiTextEditingController = TextEditingController();

  bool get doesNotHaveName => name.isEmpty;
  bool get isEditing => friendGroup != null;
  bool get hasEmoji => selectedEmoji != null;
  bool get doesNotHaveEmoji => selectedEmoji == null;
  FriendGroup? get friendGroup => widget.friendGroup;
  void Function(bool)? get onCreating => widget.onCreating;
  void Function(bool)? get onUpdating => widget.onUpdating;
  void Function(bool)? get onDeleting => widget.onDeleting;
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
  void Function(FriendGroup)? get onUpdatedFriendGroup => widget.onUpdatedFriendGroup;
  void Function(FriendGroup)? get onCreatedFriendGroup => widget.onCreatedFriendGroup;
  void Function(FriendGroup)? get onDeletedFriendGroup => widget.onDeletedFriendGroup;
  String? get nameErrorText => serverErrors.containsKey('name') ? serverErrors['name'] : null;
  FriendGroupRepository get friendGroupRepository => friendGroupProvider.friendGroupRepository;
  FriendGroupProvider get friendGroupProvider => Provider.of<FriendGroupProvider>(context, listen: false);
  String? get descriptionErrorText => serverErrors.containsKey('description') ? serverErrors['description'] : null;
  bool get doesNotHaveChanges => isEditing ? (selectedEmoji?.emoji == friendGroup!.emoji) && (name == friendGroup!.name) && (description == friendGroup!.description) && (shared == friendGroup!.shared) && (canAddFriends == friendGroup!.canAddFriends) : false;

  void _startDeleteLoader() => setState(() => isDeleting = true);
  void _stopDeleteLoader() => setState(() => isDeleting = false);
  void _startSubmittionLoader() => setState(() => isSubmitting = true);
  void _stopSubmittionLoader() => setState(() => isSubmitting = false);

  @override
  void initState() {
    super.initState();

    if(isEditing) {
      name = friendGroup!.name;
      shared = friendGroup!.shared;
      description = friendGroup!.description;
      canAddFriends = friendGroup!.canAddFriends;
      selectedEmoji = friendGroup!.emoji == null ? null : Emoji(friendGroup!.emoji!, '');
    }
  }

  void _requestCreateFriendGroup() {

    if(isSubmitting) return;

    if(canProceedWithRequest() == false) return; 

    _resetServerErrors().then((value) {

      if(_formKey.currentState!.validate()) {

        _startSubmittionLoader();
        if(onCreating != null) onCreating!(true); 

        friendGroupRepository.createFriendGroup(
          name: name,
          shared: shared,
          description: description,
          emoji: selectedEmoji!.emoji,
          canAddFriends: canAddFriends
        ).then((response) async {

          if(response.statusCode == 201) {

            _resetForm();

            String message = response.data['message'];

            FriendGroup createdFriendGroup = FriendGroup.fromJson(response.data['friendGroup']);

            if(onCreatedFriendGroup != null) onCreatedFriendGroup!(createdFriendGroup);

            SnackbarUtility.showSuccessMessage(message: message);

          }

        }).onError((dio.DioException exception, stackTrace) {

          ErrorUtility.setServerValidationErrors(setState, serverErrors, exception);

        }).catchError((error) {

          printError(info: error.toString());

          SnackbarUtility.showErrorMessage(message: 'Can\'t create group');

        }).whenComplete(() {

          _stopSubmittionLoader();
          if(onCreating != null) onCreating!(false);

        });

      }else{

        SnackbarUtility.showErrorMessage(message: 'We found some mistakes');

      }

    });

  }

  void _requestUpdateFriendGroup() {

    if(isSubmitting) return;

    if(canProceedWithRequest() == false) return; 

    _resetServerErrors().then((value) {

      if(_formKey.currentState!.validate()) {

        _startSubmittionLoader();
        if(onUpdating != null) onUpdating!(true);

        friendGroupProvider.setFriendGroup(friendGroup!).friendGroupRepository.updateFriendGroup(
          name: name,
          shared: shared,
          description: description,
          emoji: selectedEmoji!.emoji,
          canAddFriends: canAddFriends
        ).then((response) async {

          if(response.statusCode == 200) {

            _resetForm();

            final String message = response.data['message'];

            final FriendGroup updatedFriendGroup = FriendGroup.fromJson(response.data['friendGroup']);

            if(onUpdatedFriendGroup != null) onUpdatedFriendGroup!(updatedFriendGroup);

            SnackbarUtility.showSuccessMessage(message: message);

          }

        }).onError((dio.DioException exception, stackTrace) {

          ErrorUtility.setServerValidationErrors(setState, serverErrors, exception);

        }).catchError((error) {

          printError(info: error.toString());

          SnackbarUtility.showErrorMessage(message: 'Can\'t update group');

        }).whenComplete(() {

          _stopSubmittionLoader();
          if(onUpdating != null) onUpdating!(false);

        });

      }else{

        SnackbarUtility.showErrorMessage(message: 'We found some mistakes');

      }

    });

  }

  /// Reset the server errors
  void _resetForm() {
    setState(() {
      name = '';

      Future.delayed(const Duration(milliseconds: 100)).then((value) {

        if(_formKey.currentState != null) {
          
          _formKey.currentState!.reset();

        }
      
      });
    });
  }

  void _requestDeleteFriendGroup() async {

    if(isDeleting) return;

    final bool? confirmation = await confirmDelete();

    /// If we can delete
    if(confirmation == true) {

      _startDeleteLoader();

      /// Notify parent that we are starting the deleting process
      if(onDeleting != null) onDeleting!(true);

      friendGroupProvider.setFriendGroup(friendGroup!).friendGroupRepository.deleteFriendGroup().then((response) async {

        if(response.statusCode == 200) {

          /// Notify parent that the friend group has been deleted
          if(onDeletedFriendGroup != null) onDeletedFriendGroup!(friendGroup!);

          SnackbarUtility.showSuccessMessage(message: response.data['message']);

        }

      }).onError((dio.DioException exception, stackTrace) {

        ErrorUtility.setServerValidationErrors(setState, serverErrors, exception);

      }).catchError((error) {

        printError(info: error.toString());

        SnackbarUtility.showErrorMessage(message: 'Failed to delete group');

      }).whenComplete(() {

        _stopDeleteLoader();

        /// Notify parent that we are ending the deleting process
        if(onDeleting != null) onDeleting!(false);

      });

    }

  }

  /// Confirm delete transaction
  Future<bool?> confirmDelete() {

    return DialogUtility.showConfirmDialog(
      content: 'Are you sure you want to delete ${friendGroup!.name}?',
      context: context
    );

  }

  bool canProceedWithRequest() {

    if( name.isEmpty ) {
      
      /// Start shaking the ShakeWidget widget
      shakeName.shake(setState: setState);

      return false;

    }

    return true;

  }

  /// Reset the server errors
  Future _resetServerErrors() {

    setState(() => serverErrors = {});

    /**
     *  We need to allow the setState() method to update the Widget Form Fields
     *  so that we can give the application a chance to update the inputs 
     *  before we validate them.
     */
    return Future.delayed(const Duration(milliseconds: 100));
    
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Stpre Emoji Picker
            FriendGroupEmojiPicker(
              emoji: selectedEmoji,
              onEmojiSelected: (Category? category, Emoji emoji) {
                setState(() => selectedEmoji = emoji);
              },
            ),

            /// Spacer
            const SizedBox(height: 16,),

            /// Group Name
            ShakeWidget(
              shakeConstant: ShakeHorizontalConstant2(),
              autoPlay: shakeName.canShake,
              enableWebMouseHover: true,
              child: CustomTextFormField(
                errorText: serverErrors.containsKey('name') ? serverErrors['name'] : null,
                hintText: 'Gym Buddies',
                enabled: !isSubmitting,
                initialValue: name,
                maxLength: 60,
                onChanged: (value) {
                  setState(() => name = value); 
                }
              ),
            ),
              
            /// Spacer
            const SizedBox(height: 16),

            /// Description
            CustomTextFormField(
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              hintText: 'Home for healthy gym products',
              labelText: 'Description (Optional)',
              errorText: descriptionErrorText,
              initialValue: description,
              enabled: !isSubmitting,
              borderRadiusAmount: 16,
              maxLength: 120,
              minLines: 2,
              onChanged: (value) {
                setState(() => description = value); 
              }
            ),

            /// Spacer
            const SizedBox(height: 16),

            /// Share Group Checkbox
            CustomCheckbox(
              value: shared,
              disabled: isSubmitting,
              text: 'Share group with friends',
              onChanged: (value) {
                setState(() => shared = value ?? false); 
              }
            ),

            /// Spacer
            const SizedBox(height: 8),

            /// Share Group Checkbox
            AnimatedSize(
              duration: const Duration(milliseconds: 500),
              child: SizedBox(
                width: double.infinity,
                child: AnimatedSwitcher(
                  switchInCurve: Curves.easeIn,
                  switchOutCurve: Curves.easeOut,
                  duration: const Duration(milliseconds: 500),
                  child: shared ? CustomCheckbox(
                    value: canAddFriends,
                    disabled: isSubmitting,
                    text: 'Friends can add other friends',
                    onChanged: (value) {
                      setState(() => canAddFriends = value ?? false); 
                    }
                  ) : null,
                ),
              ),
            ),

            /// Spacer
            const SizedBox(height: 16),

            /// Add Button
            CustomElevatedButton(
              width: 120,
              isLoading: isSubmitting,
              alignment: Alignment.center,
              isEditing ? 'Save Changes' : 'Create Group',
              onPressed: isEditing ? _requestUpdateFriendGroup : _requestCreateFriendGroup,
              disabled: doesNotHaveName || doesNotHaveEmoji || isDeleting || (isEditing && doesNotHaveChanges),
            ),

            if(isEditing) ...[

              /// Spacer
              const SizedBox(height: 32),

              /// Delete
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
                    const CustomTitleMediumText('Delete', margin: EdgeInsets.only(bottom: 4),),

                    /// Divider
                    const Divider(),
              
                    /// Delete Instructions
                    RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.normal,
                          height: 1.4
                        ),
                        text: 'Permanently delete ',
                        children: [
                          TextSpan(text: friendGroup!.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const TextSpan(text: '. Once this group is deleted you will not be able to recover it.'),
                        ]
                      ),
                    ),

                    /// Spacer
                    const SizedBox(height: 8,),

                    /// Remove Button
                    CustomElevatedButton(
                      'Delete',
                      width: 180,
                      isError: true,
                      isLoading: isDeleting,
                      alignment: Alignment.center,
                      onPressed: _requestDeleteFriendGroup,
                    ),

                  ],
                ),
              ),

              /// Spacer
              const SizedBox(height: 100),

            ]

          ]
        )
    );
  }
}