import 'dart:io';

import 'package:bonako_demo/features/Image_picker/widgets/image_picker_modal_bottom_sheet/image_picker_modal_bottom_sheet.dart';
import 'package:bonako_demo/features/Image_picker/enums/image_picker_enums.dart';
import 'package:bonako_demo/features/home/providers/home_provider.dart';
import 'package:bonako_demo/features/products/models/product.dart';
import 'package:bonako_demo/features/products/providers/product_provider.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import 'package:bonako_demo/features/stores/providers/store_provider.dart';
import 'package:bonako_demo/features/stores/services/store_services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class ProductPhoto extends StatefulWidget {

  final double? radius;
  final Product? product;
  final bool canChangePhoto;
  final ShoppableStore store;
  final Function(XFile)? onPickedFile;

  const ProductPhoto({
    Key? key,
    this.radius,
    this.onPickedFile,
    required this.store,
    required this.product,
    this.canChangePhoto = false,
  }) : super(key: key);

  @override
  State<ProductPhoto> createState() => _ProductPhotoState();
}

class _ProductPhotoState extends State<ProductPhoto> {

  XFile? file;
  XFile? fileUrl;
  bool get hasFile => file != null;
  String? get filePath => file?.path;
  double? get radius => widget.radius;
  bool get hasProduct => product != null;
  Product? get product => widget.product;
  ShoppableStore get store => widget.store;
  bool get doesNotHaveFile => file == null;
  bool get canChangePhoto => widget.canChangePhoto;
  bool get doesNotHavePhoto => product?.photo == null;
  bool get hasPhoto => hasProduct && product!.photo != null;

  Function(XFile)? get onPickedFile => widget.onPickedFile;
  bool get isShowingStorePage => storeProvider.isShowingStorePage;
  bool get hasSelectedMyStores => homeProvider.hasSelectedMyStores;
  bool get canAccessAsTeamMember => StoreServices.canAccessAsTeamMember(store);
  bool get teamMemberWantsToViewAsCustomer => store.teamMemberWantsToViewAsCustomer;
  HomeProvider get homeProvider => Provider.of<HomeProvider>(context, listen: false);
  bool get isTeamMemberWhoHasJoined => StoreServices.isTeamMemberWhoHasJoined(store);
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: true);
  bool get showEditableMode => (isShowingStorePage || hasSelectedMyStores) && isTeamMemberWhoHasJoined && !teamMemberWantsToViewAsCustomer;

  Widget get placeholderPhoto {

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade100,
      child: Icon(Icons.store_mall_directory_outlined, size: 16, color: Colors.grey.shade400,)
    );

  }

  ImageProvider<Object>? get backgroundImage {
    if(hasFile) {

      return FileImage(File(filePath!));

    }else if(hasPhoto) {

      return CachedNetworkImageProvider(
        product!.photo!,
      );

    }
    
    return null;
  }

  Widget get editablePhoto {
    return ImagePickerModalBottomSheet(
      radius: radius,
      title: 'Product Photo',
      subtitle: 'Your customers love quality photos 👌',
      fileName: 'photo',
      onSubmittedFile: (file, response) {

        final responseBody = jsonDecode(response.body);
        
        /// Set the updated photo from the response
        setState(() => product!.photo = responseBody['photo']);

      },
      onDeletedFile: (response) {
        if(response.statusCode == 200) {
        
          /// Unset the photo
          setState(() => product!.photo = null);

        }
      },
      onPickedFile: (file) {
        setState(() {
          this.file = file;
          if(onPickedFile != null) onPickedFile!(file);
        });
      },
      submitMethod: SubmitMethod.post,
      submitUrl: product?.links.updatePhoto.href,
      deleteUrl: product?.links.deletePhoto.href,
      trigger: doesNotHaveFile && doesNotHavePhoto ? null : (openBottomModalSheet) => GestureDetector(
        onTap: () {
           
          /// If we can change the photo
          if(canChangePhoto) {

            openBottomModalSheet();

          }

        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300,),
            borderRadius: BorderRadius.circular(radius ?? 20)
          ),
          child: Stack(
            children: [
              
              CircleAvatar(
                radius: widget.radius,
                backgroundImage: backgroundImage,
                backgroundColor: Colors.grey.shade100,
              ),

              if(canChangePhoto) Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(radius ?? 20)
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.mode_edit_outlined, color: Colors.white)    
                ),
              )
              
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return hasFile || hasPhoto || showEditableMode ? editablePhoto : placeholderPhoto;
  }
}