import 'package:bonako_demo/core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/Image_picker/widgets/image_picker_modal_bottom_sheet/image_picker_modal_bottom_sheet.dart';
import 'package:bonako_demo/features/Image_picker/enums/image_picker_enums.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../../../services/store_services.dart';
import '../../../../models/shoppable_store.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class StoreCoverPhoto extends StatefulWidget {

  final ShoppableStore store;
  final bool canChangeCoverPhoto;

  const StoreCoverPhoto({
    Key? key,
    required this.store,
    this.canChangeCoverPhoto = false,
  }) : super(key: key);

  @override
  State<StoreCoverPhoto> createState() => _StoreCoverPhotoState();
}

class _StoreCoverPhotoState extends State<StoreCoverPhoto> {

  ShoppableStore get store => widget.store;
  bool get hasCoverPhoto => store.hasCoverPhoto;
  bool get canChangeCoverPhoto => widget.canChangeCoverPhoto;
  bool get doesNotHaveCoverPhoto => store.doesNotHaveCoverPhoto;

  Widget placeholderCoverPhoto(openBottomModalSheet) {
    return DottedBorder(
        radius: const Radius.circular(8.0),
        borderType: BorderType.RRect,
        strokeCap: StrokeCap.butt,
        padding: EdgeInsets.zero,
        dashPattern: const [6, 3],
        color: Colors.grey,
        strokeWidth: 1,
        child: Material(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          color:Colors.grey.shade100,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => openBottomModalSheet(),
            child: Ink(
              child: Container(
                height: 100,
                width: double.infinity,
                /// Note that we use "11px" instead of "12px" because we want 
                /// to accomodate the 1px from the border strokeWidth
                padding: const EdgeInsets.all(11),
                child: Align(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      /// Icon
                      Icon(Icons.photo_outlined, size: 32, color: Colors.grey.shade400),
                      
                      /// Spacer
                      const SizedBox(width: 8),
                      
                      /// Text
                      const CustomBodyText('Add Cover Photo')
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
  }

  Widget coverPhoto(openBottomModalSheet) {
    return GestureDetector(
      onTap: () {
        /// If we can change the cover photo
        if (canChangeCoverPhoto) {
          openBottomModalSheet();
        /// If we cannot change the cover photo
        } else {
          StoreServices.navigateToStorePage(store);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: CachedNetworkImage(
                placeholder: (context, url) =>
                    const CustomCircularProgressIndicator(),
                imageUrl: store.coverPhoto!,
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),
            ),
            if (canChangeCoverPhoto)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.mode_edit_outlined,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    /**
     * The onTap() method can be used with an Enum to decide
     * the type of callback that should be executed. For now
     * we just want to navigate to show the store
     */
    return ImagePickerModalBottomSheet(
      title: 'Cover Photo',
      subtitle: 'Your customers love quality cover photos 👌',
      fileName: 'cover_photo',
      onSubmittedFile: (file, response) {
        
        /// Set the updated cover photo from the response
        setState(() => store.coverPhoto = response.data['coverPhoto']);

      },
      onDeletedFile: (response) {
        if(response.statusCode == 200) {
        
          /// Unset the cover photo
          setState(() => store.coverPhoto = null);

        }
      },
      submitMethod: SubmitMethod.post,
      submitUrl: store.links.updateCoverPhoto.href,
      deleteUrl: hasCoverPhoto ? store.links.deleteCoverPhoto.href : null,
      trigger: doesNotHaveCoverPhoto 
        ? (openBottomModalSheet) => placeholderCoverPhoto(openBottomModalSheet)
        : (openBottomModalSheet) => coverPhoto(openBottomModalSheet)
      );
  }
}