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

  const AddressCardsInVerticalView({
    super.key,
    required this.user
  });

  @override
  State<AddressCardsInVerticalView> createState() => _AddressCardsInVerticalViewState();
}

class _AddressCardsInVerticalViewState extends State<AddressCardsInVerticalView> {

  bool isLoading = false;
  List<Address> addresses = [];

  User get user => widget.user;
  void _startLoader() => setState(() => isLoading = true);
  void _stopLoader() => setState(() => isLoading = false);
  UserProvider get userProvider => Provider.of<UserProvider>(context, listen: false);

  @override
  void initState() {
    super.initState();
    _requestShowAddresses();
  }

  _requestShowAddresses() {

    _startLoader();

    userProvider.setUser(user).userRepository.showAddresses(
      types: [AddressType.home, AddressType.work]
    ).then((response) async {

      if(response.statusCode == 200) {

        setState(() {

          final responseBody = jsonDecode(response.body);
          addresses = (responseBody['data'] as List).map((address) => Address.fromJson(address)).toList();

        });

      }

    }).catchError((error) {

      SnackbarUtility.showErrorMessage(message: 'Can\'t show addresses');

    }).whenComplete((){

      _stopLoader();

    });

  }

  void onCreatedAddress(Address updatedAddress) {
    setState(() {
      addresses.add(updatedAddress);
    });
  }

  void onUpdatedAddress(Address updatedAddress) {
    setState(() {
      final int index = addresses.indexWhere((address) => address.id == updatedAddress.id);
      addresses[index] = updatedAddress;
    });
  }

  void onDeletedAddress(Address deletedAddress) {
    setState(() {
      addresses.removeWhere((address) => address.id == deletedAddress.id);
    });
  }

  @override
  Widget build(BuildContext context) {

    /// Get the size of the screen
    final Size size = MediaQuery.of(context).size;

    return AnimatedSize(
      clipBehavior: Clip.none,
      duration: const Duration(milliseconds: 500),
      child: isLoading ? const CustomCircularProgressIndicator() : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
    
            ...addresses.map((address) {
              
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: CreateOrUpdateAddressModalBottomSheet(
                  user: user,
                  address: address,
                  onUpdatedAddress: onUpdatedAddress,
                  onDeletedAddress: () => onDeletedAddress(address),
                  trigger: (openBottomModalSheet) => SizedBox(
                    /// Occupy 80% of the screen width
                    width: size.width * 0.8,
                    child: AddressCard(
                      user: user,
                      address: address
                    )
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