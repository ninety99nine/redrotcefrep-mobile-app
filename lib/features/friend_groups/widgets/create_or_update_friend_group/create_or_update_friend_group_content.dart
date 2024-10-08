import 'package:perfect_order/features/friend_groups/widgets/create_or_update_friend_group/create_or_update_friend_group_form.dart';
import '../../../../core/shared_widgets/text/custom_title_medium_text.dart';
import 'package:perfect_order/features/friend_groups/models/friend_group.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateOrUpdateFriendGroupContent extends StatefulWidget {
  
  final String? title;
  final String? subtitle;
  final FriendGroup? friendGroup;
  final void Function(FriendGroup)? onUpdatedFriendGroup;
  final void Function(FriendGroup)? onCreatedFriendGroup;
  final void Function(FriendGroup)? onDeletedFriendGroup;

  const CreateOrUpdateFriendGroupContent({
    super.key,
    this.title,
    this.subtitle,
    this.friendGroup,
    this.onUpdatedFriendGroup,
    this.onCreatedFriendGroup,
    this.onDeletedFriendGroup,
  });

  @override
  State<CreateOrUpdateFriendGroupContent> createState() => _CreateOrUpdateFriendGroupContentState();
}

class _CreateOrUpdateFriendGroupContentState extends State<CreateOrUpdateFriendGroupContent> {

  bool get isEditing => friendGroup != null;
  FriendGroup? get friendGroup => widget.friendGroup;
  void Function(FriendGroup)? get onUpdatedFriendGroup => widget.onUpdatedFriendGroup;
  void Function(FriendGroup)? get onCreatedFriendGroup => widget.onCreatedFriendGroup;
  void Function(FriendGroup)? get onDeletedFriendGroup => widget.onDeletedFriendGroup;

  String get title {

    if(widget.title == null) {

      if(isEditing) {

        return 'Update Your Group';

      }else{

        return 'Create Your Group';

      }

    }else {

      return widget.title!;

    }
  }

  String get subtitle {

    if(widget.subtitle == null) {

      if(isEditing) {

        return 'Lets make changes to your group';

      }else{

        return 'Lets get your group ready';

      }

    }else {

      return widget.subtitle!;

    }
  }

  Widget get content {
    return CreateOrUpdateFriendGroupForm(
      friendGroup: friendGroup,
      onCreatedFriendGroup: onCreatedFriendGroup,
      onUpdatedFriendGroup: onUpdatedFriendGroup,
      onDeletedFriendGroup: onDeletedFriendGroup
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
              
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              
                    /// Title
                    CustomTitleMediumText(title, padding: const EdgeInsets.only(bottom: 8),),
                    
                    /// Subtitle
                    CustomBodyText(subtitle),

                    /// Spacer
                    const SizedBox(height: 16),

                    /// Divider
                    const Divider(height: 0),
                    
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                    child: content,
                  ),
                ),
              ),
          
            ],
          ),
    
          /// Cancel Icon
          Positioned(
            right: 10,
            top: 8,
            child: IconButton(
              icon: Icon(Icons.cancel, size: 28, color: Theme.of(context).primaryColor,),
              onPressed: () => Get.back()
            ),
          ),

        ],
      ),
    );
  }
}