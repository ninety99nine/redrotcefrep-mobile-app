import 'package:perfect_order/features/Image_picker/widgets/image_picker_modal_bottom_sheet/image_picker_modal_bottom_sheet.dart';
import 'package:perfect_order/core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import 'package:perfect_order/features/Image_picker/enums/image_picker_enums.dart';
import 'package:perfect_order/core/shared_widgets/full_screen_image/main.dart';
import 'package:perfect_order/features/stores/providers/store_provider.dart';
import 'package:perfect_order/features/stores/services/store_services.dart';
import 'package:perfect_order/features/stores/models/shoppable_store.dart';
import 'package:perfect_order/features/home/providers/home_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'dart:io';

enum PhotoShape {
  circle,
  rectangle
}

enum ChangePhotoType {
  none,
  editIconOverImage,
  editIconONextToImage
}

class StoreLogo extends StatefulWidget {

  final double? height;
  final double? radius;
  final ShoppableStore store;
  final Function()? onDeletedFile;
  final Function(XFile)? onPickedFile;
  final ChangePhotoType changePhotoType;
  final Function(String)? onSubmittedFile;
  final PhotoShape photoShape;

  const StoreLogo({
    Key? key,
    this.height,
    this.radius,
    this.onPickedFile,
    this.onDeletedFile,
    required this.store,
    this.onSubmittedFile,
    this.changePhotoType = ChangePhotoType.none,
    this.photoShape = PhotoShape.circle

  }) : super(key: key);

  @override
  State<StoreLogo> createState() => _StoreLogoState();
}

class _StoreLogoState extends State<StoreLogo> {

  XFile? file;
  XFile? fileUrl;
  late double height;
  late double radius;
  late ShoppableStore store;

  bool get hasFile => file != null;
  String? get filePath => file?.path;
  bool get hasPhoto => store.logo != null;
  bool get doesNotHaveFile => file == null;
  bool get hasEmoji => store.emoji != null;
  PhotoShape get photoShape => widget.photoShape;
  bool get doesNotHavePhoto => store.logo == null;
  Function()? get onDeletedFile => widget.onDeletedFile;
  bool get isCircleShape => photoShape == PhotoShape.circle;
  ChangePhotoType get changePhotoType => widget.changePhotoType;
  bool get isRectangleShape => photoShape == PhotoShape.rectangle;
  Function(String)? get onSubmittedFile => widget.onSubmittedFile;
  bool get photoIsAnAssetFile => store.logo?.startsWith('http') == false;
  bool get photoIsANetworkFile => store.logo?.startsWith('http') == true;

  Function(XFile)? get onPickedFile => widget.onPickedFile;
  bool get isShowingStorePage => storeProvider.isShowingStorePage;
  bool get hasSelectedMyStores => homeProvider.hasSelectedMyStores;
  bool get canAccessAsTeamMember => StoreServices.canAccessAsTeamMember(store);
  bool get teamMemberWantsToViewAsCustomer => store.teamMemberWantsToViewAsCustomer;
  HomeProvider get homeProvider => Provider.of<HomeProvider>(context, listen: false);
  bool get isTeamMemberWhoHasJoined => StoreServices.isTeamMemberWhoHasJoined(store);
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: true);
  bool get showEditableMode => (isShowingStorePage || hasSelectedMyStores) && isTeamMemberWhoHasJoined && !teamMemberWantsToViewAsCustomer;

  @override
  void initState() {
    super.initState();
    store = widget.store;
    
    if(widget.radius == null) {
      if(isCircleShape) {
        radius = 40;
      }else if(isRectangleShape) {
        radius = 16;
      }
    } else{
      radius = widget.radius!;
    }
    
    if(widget.height == null) {
      if(isRectangleShape) {
        height = 200;
      }
    } else{
      height = widget.height!;
    }
  }

  @override
  void didUpdateWidget(covariant StoreLogo oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() => store = widget.store);
  }

  Widget get placeholderPhoto {

    Widget emoji = Text('${store.emoji}', style: const TextStyle(fontSize: 32));

    Widget noImagePlaceholder = CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade100,
      child: Icon(
        size: 24, 
        Icons.image, 
        color: Colors.grey.shade400
      )
    );

    return hasEmoji ? emoji : noImagePlaceholder;

  }

  Widget trigger(openBottomModalSheet) {

    /// If we don't have a file or photo
    if(doesNotHaveFile && doesNotHavePhoto) {

      Widget child;
      BorderType borderType;

      final Widget icon = Icon(
        Icons.add_photo_alternate_outlined,
        color: Colors.grey.shade400,
        size: 16
      );
      
      if(photoShape == PhotoShape.circle) {

        borderType = BorderType.Circle;

        /// Circle Shape
        child = CircleAvatar(
          radius: radius,
          backgroundColor: Colors.transparent,
          child: icon
        );

      }else{

        borderType = BorderType.RRect;

        /// Rectangle Shape
        child = Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            color: Colors.transparent,
          ),
          child: icon
        );

      }

      return DottedBorder(
        radius: Radius.circular(radius),
        strokeCap: StrokeCap.butt,
        padding: EdgeInsets.zero,
        borderType: borderType,
        dashPattern: const [6, 3],
        color: Colors.grey,
        strokeWidth: 1,
        child: Material(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          color:Colors.grey.shade100,
          child: InkWell(
            borderRadius: BorderRadius.circular(radius),
            onTap: () => openBottomModalSheet(),
            child: Ink(
              child: child
            ),
          ),
        ),
      );

    }else{
      
      Widget child;

      /// Expandable Image
      final Widget expandableImage = Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300,),
          borderRadius: BorderRadius.circular(radius)
        ),
        child: FullScreenWidget(
          backgroundColor: Colors.transparent,
          fullScreenChild: fullScreenImage,
          backgroundIsTransparent: true,
          child: normalImage
        ),
      );

      if(changePhotoType == ChangePhotoType.editIconOverImage)  {
        
        child = Stack(
          children: [
            
            /// Expandable Image
            expandableImage,

            /// Edit Icon Over Image
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(radius)
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.mode_edit_outlined, 
                  color: Colors.white
                )    
              ),
            )
            
          ],
        );

      }else if(changePhotoType == ChangePhotoType.editIconONextToImage)  {

        child = Row(
          children: [
            
            /// Expandable Image
            if(isCircleShape) expandableImage,
            
            /// Expandable Image
            if(isRectangleShape) Expanded(child: expandableImage),
        
            /// Edit Icon Next To Image
            IconButton(
              icon: const Icon(
                Icons.edit_sharp, 
                color: Colors.grey
              ), onPressed: openBottomModalSheet
            )
        
          ],
        );

      }else{

        /// Expandable Image
        child = expandableImage;

      }

      return GestureDetector(
        onTap: () {
          /// If we can change the photo
          if(changePhotoType == ChangePhotoType.editIconOverImage || changePhotoType == ChangePhotoType.editIconONextToImage) {
            openBottomModalSheet();
          }
        },
        child: child
      );

    }

  }

  ImageProvider<Object>? get backgroundImage {

    if(hasFile) {

      return FileImage(File(filePath!));

    }else if(hasPhoto && photoIsAnAssetFile) {

      return FileImage(File(store.logo!));

    }else if(hasPhoto && photoIsANetworkFile) {

      return CachedNetworkImageProvider(
        store.logo!,
      );

    }
    
    return null;
  }

  Widget get normalImage {
    
    if(photoShape == PhotoShape.circle) {
      
      /// Circle Shape
      return CircleAvatar(
        radius: radius,
        backgroundImage: backgroundImage,
        backgroundColor: Colors.grey.shade100,
      );

    }else{

      /// Rectangle Shape
      return Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: Colors.transparent,
          image: DecorationImage(
            alignment: Alignment.topCenter,
            image: backgroundImage!,
            fit: BoxFit.cover,
          ),
        )
      );

    }
  }

  Widget? get fullScreenImage {

    if(hasFile) {

      return Image.asset(filePath!);

    }else if(hasPhoto && photoIsAnAssetFile) {

      return Image.asset(store.logo!);

    }else if(hasPhoto && photoIsANetworkFile) {

      return CachedNetworkImage(
        placeholder: (context, url) => const CustomCircularProgressIndicator(),
        imageUrl: store.logo!,
        height: double.infinity,
        width: double.infinity,
        fit: BoxFit.contain,
      );

    }else{

      return null;

    }
    
  }

  Widget get editablePhoto {
    return ImagePickerModalBottomSheet(
      radius: radius,
      trigger: trigger,
      fileName: 'logo',
      subtitle: 'Your customers love quality logos 👌',
      title: hasPhoto ? 'Store Logo' : 'Add Store Logo',
      onSubmittedFile: (file, response) {
        
        /// Set the updated photo from the file system
        /// We could use the upadated photo from the
        /// request but this would be slower to load
        /// e.g the following takes time to show up
        /// since the photo must be downloaded:
        /// 
        /// user!.logo = response.data['logo']
        setState(() {

          /// Set the file
          this.file = file;

            /// Set the photo
          store.logo = file.path;

          if(onSubmittedFile != null) onSubmittedFile!(file.path);
          
        });

      },
      onDeletedFile: (response) {
        if(response.statusCode == 200) {
        
          setState(() {

            /// Unset the file
            file = null;

            /// Unset the photo
            store.logo = null;

            if(onDeletedFile != null) onDeletedFile!();

          });

        }
      },
      onPickedFile: (file) {
        setState(() {
          this.file = file;
          if(onPickedFile != null) onPickedFile!(file);
        });
      },
      submitMethod: SubmitMethod.post,
      submitUrl: store.links.updateLogo.href,
      deleteUrl: store.links.deleteLogo.href,
    );
  }

  @override
  Widget build(BuildContext context) {
    return hasFile || hasPhoto || showEditableMode ? editablePhoto : placeholderPhoto;
  }
}