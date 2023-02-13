import '../../../friends/widgets/friends_show/friends_modal_bottom_sheet/friends_modal_bottom_sheet.dart';
import '../../../friends/widgets/friends_show/friends_in_vertical_infinite_scroll.dart';
import '../../../friend_groups/widgets/friend_group_create_or_update/friend_items.dart';
import '../../../../core/shared_widgets/text_form_fields/custom_text_form_field.dart';
import '../../../../core/shared_models/user_association_as_friend_group_member.dart';
import '../../../../core/shared_widgets/message_alerts/custom_message_alert.dart';
import '../../../../core/shared_widgets/buttons/custom_elevated_button.dart';
import '../../../../core/shared_widgets/text/custom_title_medium_text.dart';
import '../../../friend_groups/repositories/friend_group_repository.dart';
import '../../../../core/shared_widgets/checkboxes/custom_checkbox.dart';
import '../../../friend_groups/providers/friend_group_provider.dart';
import 'package:flutter_shake_animated/flutter_shake_animated.dart';
import '../../../friend_groups/models/friend_group.dart';
import '../../../../core/utils/shake_utility.dart';
import '../../../friends/enums/friend_enums.dart';
import '../../../../core/shared_models/user.dart';
import '../../../../core/utils/snackbar.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class FriendGroupCreateOrUpdate extends StatefulWidget {
  
  final FriendGroup? friendGroup;
  final Function(bool) onSubmitting;
  final Function? onUpdatedFriendGroup;
  final Function? onCreatedFriendGroup;

  const FriendGroupCreateOrUpdate({
    super.key,
    this.friendGroup,
    required this.onSubmitting,
    this.onUpdatedFriendGroup,
    this.onCreatedFriendGroup,
  });

  @override
  State<FriendGroupCreateOrUpdate> createState() => _FriendGroupContentState();
}

class _FriendGroupContentState extends State<FriendGroupCreateOrUpdate> {

  String name = '';
  bool shared = false;
  Map serverErrors = {};
  List<User> friends = [];
  bool isSubmitting = false;
  bool canAddFriends = false;
  final _formKey = GlobalKey<FormState>();
  ShakeUtility shakeName = ShakeUtility();
  
  bool get hasFriends => friends.isNotEmpty;
  bool get isCreating => friendGroup == null;
  bool get isEditting => friendGroup != null;
  FriendGroup? get friendGroup => widget.friendGroup;
  Function(bool) get onSubmitting => widget.onSubmitting;
  Function? get onUpdatedFriendGroup => widget.onUpdatedFriendGroup;
  Function? get onCreatedFriendGroup => widget.onCreatedFriendGroup;
  FriendGroupRepository get friendGroupRepository => friendGroupProvider.friendGroupRepository;
  FriendGroupProvider get friendGroupProvider => Provider.of<FriendGroupProvider>(context, listen: false);

  bool get isCreator => friendGroup == null ? true : userAssociationAsFriendGroupMember!.role == 'Creator';
  UserAssociationAsFriendGroupMember? get userAssociationAsFriendGroupMember => friendGroup == null ? null : friendGroup!.attributes.userAssociationAsFriendGroupMember;

  bool get hasChanged {
    if(isCreating) {
      return hasFriends;
    }else{
      return hasFriends || name != friendGroup!.name || shared != friendGroup!.shared || canAddFriends != friendGroup!.canAddFriends;
    }
  }

  void _startSubmittionLoader() => setState(() => isSubmitting = true);
  void _stopSubmittionLoader() => setState(() => isSubmitting = false);

  @override
  void initState() {
    super.initState();

    /// If we are editting a friend group
    if(isEditting) {

      /// Get property values from the friend group
      name = friendGroup!.name;
      shared = friendGroup!.shared;
      canAddFriends = friendGroup!.canAddFriends;

    }
  }

  _requestCreateFriendGroup() {

    _resetServerErrors();

    if(canProceedWithRequest() == false) return; 

    if(_formKey.currentState!.validate()) {

      _startSubmittionLoader();
      
      /// Notify parent that we are loading
      onSubmitting(true);

      friendGroupRepository.createFriendGroup(
        name: name,
        shared: shared,
        friends: friends,
        context: context,
        canAddFriends: canAddFriends,
      ).then((response) async {

        final responseBody = jsonDecode(response.body);

        if(response.statusCode == 200) {

          SnackbarUtility.showSuccessMessage(message: responseBody['message'], context: context);

          if(onCreatedFriendGroup != null) onCreatedFriendGroup!();

        }else if(response.statusCode == 422) {

          handleServerValidation(responseBody['errors']);
          
        }

      }).catchError((error) {

        SnackbarUtility.showErrorMessage(message: 'Can\'t update group', context: context);

      }).whenComplete((){

        _stopSubmittionLoader();
      
        /// Notify parent that we are not loading
        onSubmitting(false);

      });

    }else{

      SnackbarUtility.showErrorMessage(context: context, message: 'We found some mistakes');

    }

  }

  _requestUpdateFriendGroup() {

    _resetServerErrors();

    if(canProceedWithRequest() == false) return; 

    if(_formKey.currentState!.validate()) {

      _startSubmittionLoader();
      
        /// Notify parent that we are loading
      onSubmitting(true);

      friendGroupRepository.updateFriendGroup(
        name: name,
        shared: shared,
        friends: friends,
        context: context,
        canAddFriends: canAddFriends,
      ).then((response) async {

        final responseBody = jsonDecode(response.body);

        if(response.statusCode == 200) {

          SnackbarUtility.showSuccessMessage(message: responseBody['message'], context: context);

          if(onUpdatedFriendGroup != null) onUpdatedFriendGroup!();


        }else if(response.statusCode == 422) {

          handleServerValidation(responseBody['errors']);
          
        }

      }).catchError((error) {

        SnackbarUtility.showErrorMessage(message: 'Can\'t update group', context: context);

      }).whenComplete((){

        _stopSubmittionLoader();
      
        /// Notify parent that we are not loading
        onSubmitting(false);

      });

    }else{

      SnackbarUtility.showErrorMessage(context: context, message: 'We found some mistakes');

    }

  }

  bool canProceedWithRequest() {

    if( name.isEmpty ) {
      
      /// Start shaking the ShakeWidget widget
      shakeName.shake(setState: setState);

      return false;

    }

    return true;

  }

  /// Set the validation errors as serverErrors
  void handleServerValidation(Map errors) {

    /**
     *  errors = {
     *    comment: [The comment must be more than 10 characters]
     * }
     */
    setState(() {
      errors.forEach((key, value) {
        serverErrors[key] = value[0];
      });
    });

  }

  /// Reset the server errors
  void _resetServerErrors() => setState(() => serverErrors = {});

  /// Called when the user is done selecting friends
  void onDoneSelectingFriends(List<User> friends) {
    setState(() {
      if(this.friends.isEmpty) {

        /// Set friends
        this.friends = friends;

      }else{

        /// Add friends to existing list of friends while avoiding duplicates
        this.friends.addAll(
          friends.where((newFriend) {
            return this.friends.where((existingFriend) => existingFriend.id == newFriend.id).isEmpty;
          }).toList()
        );
      }
    });
  }

  void onRemoveFriends(User user) {
    setState(() => friends.removeWhere((currUser) => currUser.id == user.id));
  }
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0,),
        child: Column(
          children: [

            Form(
              key: _formKey,
              child: Column(
                children: [

                  /// Spacer
                  const SizedBox(height: 16),
                
                  /// Show Catch Error Message
                  if(isCreating) const CustomMessageAlert(
                    'You can create a group for work friends, church friends, social clubs',
                    margin: EdgeInsets.only(bottom: 16)
                  ),

                  if(!isCreator) const CustomMessageAlert(
                    'This is a shared group',
                    margin: EdgeInsets.only(bottom: 16)
                  ),

                  /// Group Name
                  if(isCreator) ShakeWidget(
                    shakeConstant: ShakeHorizontalConstant2(),
                    autoPlay: shakeName.canShake,
                    enableWebMouseHover: true,
                    child: CustomTextFormField(
                      errorText: serverErrors.containsKey('name') ? serverErrors['name'] : null,
                      enabled: isCreator && !isSubmitting,
                      initialValue: name,
                      hintText: 'Co-workers',
                      onChanged: (value) {
                        setState(() => name = value); 
                      },
                      onSaved: (value) {
                        setState(() => name = value ?? ''); 
                      },
                    ),
                  ),

                  if(!isCreator) Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(24)
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: CustomTitleMediumText(name),
                    ),
                  ),

                  /// Spacer
                  if(isCreator) const SizedBox(height: 16),

                  /// Share Group Checkbox
                  if(isCreator) CustomCheckbox(
                    value: shared,
                    disabled: isSubmitting,
                    text: 'Share group with friends',
                    onChanged: (value) {
                      setState(() => shared = value ?? false); 
                    }
                  ),

                  /// Can Add Other Friends Checkbox
                  if(isCreator) AnimatedSize(
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

                  /// Divider
                  if(canAddFriends == false) const SizedBox(height: 16),
                  const Divider(height: 32),

                  /// Friend Modal Bottom Sheet
                  if(isCreator || (!isCreator && canAddFriends)) Row(
                    key: ValueKey(hasChanged),
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: hasChanged ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
                    children: [
                      
                      FriendsModalBottomSheet(
                        purpose: Purpose.addFriendsToGroup,
                        onDoneSelectingFriends: onDoneSelectingFriends,
                      ),
                  
                      if(hasChanged) CustomElevatedButton(
                        width: 120,
                        isLoading: isSubmitting,
                        alignment: Alignment.center,
                        isEditting ? 'Save Changes' : 'Create Group',
                        onPressed: isEditting ? _requestUpdateFriendGroup : _requestCreateFriendGroup,
                      )
                      
                    ],
                  ),

                  if(isEditting && hasFriends) const CustomMessageAlert(
                    'Save your new friends to this group',
                    margin: EdgeInsets.only(top: 16, bottom: 16)
                  ),

                  /// Friends In ListView
                  if(hasFriends) FriendItems(
                    users: friends,
                    onRemoveFriends: onRemoveFriends
                  ),
          
                  /// Friends In Vertical Infinite Scroll
                  if(isEditting && !hasFriends) FriendsInVerticalInfiniteScroll(
                    canShowRemoveIcon: true,
                    friendGroup: friendGroup,
                    canSelect: canAddFriends,
                    headerPadding: const EdgeInsets.only(top: 16, bottom: 0, left: 16, right: 16)
                  ),
                  
                ]
              ),
            ),

            /// Spacer
            const SizedBox(height: 100)

          ],
        ),
      ),
    );
  }
}