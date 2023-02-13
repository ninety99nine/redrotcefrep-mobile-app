import 'dart:convert';

import 'package:bonako_demo/core/shared_widgets/buttons/custom_elevated_button.dart';
import 'package:bonako_demo/core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:bonako_demo/features/friend_groups/models/friend_group.dart';
import 'package:bonako_demo/features/friend_groups/providers/friend_group_provider.dart';
import 'package:bonako_demo/features/friend_groups/repositories/friend_group_repository.dart';
import 'package:bonako_demo/features/friend_groups/widgets/friend_groups_show/friend_groups_modal_bottom_sheet/friend_groups_modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

import '../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../../features/stores/enums/store_enums.dart';
import '../../../stores/widgets/store_cards.dart';
import 'package:flutter/material.dart';

class GroupsPageContent extends StatefulWidget {
  const GroupsPageContent({super.key});

  @override
  State<GroupsPageContent> createState() => _GroupsPageContentState();
}

class _GroupsPageContentState extends State<GroupsPageContent> with SingleTickerProviderStateMixin {
  
  bool isLoading = false;
  FriendGroup? friendGroup;
  
  bool get hasFriendGroup => friendGroup != null;
  FriendGroupRepository get friendGroupRepository => friendGroupProvider.friendGroupRepository;
  FriendGroupProvider get friendGroupProvider => Provider.of<FriendGroupProvider>(context, listen: false);

  void _startLoader() => setState(() => isLoading = true);
  void _stopLoader() => setState(() => isLoading = false);

  @override
  void initState() {
    super.initState();
    _requestShowLastSelectedFriendGroup();
  }

  void _requestShowLastSelectedFriendGroup() async {

    _startLoader();

    friendGroupRepository.showLastSelectedFriendGroup(
      context: context,
    ).then((response) {

      final responseBody = jsonDecode(response.body);

      if(response.statusCode == 200) {

        friendGroup = FriendGroup.fromJson(responseBody);

      }

    }).whenComplete(() {
      _stopLoader();
    });

  }

  /// Called when the friend group is selected 
  void onSelectedFriendGroups(List<FriendGroup> friendGroups) {
    if(friendGroups.isNotEmpty) {
      setState(() => friendGroup = friendGroups.first);
    }
  }

  Widget get content {
    if(isLoading) {
      
      return const CustomCircularProgressIndicator();
    
    }else if(!isLoading && hasFriendGroup) {
      
      return storeCards;

    }else{

      return const CustomBodyText('No Group');

    }
  }

  Widget get header {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        
        /// Instruction
        const CustomBodyText(
          'Get something 👌 for your group',
          padding: EdgeInsets.only(top: 16, bottom: 8, left: 8, right: 9)
        ),

        /// Spacer
        const SizedBox(height: 8,),

        /// Group Card
        groupCard,

        /// Spacer
        const SizedBox(height: 8,),

      ],
    );
  }

  Widget get groupCard {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0)
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  /// Name
                  AnimatedSize(
                    duration: const Duration(milliseconds: 500),
                    child: AnimatedSwitcher(
                      switchInCurve: Curves.easeIn,
                      switchOutCurve: Curves.easeOut,
                      duration: const Duration(milliseconds: 500),
                      child: CustomTitleSmallText(
                        key: ValueKey(friendGroup!.name),
                        friendGroup!.name, margin: const EdgeInsets.only(bottom: 5)
                      )
                    ),
                  ),

                ],
              ),

              /// Friend Groups Modal Bottom Sheet (Used to change the Friend Group)
              FriendGroupsModalBottomSheet(
                enableBulkSelection: false,
                onSelectedFriendGroups: onSelectedFriendGroups,
              )

            ]
        ),
      ),
    );
  }

  Widget get storeCards {
    return StoreCards(
      friendGroup: friendGroup,
      contentBeforeSearchBar: header,
      userAssociation: UserAssociation.friendGroupMember,
    );
  }

  @override
  Widget build(BuildContext context) {
    return content;
  }
}
