import 'package:bonako_demo/core/shared_models/user.dart';
import 'package:bonako_demo/core/shared_widgets/button/custom_elevated_button.dart';
import 'package:bonako_demo/features/addresses/providers/address_provider.dart';
import 'package:bonako_demo/features/addresses/widgets/create_or_update_address/create_or_update_address_form.dart';
import '../../../../../core/shared_widgets/text/custom_title_medium_text.dart';
import '../../../../../core/shared_widgets/text/custom_body_text.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../models/address.dart';
import 'package:get/get.dart';

class CreateOrUpdateAddressContent extends StatefulWidget {
  
  final User user;
  final Address? address;
  final bool showingFullPage;
  final Function()? onDeletedAddress;
  final Function(Address)? onCreatedAddress;
  final Function(Address)? onUpdatedAddress;

  const CreateOrUpdateAddressContent({
    super.key,
    this.address,
    required this.user,
    this.onDeletedAddress,
    this.onCreatedAddress,
    this.onUpdatedAddress,
    this.showingFullPage = false
  });

  @override
  State<CreateOrUpdateAddressContent> createState() => _CreateOrUpdateAddressContentState();
}

class _CreateOrUpdateAddressContentState extends State<CreateOrUpdateAddressContent> {

  bool isSubmitting = false;
  User get user => widget.user;
  bool get isEditing => address != null;
  Address? get address => widget.address;
  bool disableFloatingActionButton = false;
  double get topPadding => showingFullPage ? 32 : 0;
  bool get showingFullPage => widget.showingFullPage;
  Function()? get onDeletedAddress => widget.onDeletedAddress;
  Function(Address)? get onCreatedAddress => widget.onCreatedAddress;
  Function(Address)? get onUpdatedAddress => widget.onUpdatedAddress;
  AddressProvider get addressProvider => Provider.of<AddressProvider>(context, listen: false);

  /// This allows us to access the state of UpdateStoreForm widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CreateOrUpdateAddressFormState> _createOrUpdateAddressFormState = GlobalKey<CreateOrUpdateAddressFormState>();

  /// Content to show based on the specified view
  Widget get content {
    
    return CreateOrUpdateAddressForm(
      user: user,
      address: address,
      onDeleting: onDeleting,
      onSubmitting: onSubmitting,
      onDeletedAddress: _onDeletedAddress,
      onCreatedAddress: _onCreatedAddress,
      onUpdatedAddress: _onUpdatedAddress,
      key: _createOrUpdateAddressFormState,
    );

  }

  void onDeleting(status) {
    setState(() {
      disableFloatingActionButton = status;
    });
  }

  void onSubmitting(status) {
    setState(() {
      isSubmitting = status;
      disableFloatingActionButton = status;
    });
  }

  void _onCreatedAddress(Address address){
    
    /// Close the bottom modal sheet
    Get.back();

    if(onCreatedAddress != null) onCreatedAddress!(address);

  }

  void _onUpdatedAddress(Address address){
    
    /// Close the bottom modal sheet
    Get.back();

    if(onUpdatedAddress != null) onUpdatedAddress!(address);

  }

  void _onDeletedAddress(){
    
    /// Close the bottom modal sheet
    Get.back();

    if(onDeletedAddress != null) onDeletedAddress!();

  }

  /// Floating action button widget
  Widget get floatingActionButton {

    return CustomElevatedButton(
      width: 120,
      'Save Changes',
      color: Colors.green,
      isLoading: isSubmitting,
      onPressed: floatingActionButtonOnPressed,
    );

  }

  /// Action to be called when the floating action button is pressed 
  void floatingActionButtonOnPressed() {

    /// If we should disable the floating action button, then do nothing
    if(disableFloatingActionButton) return;

    if(_createOrUpdateAddressFormState.currentState != null) {
      _createOrUpdateAddressFormState.currentState!.submit();
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
                  children: [
            
                    /// Title
                    CustomTitleMediumText('${isEditing ? 'Edit' : 'Create'} Address', padding: const EdgeInsets.only(bottom: 8),),
                    
                    /// Subtitle
                    const Align(
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
                Navigator.of(context).pop();

                /// Set the address
                //addressProvider.setStore(address);
                
                /// Navigate to the page
                //Navigator.of(context).pushNamed(ReviewsPage.routeName);
              
              }
            ),
          ),
  
          /// Cancel Icon
          Positioned(
            right: 10,
            top: 8 + topPadding,
            child: IconButton(
              icon: Icon(Icons.cancel, size: 28, color: Theme.of(context).primaryColor,),
              onPressed: () => Navigator.of(context).pop(),
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