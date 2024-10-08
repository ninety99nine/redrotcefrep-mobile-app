import 'package:perfect_order/core/shared_models/user.dart';
import 'package:perfect_order/core/shared_widgets/button/custom_elevated_button.dart';
import 'package:perfect_order/features/products/widgets/create_or_update_product_form/create_or_update_product_form.dart';
import 'package:perfect_order/features/user/providers/user_provider.dart';
import 'package:perfect_order/features/user/widgets/user_profile/update_user_profile/update_user_profile_form.dart';
import '../../../../../core/shared_widgets/text/custom_title_medium_text.dart';
import '../../../../../core/shared_widgets/text/custom_body_text.dart';
import 'package:perfect_order/features/products/models/product.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpdateUserProfileContent extends StatefulWidget {
  
  final User user;
  final bool showingFullPage;
  final Function(User)? onUpdatedUser;

  const UpdateUserProfileContent({
    super.key,
    required this.user,
    this.onUpdatedUser,
    this.showingFullPage = false
  });

  @override
  State<UpdateUserProfileContent> createState() => _UpdateUserProfileContentState();
}

class _UpdateUserProfileContentState extends State<UpdateUserProfileContent> {

  bool isSubmitting = false;
  User get user => widget.user;
  bool disableFloatingActionButton = false;
  double get topPadding => showingFullPage ? 32 : 0;
  bool get showingFullPage => widget.showingFullPage;
  Function(User)? get onUpdatedUser => widget.onUpdatedUser;
  UserProvider get userProvider => Provider.of<UserProvider>(context, listen: false);

  /// This allows us to access the state of UpdateStoreForm widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<UpdateUserProfileFormState> _updateUserProfileFormState = GlobalKey<UpdateUserProfileFormState>();

  /// Content to show based on the specified view
  Widget get content {
    
    return UpdateUserProfileForm(
      user: user,
      onSubmitting: onSubmitting,
      onUpdatedUser: _onUpdatedUser,
      key: _updateUserProfileFormState,
    );

  }

  void onSubmitting(status) {
    setState(() {
      isSubmitting = status;
      disableFloatingActionButton = status;
    });
  }

  void _onUpdatedUser(User user){
    
    /// Close the bottom modal sheet
    Get.back();

    if(onUpdatedUser != null) onUpdatedUser!(user);

  }

  /// Floating action button widget
  Widget get floatingActionButton {

    return CustomElevatedButton(
      width: 120,
      'Save Changes',
      isLoading: isSubmitting,
      onPressed: floatingActionButtonOnPressed,
    );

  }

  /// Action to be called when the floating action button is pressed 
  void floatingActionButtonOnPressed() {

    /// If we have disabled the floating action button, then do nothing
    if(disableFloatingActionButton) return;

    if(_updateUserProfileFormState.currentState != null) {
      _updateUserProfileFormState.currentState!.requestUpdateUser();
    }

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
              
              /// Wrap Padding around the following:
              /// Title, Subtitle, Filters
              Padding(
                padding: EdgeInsets.only(top: 20 + topPadding, left: 32, bottom: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
            
                    /// Title
                    CustomTitleMediumText('Edit Profile', padding: EdgeInsets.only(bottom: 8),),
                    
                    /// Subtitle
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CustomBodyText('Want to make changes?'),
                    ),
                    
                  ],
                ),
              ),

              /// Content
              Expanded(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  alignment: Alignment.topCenter,
                  width: double.infinity,
                  color: Colors.white,
                  child: content,
                ),
              )
          
            ],
          ),
  
          /// Expand Icon
          if(!showingFullPage) Positioned(
            top: 8,
            right: 50,
            child: IconButton(
              icon: const Icon(Icons.open_in_full_rounded, size: 24, color: Colors.grey),
              onPressed: () {
                
                /// Close the Modal Bottom Sheet
                Get.back();

                /// Set the user
                //userProvider.setStore(user);
                
                /// Navigate to the page
                /// Get.toNamed(ReviewsPage.routeName);
              
              }
            ),
          ),
  
          /// Cancel Icon
          Positioned(
            right: 10,
            top: 8 + topPadding,
            child: IconButton(
              icon: Icon(Icons.cancel, size: 28, color: Theme.of(context).primaryColor,),
              onPressed: () => Get.back()
            ),
          ),
  
          /// Floating Button
          AnimatedPositioned(
            right: 10,
            duration: const Duration(milliseconds: 500),
            top: 56 + topPadding,
            child: floatingActionButton
          )
        ],
      ),
    );
  }
}