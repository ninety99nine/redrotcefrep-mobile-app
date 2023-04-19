import 'package:bonako_demo/core/shared_models/user.dart';
import 'package:bonako_demo/core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import 'package:bonako_demo/core/utils/snackbar.dart';
import 'package:bonako_demo/features/addresses/enums/address_enums.dart';
import 'package:bonako_demo/features/addresses/widgets/create_or_update_address/create_or_update_address_modal_bottom_sheet/create_or_update_address_modal_bottom_sheet.dart';
import 'package:bonako_demo/features/addresses/widgets/address_card.dart';
import 'package:bonako_demo/features/user/providers/user_provider.dart';
import 'package:collection/collection.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import './../models/address.dart';
import 'dart:convert';

class AddressCardsInVerticalView extends StatefulWidget {

  final User user;
  final bool selectable;
  final double elevation;
  final double screenWidthPercentage;
  final Function(bool)? onLoadingAddresses;
  final Function(Address?)? onSelectedAddress;

  const AddressCardsInVerticalView({
    super.key,
    required this.user,
    this.elevation = 2.0,
    this.onSelectedAddress,
    this.selectable = false,
    this.onLoadingAddresses,
    this.screenWidthPercentage = 0.8,
  });

  @override
  State<AddressCardsInVerticalView> createState() => _AddressCardsInVerticalViewState();
}

class _AddressCardsInVerticalViewState extends State<AddressCardsInVerticalView> {

  bool isLoading = false;
  Address? selectedAddress;
  List<Address> addresses = [];

  User get user => widget.user;
  bool get selectable => widget.selectable;
  double get elevation => widget.elevation;
  void _startLoader() => setState(() => isLoading = true);
  void _stopLoader() => setState(() => isLoading = false);
  double get screenWidthPercentage => widget.screenWidthPercentage;
  Function(bool)? get onLoadingAddresses => widget.onLoadingAddresses;
  Function(Address?)? get onSelectedAddress => widget.onSelectedAddress;
  UserProvider get userProvider => Provider.of<UserProvider>(context, listen: false);

  @override
  void initState() {
    super.initState();
    _requestShowAddresses();
  }

  _requestShowAddresses() {

    _startLoader();
    if(onLoadingAddresses != null) onLoadingAddresses!(true);

    userProvider.setUser(user).userRepository.showAddresses(
      types: [AddressType.home, AddressType.work]
    ).then((response) async {

      if(response.statusCode == 200) {

        setState(() {

          final responseBody = jsonDecode(response.body);
          addresses = (responseBody['data'] as List).map((address) => Address.fromJson(address)).toList();

          /// Check if there is any address
          if(addresses.isNotEmpty) {

            /// Set the first address as selected address
            _onSelectedAddress(addresses.first);

          }else{
            
            /// Set the selected address to null
            _onSelectedAddress(null);

          }

        });

      }

    }).catchError((error) {

      SnackbarUtility.showErrorMessage(message: 'Can\'t show addresses');

    }).whenComplete((){

      _stopLoader();
      if(onLoadingAddresses != null) onLoadingAddresses!(false);

    });

  }

  void onCreatedAddress(Address createdAddress) {

    /// Add the created address to the list
    addresses.add(createdAddress);

    /// Set the created address as selected address
    _onSelectedAddress(createdAddress);

  }

  void onUpdatedAddress(Address updatedAddress) {

    /// Find the index of the updated address
    final int index = addresses.indexWhere((address) => address.id == updatedAddress.id);

    /// Update the address
    addresses[index] = updatedAddress;

    /// Set the created address as selected address
    _onSelectedAddress(updatedAddress);

  }

  void onDeletedAddress(Address deletedAddress) {
    setState(() {

      addresses.removeWhere((address) => address.id == deletedAddress.id);

      /// Check if the deleted address is the selected address
      if(selectedAddress?.id == deletedAddress.id) {

        /// Set the selected address to null
        selectedAddress = null;

      }
      
    });
  }

  void _onSelectedAddress(Address? selectedAddress) {
    setState(() {
      
      /// Set the selected address
      this.selectedAddress = selectedAddress;

      /// If the onSelectedAddress is provided
      if(onSelectedAddress != null) {

        /// Notify the parent widget
        onSelectedAddress!(selectedAddress);

      }

    });
  }

  @override
  Widget build(BuildContext context) {

    /// Get the size of the screen
    final Size size = MediaQuery.of(context).size;

    return AnimatedSize(
      clipBehavior: Clip.none,
      duration: const Duration(milliseconds: 500),
      child: isLoading ? const CustomCircularProgressIndicator(
        margin: EdgeInsets.symmetric(vertical: 16),
      ) : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
    
            ...addresses.map((address) {
              
              /// Address Card
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: CreateOrUpdateAddressModalBottomSheet(
                  user: user,
                  address: address,
                  onUpdatedAddress: onUpdatedAddress,
                  onDeletedAddress: () => onDeletedAddress(address),
                  trigger: (openBottomModalSheet) => GestureDetector(
                    onTap: () {

                      /// This means that the address card is selectable
                      if(selectable) {

                        /// Set the selected address
                        _onSelectedAddress(address);
                        
                      }else{

                        /// Open the bottom modal sheet
                        openBottomModalSheet();

                      }

                    },
                    child: SizedBox(
                      /// Occupy a percentage of the screen width
                      width: size.width * screenWidthPercentage,
                      child: AddressCard(
                        user: user,
                        address: address,
                        elevation: elevation,
                        onEditAddress: () => openBottomModalSheet(),
                        isSelected: selectable && address.id == selectedAddress?.id
                      )
                    ),
                  ),
                ),
              );
    
            }).toList(),
    
            /// Add Address Button
            CreateOrUpdateAddressModalBottomSheet(
              user: user,
              onCreatedAddress: onCreatedAddress,
              trigger: (openBottomModalSheet) => IconButton(
                onPressed: () => openBottomModalSheet(),
                icon: Icon(Icons.add_circle, size: 28, color: Colors.grey.shade400,),
              ),
            ),
    
          ],
        ),
      ),
    );
  }
}