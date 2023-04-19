import 'package:bonako_demo/core/shared_models/user.dart';
import 'package:bonako_demo/core/shared_widgets/button/custom_text_button.dart';
import 'package:bonako_demo/core/shared_widgets/cards/custom_card.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:bonako_demo/features/addresses/enums/address_enums.dart';
import 'package:bonako_demo/features/authentication/providers/auth_provider.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './../models/address.dart';

class AddressCard extends StatefulWidget {

  final User user;
  final bool isSelected;
  final Address? address;
  final double elevation;
  final AddressType? addressType;
  final Function()? onEditAddress;

  const AddressCard({
    super.key,
    this.address,
    this.addressType,
    required this.user,
    this.elevation = 2.0,
    this.isSelected = false,
    required this.onEditAddress
  });

  @override
  State<AddressCard> createState() => _AddressCardState();
}

class _AddressCardState extends State<AddressCard> {

  User get user => widget.user;
  Address? get address => widget.address;
  String get firstName => user.firstName;
  bool get isSelected => widget.isSelected;
  double get elevation => widget.elevation;
  Function()? get onEditAddress => widget.onEditAddress;
  bool get isNotMyAddress => user.id != authProvider.user!.id;
  AddressType? get addressType => address?.type ?? widget.addressType;
  AuthProvider get authProvider => Provider.of(context, listen: false);

  Widget get addressContent {
    return Row(
      children: [

        /// Address Content
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              /// Address Title
              Row(
                children: [

                  /// Display Name (Show only if it's not my address)
                  if(isNotMyAddress) CustomTitleSmallText(firstName, margin: const EdgeInsets.only(right: 4),),

                  /// Location Icon + (Home / Work / Friend / Business)
                  if(addressType != null) ...[
                    
                    /// Location Icon
                    Icon(Icons.location_pin, size: 16, color: isSelected ? Colors.grey : Colors.grey.shade400,),
              
                    /// Spacer
                    const SizedBox(width: 4,),
                    
                    /// Address Type e.g Home / Work / Friend / Business
                    CustomTitleSmallText(addressType!.name.capitalize!),

                  ]

                ],
              ),
              
              /// Spacer
              const SizedBox(height: 8,),
        
              /// Address Line e.g Gaborone, Tlokweng, Plot 1234
              CustomBodyText(address?.addressLine ?? 'No address set', lightShade: !isSelected,),
        
            ],
          ),
        ),

        /// Spacer
        const SizedBox(width: 8,),

        /// Icon
        CustomTextButton(
          '',
          prefixIconSize: 20,
          onPressed: onEditAddress,
          prefixIcon: Icons.mode_edit_outlined,
          color: isSelected ? Colors.grey : Colors.grey.shade400
        )

      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      backgroundColor: isSelected ? Colors.green.shade50 : null,
      borderColor: isSelected ? Colors.green : null,
      elevation: elevation,
      child: addressContent,
    );
  }
}