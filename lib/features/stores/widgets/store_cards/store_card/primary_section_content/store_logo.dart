import 'dart:convert';

import 'package:bonako_demo/features/Image_picker/widgets/image_picker_modal_bottom_sheet/image_picker_modal_bottom_sheet.dart';
import 'package:bonako_demo/features/Image_picker/enums/image_picker_enums.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/instance_manager.dart';
import '../../../../services/store_services.dart';
import '../../../../models/shoppable_store.dart';
import 'package:flutter/material.dart';

class StoreLogo extends StatefulWidget {

  final double? radius;
  final bool canChangeLogo;
  final ShoppableStore store;

  const StoreLogo({
    Key? key,
    this.radius,
    required this.store,
    this.canChangeLogo = false,
  }) : super(key: key);

  @override
  State<StoreLogo> createState() => _StoreLogoState();
}

class _StoreLogoState extends State<StoreLogo> {

  bool get hasLogo => store.logo != null;
  ShoppableStore get store => widget.store;
  bool get canChangeLogo => widget.canChangeLogo;
  bool get doesNothaveLogo => store.logo == null;

  @override
  Widget build(BuildContext context) {

    /**
     * The onTap() method can be used with an Enum to decide
     * the type of callback that should be executed. For now
     * we just want to navigate to show the store
     */
    return ImagePickerModalBottomSheet(
      fileName: 'logo',
      onSubmittedFile: (file, response) {

        final responseBody = jsonDecode(response.body);
        
        /// Set the updated logo from the response
        setState(() => store.logo = responseBody['logo']);

      },
      onDeletedFile: (response) {
        if(response.statusCode == 200) {
        
          /// Unset the logo
          setState(() => store.logo = null);

        }
      },
      submitMethod: SubmitMethod.post,
      submitUrl: store.links.updateLogo.href,
      deleteUrl: hasLogo ? store.links.deleteLogo.href : null,
      trigger: doesNothaveLogo ? null : (openBottomModalSheet) => GestureDetector(
        onTap: () {
           
          /// If we can change the logo
          if(canChangeLogo) {

            openBottomModalSheet();

          /// If we cannot change the logo
          }else{
            
            StoreServices.navigateToStorePage(store);

          }

        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300,),
            borderRadius: BorderRadius.circular(50)
          ),
          child: Stack(
            children: [
              CircleAvatar(
                radius: widget.radius,
                backgroundColor: Colors.grey.shade100,
                backgroundImage: store.logo == null ? null : CachedNetworkImageProvider(
                  store.logo!,
                ),
              ),

              if(canChangeLogo) Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(50)
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.mode_edit_outlined, color: Colors.white,)     
                ),
              )
              
            ],
          ),
        ),
      ),
    );
  }
}