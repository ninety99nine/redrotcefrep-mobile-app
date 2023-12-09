import 'package:bonako_demo/core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_medium_text.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:bonako_demo/features/authentication/providers/auth_provider.dart';
import 'package:bonako_demo/features/friend_groups/models/friend_group.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/user/models/resource_totals.dart';
import 'package:bonako_demo/core/shared_models/user.dart';
import 'package:bonako_demo/core/utils/snackbar.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';

class GroupsPageContent extends StatefulWidget {

  final Function(int) onChangeNavigationTab;
  final Future<dio.Response?> Function() onRequestShowResourceTotals;

  const GroupsPageContent({
    super.key,
    required this.onChangeNavigationTab,
    required this.onRequestShowResourceTotals
  });

  @override
  State<GroupsPageContent> createState() => _GroupsPageContentState();
}

class _GroupsPageContentState extends State<GroupsPageContent> with WidgetsBindingObserver{

  late User authUser;
  ResourceTotals? resourceTotals;
  bool isLoadingFriendGroup = false;
  bool isLoadingResourceTotals = false;
  FriendGroup? myRecentlyCreatedFriendGroup;
  bool sentFirstRequestToLoadFriendGroup = false;

  bool get hasResourceTotals => resourceTotals != null;
  bool get doesNotHaveResourceTotals => resourceTotals == null;
  bool get hasCreatedAFriendGroup => myRecentlyCreatedFriendGroup != null;
  Function(int) get onChangeNavigationTab => widget.onChangeNavigationTab;
  
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
  Future<dio.Response?> Function() get onRequestShowResourceTotals => widget.onRequestShowResourceTotals;
  int get totalPlacedOrders => hasCreatedAFriendGroup ? myRecentlyCreatedFriendGroup!.ordersCount ?? 0 : 0;
  int get totalAddedStores => hasCreatedAFriendGroup ? myRecentlyCreatedFriendGroup!.storesCount ?? 0 : 0;
  int get totalAddedFriends => hasCreatedAFriendGroup ? myRecentlyCreatedFriendGroup!.friendsCount ?? 0 : 0;
  bool get hasAddedStores => hasCreatedAFriendGroup ? myRecentlyCreatedFriendGroup!.storesCount! > 0 : false;
  bool get hasAddedFriends => hasCreatedAFriendGroup ? myRecentlyCreatedFriendGroup!.friendsCount! > 0 : false;
  bool get hasPlacedAnOrder => hasCreatedAFriendGroup ? myRecentlyCreatedFriendGroup!.ordersCount! > 0 : false;
  bool get hasGroupsJoinedAsNonCreator => hasResourceTotals ? resourceTotals!.totalGroupsJoinedAsNonCreator > 0 : false;
  bool get hasCompletedEverything => hasCreatedAFriendGroup ? false : false;

  void _startShowGroupLoader() => setState(() => isLoadingFriendGroup = true);
  void _stopShowGroupLoader() => setState(() => isLoadingFriendGroup = false);
  void _startRequestResourceTotalsLoader() => setState(() => isLoadingResourceTotals = true);
  void _stopRequestResourceTotalsLoader() => setState(() => isLoadingResourceTotals = false);

  @override
  void initState() {
    super.initState();
    authUser = authProvider.user!;

    _showFirstCreatedFriendGroup();

    // Register the observer to detect app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
    
  }

  @override
  void dispose() {
    super.dispose();

    // Remove the observer to detect app lifecycle changes
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {

    /**
     *  Once the user returns we want to refresh the state of the friend group incase
     *  anything has changed e.g The group has members
     */
    if (state == AppLifecycleState.resumed) {

      _showFirstCreatedFriendGroup();

    }

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    /// Get the authenticated user's resource totals
    final ResourceTotals? updateResourceTotals = Provider.of<AuthProvider>(context, listen: false).resourceTotals;

    if(updateResourceTotals != null) {

      /// Update the local resourceTotals
      setState(() => resourceTotals = updateResourceTotals);
      
    }
    
  }

  void _showFirstCreatedFriendGroup() {

    _startShowGroupLoader();

    authProvider.userRepository.showFirstCreatedFriendGroup().then((response) {

      setState(() => sentFirstRequestToLoadFriendGroup = true);

      if(response.statusCode == 200) {

        final bool friendGroupExists = response.data['exists'];

        if(friendGroupExists) {

          setState(() => myRecentlyCreatedFriendGroup = FriendGroup.fromJson(response.data['friendGroup']));

        }

      }

    }).catchError((error) {

      printError(info: error.toString());

      SnackbarUtility.showErrorMessage(message: 'Failed to show your first group');

    }).whenComplete(() {

      _stopShowGroupLoader();

    });

  }

  Widget get _completedEverythingContent {
    return Column(
      children: const [

        Text('Completed')

      ]
    );
  }

  Widget get _hasNotCompletedEverythingContent {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
      child: Column(
        children: [
    
          /// Title
          const CustomTitleMediumText('How Groups Work', margin: EdgeInsets.only(top: 32),),
    
          Stack(
            children: [
              
              _milestones,
    
            ],
          ),

          /// NOTE THAT THE INVITAITONS WILL GO HERE
          /// NOTE THAT THE INVITAITONS WILL GO HERE
          /// NOTE THAT THE INVITAITONS WILL GO HERE

          /// Group Image
          _groupImage,

          /// Spacer
          const SizedBox(height: 100),

        ]
      )
    );
  }

  Widget get _milestones {
    return  Container(
      padding: const EdgeInsets.only(top: 16),
      child: Stack(
        children: [

          Column(
            children: [
    
              /// Create Group Milestone
              _addMilestone(
                number: 1,
                checked: hasCreatedAFriendGroup,
                content: createFriendGroupInstruction
              ),
    
              /// Add Friends Milestone
              _addMilestone(
                number: 2,
                checked: hasAddedFriends,
                content: addFriendsInstruction
              ),
    
              /// Add Stores Milestone
              _addMilestone(
                number: 3,
                checked: hasAddedStores,
                content: addStoresInstruction
              ),
    
              /// Place Order Milestone
              _addMilestone(
                number: 4,
                checked: hasPlacedAnOrder,
                content: placeAnOrderInstruction
              ),
              
            ],
          ),

          if(isLoadingFriendGroup || isLoadingResourceTotals) Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: const BorderRadius.all(Radius.circular(16))
              ),
              child: const CustomCircularProgressIndicator(
                strokeWidth: 2,
                size: 16
              ),
            ),
          )
          
        ],
      ),
    );
  }

  Widget _addMilestone({ required bool checked, required int number, required dynamic content }) {

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.all(Radius.circular(16))
            ),
            child: checked 
            ? Icon(Icons.check_circle_sharp, size: 32, color: Colors.white.withOpacity(0.8))
            : Center(child: CustomTitleSmallText('$number', color: Colors.white,))
          ),
          const SizedBox(width: 16),
          content.runtimeType == String
            ? CustomBodyText(content)
            : content
        ],
      ),
    );

  }

  Widget get _groupImage {
    return Container(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20)
      ),
      alignment: Alignment.center,
      child: SizedBox(
        width: double.infinity,
        child: Image.asset('assets/images/friends_walking.jpeg')
      ),
    );
  }

  Widget get createFriendGroupInstruction {

    if(hasCreatedAFriendGroup) {

      return RichText(
        text: TextSpan(
          text: 'Created ',
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(
              text: myRecentlyCreatedFriendGroup!.name,
              style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline, color: Colors.green)
            ),
          ]
        )
      );

    }else{

      return RichText(
        text: TextSpan(
          text: 'First ', 
          style: Theme.of(context).textTheme.bodyMedium,
          children: const [
            TextSpan(
              text: 'create group', 
              style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)
            ),
          ]
        )
      );

    }

  }

  Widget get addFriendsInstruction {

    if(hasAddedFriends) {

      return RichText(
        text: TextSpan(
          text: 'Added ', 
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(
              text: '$totalAddedFriends ${totalAddedFriends == 1 ? 'friend' : 'friends'}',
              style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)
            ),
          ]
        )
      );

    }else{

      return RichText(
        text: TextSpan(
          text: 'Then ',
          style: Theme.of(context).textTheme.bodyMedium,
          children: const [
            TextSpan(
              text: 'add friends',
              style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)
            ),
          ]
        )
      );

    }

  }

  Widget get addStoresInstruction {

    if(hasAddedStores) {

      return RichText(
        text: TextSpan(
          text: 'Added ', 
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(
              text: '$totalAddedStores ${totalAddedStores == 1 ? 'store' : 'stores'}',
              style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline, color: Colors.green)
            ),
          ]
        )
      );

    }else{

      return RichText(
        text: TextSpan(
          text: 'Now ',
          style: Theme.of(context).textTheme.bodyMedium,
          children: const [
            TextSpan(
              text: 'add stores',
              style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)
            ),
          ]
        )
      );

    }

  }

  Widget get placeAnOrderInstruction {

    if(hasPlacedAnOrder) {

      return RichText(
        text: TextSpan(
          text: 'Placed ', 
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(
              text: '$totalPlacedOrders ${totalPlacedOrders == 1 ? 'order' : 'orders'}',
              style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline, color: Colors.green)
            ),
          ]
        )
      );

    }else{

      return RichText(
        text: TextSpan(
          text: 'Place ',
          style: Theme.of(context).textTheme.bodyMedium,
          children: const [
            TextSpan(
              text: 'order',
              style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)
            ),
          ]
        )
      );

    }

  }

  void _listenForAuthProviderChanges(BuildContext context) {

    /// Listen for changes on the AuthProvider so that we can know when the authProvider.resourceTotals have
    /// been updated. Once the authProvider.resourceTotals have been updated by the OrderPageContent Widget, 
    /// we can then use getter such as authProvider.hasStoresAsFollower to know whether this authenticated 
    /// user has stores that they are following.
    /// 
    /// Once these changes occur, we can use the didChangeDependencies() 
    /// to capture these changes and response accordingly
    Provider.of<AuthProvider>(context, listen: true);

  }

  @override
  Widget build(BuildContext context) {

    _listenForAuthProviderChanges(context);

    return SingleChildScrollView(
      child: SizedBox(
        width: double.infinity,
        child: AnimatedSize(
          duration: const Duration(milliseconds: 500),
          child: AnimatedSwitcher(
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            duration: const Duration(milliseconds: 500),
            child: doesNotHaveResourceTotals || !sentFirstRequestToLoadFriendGroup
              ? const CustomCircularProgressIndicator(
                  margin: EdgeInsets.symmetric(vertical: 100),
                  strokeWidth: 2,
                  size: 16
                )
              : Column(
                  children: [
                        
                    /// Completed Everything Content
                    if(hasCompletedEverything || hasGroupsJoinedAsNonCreator) _completedEverythingContent,

                    /// Has Not Completed Everything Content
                    if(!hasCompletedEverything && !hasGroupsJoinedAsNonCreator) _hasNotCompletedEverythingContent

                  ]
                )
          )
        )
      ),
    );
  }
}