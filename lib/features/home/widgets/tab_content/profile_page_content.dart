import 'package:bonako_demo/features/orders/enums/order_enums.dart';
import 'package:bonako_demo/features/user/widgets/user_profile/update_user_profile/update_user_profile_modal_bottom_sheet/update_user_profile_modal_bottom_sheet.dart';
import 'package:bonako_demo/features/stores/widgets/stores_in_horizontal_list_view_infinite_scroll/stores_in_horizontal_list_view_infinite_scroll.dart';
import 'package:bonako_demo/features/orders/widgets/orders_show/user_orders_in_horizontal_list_view_infinite_scroll.dart';
import 'package:bonako_demo/features/orders/widgets/orders_show/orders_modal_bottom_sheet/orders_modal_bottom_sheet.dart';
import 'package:bonako_demo/features/reviews/widgets/reviews_show/reviews_modal_bottom_sheet/reviews_modal_bottom_sheet.dart';
import 'package:bonako_demo/core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import 'package:bonako_demo/features/user/widgets/user_profile_photo/user_profile_photo.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_medium_text.dart';
import 'package:bonako_demo/core/shared_widgets/button/custom_elevated_button.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_large_text.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/user/models/resource_totals.dart';
import 'package:bonako_demo/features/reviews/enums/review_enums.dart';
import 'package:bonako_demo/features/stores/enums/store_enums.dart';
import '../../../../core/constants/constants.dart' as constants;
import '../../../authentication/providers/auth_provider.dart';
import '../../../../core/shared_models/user.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;

class ProfilePageContent extends StatefulWidget {

  final Function(int) onChangeNavigationTab;

  const ProfilePageContent({
    super.key,
    required this.onChangeNavigationTab
  });

  @override
  State<ProfilePageContent> createState() => _ProfilePageContentState();
}

class _ProfilePageContentState extends State<ProfilePageContent> {

  late User authUser;
  ResourceTotals? resourceTotals;
  int? get totalOrders => resourceTotals?.totalOrders;
  bool get hasResourceTotals => resourceTotals != null;
  int? get totalReviews => resourceTotals?.totalReviews;
  bool get doesNotHaveResourceTotals => resourceTotals == null;
  bool get doesNotHaveProfilePhoto => authUser.profilePhoto == null;
  Function(int) get onChangeNavigationTab => widget.onChangeNavigationTab;
  int? get totalGroupsJoinedAsMember => resourceTotals?.totalGroupsJoinedAsMember;
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
  bool get hasPlacedAnOrder => hasResourceTotals ? resourceTotals!.totalOrders > 0 : false;
  bool get hasSharedAReview => hasResourceTotals ? resourceTotals!.totalReviews > 0 : false;
  bool get hasCompletedEverything => hasPlacedAnOrder && hasSharedAReview && hasGroupsJoinedAsMember;
  bool get hasStoresAsACustomer => hasResourceTotals ? resourceTotals!.totalStoresAsCustomer > 0 : false;
  bool get hasCreatedAStore => hasResourceTotals ? resourceTotals!.totalStoresJoinedAsCreator > 0 : false;
  bool get hasGroupsJoinedAsMember => hasResourceTotals ? resourceTotals!.totalGroupsJoinedAsMember > 0 : false;
  bool get hasStoresAsRecentVisitor => hasResourceTotals ? resourceTotals!.totalStoresAsRecentVisitor > 0 : false;

  @override
  void initState() {
    super.initState();
    authUser = authProvider.user!;
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

  void setProfilePhoto(XFile file, dio.Response response) {
    setState(() {
      authUser.profilePhoto = file.path;
      authProvider.setUser(authUser);
    });
  }

  void unsetProfilePhoto() {
    setState(() {
      authUser.profilePhoto = null;
      authProvider.setUser(authUser);
    });
  }

  Widget get _profile {
    return UpdateUserProfileModalBottomSheet(
      user: authUser,
      onUpdatedUser: (updatedUser) {
       setState(() {
        authUser = updatedUser;
        authProvider.setUser(updatedUser);
       });
      },
      trigger: _addImageBackground(
        child: Column(
          children: [
        
            /// Profile Photo
            _profilePhoto,
        
            /// Spacer
            const SizedBox(height: 16),
        
            /// Profile Information
            _profileInformation
        
          ],
        ),
      ),
    );
  }

  Widget get _profilePhoto {
    return UserProfilePhoto(
      radius: 60, 
      canCall: false, 
      user: authUser, 
      placeholderIconSize: 80,
      onSubmittedFile: setProfilePhoto,
      onDeletedFile: unsetProfilePhoto,
      canShowEditPhotoIcon: doesNotHaveProfilePhoto, 
    );
  }

  Widget get _profileInformation {

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
          
        /// Spacer
        const SizedBox(width: 50,),

        Column(
          children: [
            
            /// Profile Name
            CustomTitleLargeText(authUser.attributes.name, color: Colors.white),

            /// Spacer
            const SizedBox(height: 4,),

            /// Mobile Number
            CustomTitleMediumText('${authUser.mobileNumber?.withoutExtension}', color: Colors.white),

          ],
        ),
          
        /// Spacer
        const SizedBox(width: 16,),

        /// Edit Icon
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Icon(Icons.mode_edit_outlined, size: 20, color: Colors.grey.shade400),
        ),

      ],
    );
  }

  Widget get _placeOrderButton {
    return CustomElevatedButton(
      'Place Order', 
      onPressed: () {},
      alignment: Alignment.center,
    );
  }

  Widget get _milestones {
    return  Container(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
    
          ///   Place Your First Order Milestone
          _addMilestone(
            number: 1,
            checked: hasPlacedAnOrder,
            content: placeYourFirstOrderInstruction
          ),
    
          /// Share Your First Review Milestone
          _addMilestone(
            number: 2,
            checked: hasSharedAReview,
            content: shareYourFirstReviewInstruction
          ),
    
          /// Create Your First Group Milestone
          _addMilestone(
            number: 3,
            checked: hasGroupsJoinedAsMember,
            content: createYourFirstGroupInstruction
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

  Widget get placeYourFirstOrderInstruction {

    if(hasPlacedAnOrder) {

      return OrdersModalBottomSheet(
        userOrderAssociation: UserOrderAssociation.customer,
        trigger: (openBottomModalSheet) => RichText(
          text: TextSpan(
            text: 'Placed ',
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              TextSpan(
                text: '${totalOrders!} ${totalOrders == 1 ? 'Order' : 'Orders'}', 
                style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline, color: Colors.green)
              ),
            ]
          )
        ),
      );

    }else{

      return GestureDetector(
        onTap: () {
          
          /// Navigate to "Order" tab
          onChangeNavigationTab(1);

        },
        child: RichText(
          text: TextSpan(
            text: 'Place your ',
            style: Theme.of(context).textTheme.bodyMedium,
            children: const [
              TextSpan(
                text: 'first order',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      );

    }

  }

  Widget get shareYourFirstReviewInstruction {

    if(hasSharedAReview) {

      return ReviewsModalBottomSheet(
        userReviewAssociation: UserReviewAssociation.reviewer,
        trigger: (openBottomModalSheet) => RichText(
          text: TextSpan(
            text: 'Shared ', 
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              TextSpan(
                text: '${totalReviews!} ${totalReviews == 1 ? 'Review' : 'Reviews'}', 
                style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline, color: Colors.green)
              ),
            ]
          )
        ),
      );

    }else{

      return ReviewsModalBottomSheet(
        onCreatedReview: onCreatedReview,
        reviewContentView: ReviewContentView.addingReview,
        userReviewAssociation: UserReviewAssociation.reviewer,
        trigger: (openBottomModalSheet) => RichText(
          text: TextSpan(
            text: 'Share your ',
            style: Theme.of(context).textTheme.bodyMedium,
            children: const [
              TextSpan(
                text: 'first review',
                style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)
              ),
            ]
          )
        ),
      );

    }

  }

  void onCreatedReview() {
    resourceTotals!.totalReviews += 1;
    authProvider.setResourceTotals(resourceTotals!);
  }

  Widget get createYourFirstGroupInstruction {

    Widget instruction;

    if(hasGroupsJoinedAsMember) {

      instruction = RichText(
        text: TextSpan(
          text: 'Joined ', 
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(
              text: '${totalGroupsJoinedAsMember!} ${totalGroupsJoinedAsMember == 1 ? 'Group' : 'Groups'}', 
              style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline, color: Colors.green)
            ),
          ]
        )
      );

    }else{

      instruction = RichText(
        text: TextSpan(
          text: 'Create your ',
          style: Theme.of(context).textTheme.bodyMedium,
          children: const [
            TextSpan(
              text: 'first group',
              style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)
            ),
          ]
        )
      );

    }

    return GestureDetector(
      onTap: () {
        
        /// Navigate to "Groups" tab
        onChangeNavigationTab(3);

      },
      child: instruction
    );

  }

  Widget get _lookingToSellCallToAction {
    return Column(
      children: [

        if(!hasCreatedAStore) ...[

          /// Divider
          const Divider(),
          
          /// Looking To Sell Information
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () {
                
                /// Navigate to "My Stores" tab
                onChangeNavigationTab(2);

              },
              child: RichText(
                text: TextSpan(
                  text: 'Looking to sell? ',
                  style: Theme.of(context).textTheme.bodyMedium,
                  children: [
                    TextSpan(text: '🤑\n', style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 32)),
                    const TextSpan(text: 'Let\'s create your first store', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, decoration: TextDecoration.underline))
                  ]
                )
              ),
            ),
          ),

          /// Divider
          if(hasPlacedAnOrder || hasStoresAsACustomer || hasStoresAsRecentVisitor) ...[
            
            const SizedBox(height: 24,),
            const Divider(height: 0,)

          ]

        ],
      ],
    );
  }

  Widget get _userAssociatedOrders {
    return Column(
      children: [

        if(hasPlacedAnOrder) ...[
        
          /// Spacer
          const SizedBox(height: 16),
        
          /// Orders In Horizontal List View
          UserOrdersInHorizontalListViewInfiniteScroll(
            user: authUser,
            orderContentType: OrderContentType.orderFullContent,
            userOrderAssociation: UserOrderAssociation.customerOrFriend,
          ),

        ],

      ],
    );
  }

  Widget get _storesAssociatedAsCustomer {
    return Column(
      children: [

        if(hasStoresAsACustomer) ...[
        
          /// Spacer
          const SizedBox(height: 16),

          /// Stores In Horizontal List View
          const StoresInHorizontalListViewInfiniteScroll(
            userAssociation: UserAssociation.customer,
          ),

        ],

      ],
    );
  }

  Widget get _storesAssociatedAsRecentVisitor {
    return Column(
      children: [

        if(hasStoresAsRecentVisitor) ...[
        
          /// Spacer
          const SizedBox(height: 16),

          /// Stores In Horizontal List View
          const StoresInHorizontalListViewInfiniteScroll(
            userAssociation: UserAssociation.recentVisitor,
          ),

        ],

      ],
    );
  }

  Widget _addImageBackground({ required Widget child }) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bg_4.png'), 
          fit: BoxFit.cover
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            end: Alignment.topCenter,
            begin: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.8), Colors.black.withOpacity(0.8)],
          ),
        ),
        child: child
      )
    );
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

    return Container(
      color: Colors.white10,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            /// Profile
            _profile,
        
            /// Spacer
            if(!hasCompletedEverything) const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
              child: Column(
                children: [
                  
                  /// Title
                  if(!hasCompletedEverything) const CustomTitleMediumText('Let\'s make that ${constants.appName}'),

                  SizedBox(
                    width: double.infinity,
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 500),
                      child: AnimatedSwitcher(
                        switchInCurve: Curves.easeIn,
                        switchOutCurve: Curves.easeOut,
                        duration: const Duration(milliseconds: 500),
                        child: doesNotHaveResourceTotals
                          ? const CustomCircularProgressIndicator(
                              margin: EdgeInsets.symmetric(vertical: 40),
                              strokeWidth: 2,
                              size: 16
                            )
                          : Column(
                              children: [
                                    
                                if(hasCompletedEverything) Column(
                                    children: [

                                      /// Place Order Button
                                      _placeOrderButton,
                                      
                                    ]
                                ),
                    
                                if(!hasCompletedEverything) Stack(
                                  children: [
                                    
                                    _milestones,

                                  ],
                                ),

                              ]
                            )
                      )
                    )
                  ),

                  /// Looking To Sell
                  _lookingToSellCallToAction,

                ]
              )
            ),

            /// User Associated Orders - Associated as Customer / Friend
            _userAssociatedOrders,

            /// Stores Associated As Customer
            _storesAssociatedAsCustomer,

            /// Stores Associated As Recent Visitor
            _storesAssociatedAsRecentVisitor,

            /// Spacer
            const SizedBox(height: 100),
            
          ],
        ),
      ),
    );
  }
}