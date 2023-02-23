
import 'package:bonako_demo/features/friend_groups/widgets/friend_groups_show/friend_group_orders_show/friend_group_orders_in_horizontal_list_view_infinite_scroll.dart';

import '../../../friend_groups/widgets/friend_groups_show/friend_groups_modal_bottom_sheet/friend_groups_modal_bottom_sheet.dart';
import '../../../../core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import '../../../../core/shared_widgets/text/custom_title_small_text.dart';
import '../../../friend_groups/repositories/friend_group_repository.dart';
import '../../../friend_groups/providers/friend_group_provider.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../friend_groups/enums/friend_group_enums.dart';
import '../../../../features/stores/enums/store_enums.dart';
import '../../../friend_groups/models/friend_group.dart';
import '../../../stores/widgets/store_cards/store_cards.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class GroupsPageContent extends StatefulWidget {
  const GroupsPageContent({super.key});

  @override
  State<GroupsPageContent> createState() => _GroupsPageContentState();
}

class _GroupsPageContentState extends State<GroupsPageContent> with SingleTickerProviderStateMixin {
  
  bool isLoading = false;
  FriendGroup? friendGroup;
  
  late FriendGroupProvider friendGroupProvider;
  bool get hasFriendGroup => friendGroup != null;
  FriendGroupRepository get friendGroupRepository => friendGroupProvider.friendGroupRepository;

  void _startLoader() => setState(() => isLoading = true);
  void _stopLoader() => setState(() => isLoading = false);

  @override
  void initState() {
    super.initState();
    setFriendGroupProvider();
    _requestShowLastSelectedFriendGroup();
  }

  @override
  void dispose() {
    /**
     *  We need to unset the friend group so that when we navigate to a different home tab
     *  e.g "Following", we do not have a reference of this friend group on the menus of 
     *  each store card on the "Following" home tab. Since the friend group was set here,
     *  it makes sense to clean up by unsetting before leaving the groups page content
     *  so that the friendGroupRepository is restored to the way it was before.
     */
    friendGroupProvider.unsetFriendGroup();
    super.dispose();
  }

  void setFriendGroupProvider() {

    /**
     * Note that we are deliberately setting the FriendGroupProvider this way instead of using a getter 
     * as we normally do. This is because we need to use the friendGroupProvider from the dispose() 
     * method to unsetFriendGroup(). This causes an error when the friendGroupProvider is declared 
     * as a getter method. To prevent this we must declare this on the initState() method so that 
     * the friendGroupProvider can then be used at the dispose() method without any errors. The 
     * Flutter error is as follows:
     * 
     * "Looking up a deactivated widget's ancestor is unsafe: At this point the state of the widget's 
     * element tree is no longer stable. To safely refer to a widget's ancestor in its dispose() 
     * method, save a reference to the ancestor by calling dependOnInheritedWidgetOfExactType() 
     * in the widget's didChangeDependencies() method."
     * 
     * Reference of related issue: 
     * 
     * https://stackoverflow.com/questions/69282208/looking-up-a-deactivated-widgets-ancestor-is-unsafe-navigator-ofcontext-push#:~:text=To%20safely%20refer%20to%20a,Navigator.
     */
    friendGroupProvider = Provider.of<FriendGroupProvider>(context, listen: false);
  }

  void _requestShowLastSelectedFriendGroup() async {

    _startLoader();

    friendGroupRepository.showLastSelectedFriendGroup(
      context: context,
    ).then((response) {

      final responseBody = jsonDecode(response.body);

      if(response.statusCode == 200) {

        friendGroup = FriendGroup.fromJson(responseBody);
        friendGroupProvider.setFriendGroup(friendGroup!);

      }

    }).whenComplete(() {
      _stopLoader();
    });

  }

  /// Called when the friend group is selected 
  void onSelectedFriendGroups(List<FriendGroup> friendGroups) {
    if(friendGroups.isNotEmpty) {
      setState(() {
        final FriendGroup friendGroup = friendGroups.first;
        friendGroupProvider.setFriendGroup(friendGroup);
        this.friendGroup = friendGroup;
      });
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
          padding: EdgeInsets.only(top: 32, bottom: 8)
        ),

        /// Spacer
        const SizedBox(height: 8,),

        /// Group Card
        groupCard,

        /// Spacer
        const SizedBox(height: 8,),

        /// Group Card
        orderCards,

        /// Spacer
        const SizedBox(height: 8,),

      ],
    );
  }

  Widget get groupCard {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
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
                  purpose: Purpose.chooseFriendGroups,
                  onSelectedFriendGroups: onSelectedFriendGroups,
                )

              ]
          ),
        ),
      ),
    );
  }
  
  Widget get orderCards {
    return AnimatedSize(
      duration: const Duration(milliseconds: 500),
      child: FriendGroupOrdersInHorizontalListViewInfiniteScroll(
        key: ValueKey(friendGroup!.name),
        friendGroup: friendGroup!,
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
