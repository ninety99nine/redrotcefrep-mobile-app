import 'package:perfect_order/features/Image_picker/widgets/image_picker_modal_bottom_sheet/image_picker_modal_bottom_sheet.dart';
import 'package:perfect_order/core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import 'package:perfect_order/core/shared_widgets/rainbow_widgets/circle_rainbow.dart';
import 'package:perfect_order/features/Image_picker/enums/image_picker_enums.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:perfect_order/core/shared_models/user.dart';
import 'package:perfect_order/core/utils/dialer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'dart:io';

class UserProfilePhoto extends StatefulWidget {

  final User? user;
  final bool canCall;
  final double radius;
  final bool isLoading;
  final double thickness;
  final double canCallSize;
  final bool canChangePhoto;
  final bool showEditableMode;
  final Function()? onDeletedFile;
  final bool canShowEditPhotoIcon;
  final double placeholderIconSize;
  final double canCallRightPosition;
  final double canCallBottomPosition;
  final Function(XFile)? onPickedFile;
  final Function(XFile, dio.Response)? onSubmittedFile;

  const UserProfilePhoto({
    Key? key,
    this.radius = 40,
    this.onPickedFile,
    this.thickness = 4,
    this.onDeletedFile,
    required this.user,
    this.canCall = true,
    this.onSubmittedFile,
    this.canCallSize = 48,
    this.isLoading = false,
    this.canChangePhoto = true,
    this.showEditableMode = false,
    this.canCallRightPosition = 0,
    this.placeholderIconSize = 100,
    this.canCallBottomPosition = 10,
    this.canShowEditPhotoIcon = false,
  }) : super(key: key);

  @override
  State<UserProfilePhoto> createState() => _UserProfilePhotoState();
}

class _UserProfilePhotoState extends State<UserProfilePhoto> {

  XFile? file;
  XFile? fileUrl;
  User? get user => widget.user;
  bool get hasUser => user != null;
  bool get hasFile => file != null;
  String? get filePath => file?.path;
  double get radius => widget.radius;
  bool get canCall => widget.canCall;
  bool get isLoading => widget.isLoading;
  double get thickness => widget.thickness;
  bool get doesNotHaveFile => file == null;
  double get canCallSize => widget.canCallSize;
  bool get hasPhoto => user?.profilePhoto != null;
  bool get canChangePhoto => widget.canChangePhoto;
  bool get doesNotHavePhoto => user?.profilePhoto == null;
  bool get canShowEditPhotoIcon => widget.canShowEditPhotoIcon;
  double get placeholderIconSize => widget.placeholderIconSize;
  double get canCallRightPosition => widget.canCallRightPosition;
  double get canCallBottomPosition => widget.canCallBottomPosition;

  bool get showEditableMode => widget.showEditableMode;
  Function()? get onDeletedFile => widget.onDeletedFile;
  bool get hasBackgroundImage => backgroundImage != null;
  Function(XFile)? get onPickedFile => widget.onPickedFile;
  Function(XFile, dio.Response)? get onSubmittedFile => widget.onSubmittedFile;

  Widget get placeholder {
    return Icon(Icons.person, size: placeholderIconSize, color: Colors.grey.shade300);
  }

  ImageProvider<Object>? get backgroundImage {
    if(hasFile) {

      return FileImage(File(filePath!));

    }else if(hasPhoto) {

      return CachedNetworkImageProvider(user!.profilePhoto!);

    }
    
    return null;
  }

  Widget get editablePhoto {
    return ImagePickerModalBottomSheet(
      radius: radius,
      title: 'Profile Photo',
      fileName: 'profile_photo',
      subtitle: 'Everyone loves quality photos 👌',
      onSubmittedFile: (file, response) {
        
        /// Set the updated photo from the file system
        /// We could use the upadated photo from the
        /// request but this would be slower to load
        /// e.g the following takes time to show up
        /// since the photo must be downloaded:
        /// 
        /// user!.photo = response.data['profile_photo']
        setState(() {

          /// Set the file
          this.file = file;

            /// Set the profile photo
          user!.profilePhoto = file.path;

          /// Notify the parent widget
          if(onSubmittedFile != null) onSubmittedFile!(file, response);

        });

      },
      onDeletedFile: (response) {
        if(response.statusCode == 200) {
        
          setState(() {

            /// Unset the file
            file = null;

            /// Unset the profile photo
            user!.profilePhoto = null;

            /// Notify the parent widget
            if(onDeletedFile != null) onDeletedFile!();

          });

        }
      },
      onPickedFile: (file) {
        setState(() {
          this.file = file;
          user!.profilePhoto = file.path;

            /// Notify the parent widget
          if(onPickedFile != null) onPickedFile!(file);
        });
      },
      submitMethod: SubmitMethod.post,
      submitUrl: user?.links.updateProfilePhoto.href,
      deleteUrl: user?.links.deleteProfilePhoto.href,
      trigger: (openBottomModalSheet) => GestureDetector(
        onTap: () {
           
          /// If we can change the photo
          if(canChangePhoto) {

            openBottomModalSheet();

          }

        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300,),
            borderRadius: BorderRadius.circular(radius + thickness)
          ),
          child: Stack(
            children: [
              
              CustomCircleRainbow(
                thickness: thickness,
                child: CircleAvatar(
                  radius: radius,
                  backgroundImage: backgroundImage,
                  backgroundColor: Colors.grey.shade100,
                  child: isLoading
                    ? const CustomCircularProgressIndicator(
                      strokeWidth: 1,
                      size: 16,
                    )
                    : (hasBackgroundImage ? null : placeholder)
                ),
              ),

              /// Edit Profile Photo
              if(canShowEditPhotoIcon && canChangePhoto) Positioned.fill(
                child: Container(
                  margin: EdgeInsets.all(hasBackgroundImage ? thickness : 8),  /// Add margin to add space around the overlay
                  decoration: BoxDecoration(
                    color: hasBackgroundImage ? Colors.black.withOpacity(0.5) : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(radius)
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.mode_edit_outlined, color: hasBackgroundImage ? Colors.white : Colors.black)    
                ),
              ),

              /// Call User
              if(hasUser && canCall) Positioned(
                right: canCallRightPosition,
                bottom: canCallBottomPosition,
                child: Container(
                  width: canCallSize,
                  height: canCallSize,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.green.shade300, width: 2),
                  ),
                  child: IconButton(
                    splashColor: Colors.green,
                    highlightColor: Colors.green,
                    onPressed: () {
                      DialerUtility.dial(number: user!.mobileNumber!.withoutExtension);
                    },
                    icon: const Icon(Icons.call, color: Colors.white,),
                  ),
                )
              )
              
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return editablePhoto;
  }
}