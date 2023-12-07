import 'dart:ffi';

import 'package:bonako_demo/features/Image_picker/widgets/image_picker_modal_bottom_sheet/image_picker_modal_bottom_sheet.dart';
import 'package:bonako_demo/core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import 'package:bonako_demo/features/Image_picker/enums/image_picker_enums.dart';
import 'package:bonako_demo/core/shared_widgets/full_screen_image/main.dart';
import 'package:bonako_demo/features/transactions/enums/transaction_enums.dart';
import 'package:bonako_demo/features/transactions/models/transaction.dart';
import 'package:bonako_demo/features/stores/providers/store_provider.dart';
import 'package:bonako_demo/features/stores/services/store_services.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import 'package:bonako_demo/features/home/providers/home_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'dart:io';

enum ProofOfPaymentPhotoShape {
  circle,
  rectangle
}

enum ChangePhotoType {
  none,
  editIconOverImage,
  editIconONextToImage
}

class TransactionProofOfPaymentPhoto extends StatefulWidget {

  final double? height;
  final double? radius;
  final ShoppableStore store;
  final Transaction? transaction;
  final Function()? onDeletedFile;
  final Function(XFile)? onPickedFile;
  final ChangePhotoType changePhotoType;
  final Function(String)? onSubmittedFile;
  final ProofOfPaymentPhotoShape proofOfPaymentPhotoShape;

  const TransactionProofOfPaymentPhoto({
    Key? key,
    this.height,
    this.radius,
    this.transaction,
    this.onPickedFile,
    this.onDeletedFile,
    required this.store,
    this.onSubmittedFile,
    this.changePhotoType = ChangePhotoType.none,
    this.proofOfPaymentPhotoShape = ProofOfPaymentPhotoShape.circle

  }) : super(key: key);

  @override
  State<TransactionProofOfPaymentPhoto> createState() => _TransactionProofOfPaymentPhotoState();
}

class _TransactionProofOfPaymentPhotoState extends State<TransactionProofOfPaymentPhoto> {

  XFile? file;
  XFile? fileUrl;
  late double height;
  late double radius;

  Transaction? transaction;
  bool get hasFile => file != null;
  String? get filePath => file?.path;
  ShoppableStore get store => widget.store;
  bool get doesNotHaveFile => file == null;
  bool get hasTransaction => transaction != null;
  Function()? get onDeletedFile => widget.onDeletedFile;
  ChangePhotoType get changePhotoType => widget.changePhotoType;
  Function(String)? get onSubmittedFile => widget.onSubmittedFile;
  bool get doesNotHavePhoto => transaction?.proofOfPaymentPhoto == null;
  bool get hasPhoto => hasTransaction && transaction!.proofOfPaymentPhoto != null;
  bool get isCircleShape => proofOfPaymentPhotoShape == ProofOfPaymentPhotoShape.circle;
  ProofOfPaymentPhotoShape get proofOfPaymentPhotoShape => widget.proofOfPaymentPhotoShape;
  bool get isRectangleShape => proofOfPaymentPhotoShape == ProofOfPaymentPhotoShape.rectangle;
  bool get photoIsAnAssetFile => hasTransaction && transaction!.proofOfPaymentPhoto?.startsWith('http') == false;
  bool get photoIsANetworkFile => hasTransaction && transaction!.proofOfPaymentPhoto?.startsWith('http') == true;

  Function(XFile)? get onPickedFile => widget.onPickedFile;
  bool get isShowingStorePage => storeProvider.isShowingStorePage;
  bool get hasSelectedMyStores => homeProvider.hasSelectedMyStores;
  bool get canAccessAsTeamMember => StoreServices.canAccessAsTeamMember(store);
  bool get teamMemberWantsToViewAsCustomer => store.teamMemberWantsToViewAsCustomer;
  HomeProvider get homeProvider => Provider.of<HomeProvider>(context, listen: false);
  bool get isTeamMemberWhoHasJoined => StoreServices.isTeamMemberWhoHasJoined(store);
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: true);
  bool get showEditableMode => isTeamMemberWhoHasJoined && !teamMemberWantsToViewAsCustomer;

  @override
  void initState() {
    super.initState();
    transaction = widget.transaction;
    
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
  void didUpdateWidget(covariant TransactionProofOfPaymentPhoto oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() => transaction = widget.transaction);
  }

  Widget get placeholderPhoto {

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade100,
      child: Icon(Icons.image, size: 24, color: Colors.grey.shade400,)
    );

  }

  Widget trigger(openBottomModalSheet) {

    /// If we don't have a file or photo
    if(doesNotHaveFile && doesNotHavePhoto) {

      Widget child;
      BorderType borderType;
      
      if(proofOfPaymentPhotoShape == ProofOfPaymentPhotoShape.circle) {

        borderType = BorderType.Circle;

        /// Circle Shape
        child = CircleAvatar(
          radius: radius,
          backgroundColor: Colors.transparent,
          child: Icon(Icons.add_photo_alternate_outlined, size: 16, color: Colors.grey.shade400,)
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
          child: Icon(Icons.add_photo_alternate_outlined, size: 16, color: Colors.grey.shade400,)
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

      return FileImage(File(transaction!.proofOfPaymentPhoto!));

    }else if(hasPhoto && photoIsANetworkFile) {

      return CachedNetworkImageProvider(
        transaction!.proofOfPaymentPhoto!,
      );

    }
    
    return null;
  }

  Widget get normalImage {
    
    if(proofOfPaymentPhotoShape == ProofOfPaymentPhotoShape.circle) {
      
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

      return Image.asset(transaction!.proofOfPaymentPhoto!);

    }else if(hasPhoto && photoIsANetworkFile) {

      return CachedNetworkImage(
        placeholder: (context, url) => const CustomCircularProgressIndicator(),
        imageUrl: transaction!.proofOfPaymentPhoto!,
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
      fileName: 'proof_of_payment_photo',
      subtitle: 'Everyone loves quality photos 👌',
      title: hasPhoto ? 'Proof Of Payment' : 'Attach Proof Of Payment',
      onSubmittedFile: (file, response) {
        
        /// Set the updated photo from the file system
        /// We could use the upadated photo from the
        /// request but this would be slower to load
        /// e.g the following takes time to show up
        /// since the photo must be downloaded:
        /// 
        /// user!.proofOfPaymentPhoto = response.data['proof_of_payment_photo']
        setState(() {

          /// Set the file
          this.file = file;

            /// Set the photo
          transaction!.proofOfPaymentPhoto = file.path;

          if(onSubmittedFile != null) onSubmittedFile!(file.path);
          
        });

      },
      onDeletedFile: (response) {
        if(response.statusCode == 200) {
        
          setState(() {

            /// Unset the file
            file = null;

            /// Unset the photo
            transaction!.proofOfPaymentPhoto = null;

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
      submitUrl: transaction?.links.updateProofOfPaymentPhoto.href,
      deleteUrl: transaction?.links.deleteProofOfPaymentPhoto.href,
    );
  }

  @override
  Widget build(BuildContext context) {
    return hasFile || hasPhoto || showEditableMode ? editablePhoto : placeholderPhoto;
  }
}