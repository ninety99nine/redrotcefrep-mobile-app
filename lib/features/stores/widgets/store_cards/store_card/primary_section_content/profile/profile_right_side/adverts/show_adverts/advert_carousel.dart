import 'package:perfect_order/features/Image_picker/widgets/image_picker_modal_bottom_sheet/image_picker_modal_bottom_sheet.dart';
import 'package:perfect_order/core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import '../../../../../../../../../../core/shared_widgets/full_screen_image/main.dart';
import '../../../../../../../../../../../core/constants/constants.dart' as constants;
import 'package:perfect_order/features/Image_picker/enums/image_picker_enums.dart';
import 'package:perfect_order/features/stores/services/store_services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../../../../models/shoppable_store.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class StoreAdvertCarousel extends StatefulWidget {
  
  final ShoppableStore store;

  const StoreAdvertCarousel({required this.store, super.key});

  @override
  State<StoreAdvertCarousel> createState() => _StoreAdvertCarouselState();
}

class _StoreAdvertCarouselState extends State<StoreAdvertCarousel> {

  final CarouselController carouselController = CarouselController();

  bool get canAddAdvert => isTeamMemberWhoHasJoined && canAccessAsTeamMember && !hasReachedMaximumAdvertsPerStore && !teamMemberWantsToViewAsCustomer;
  bool get canChangeAdvert => isTeamMemberWhoHasJoined && canAccessAsTeamMember && !teamMemberWantsToViewAsCustomer;
  bool get hasReachedMaximumAdvertsPerStore => adverts.length == constants.maximumAdvertsPerStore;
  bool get isTeamMemberWhoHasJoined => StoreServices.isTeamMemberWhoHasJoined(store);
  bool get teamMemberWantsToViewAsCustomer => store.teamMemberWantsToViewAsCustomer;
  bool get canAccessAsTeamMember => StoreServices.canAccessAsTeamMember(store);
  bool get hasAdverts => adverts.isNotEmpty;
  List<String> get adverts => store.adverts;
  ShoppableStore get store => widget.store;

  Widget centeredImage(itemIndex) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            
            CachedNetworkImage(
              placeholder: (context, url) => const CustomCircularProgressIndicator(),
              imageUrl: adverts[itemIndex],
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
    
            if(canChangeAdvert) Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8)
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.mode_edit_outlined, color: Colors.white,)     
              ),
            )
    
          ],
        ),
      ),
    );
  }

  Widget expandableAdvert(itemIndex) {
    /**
     *  FullScreenWidget - This is a custom widget that allows
     *  us to click of the individual image to be displayed in
     *  full screen view. We use the Center Widget according
     *  to the docs to show the full image contents instead
     *  of a fullview that cuts the image content.
     *  
     *  https://pub.dev/packages/full_screen_image_null_safe
     */
    return FullScreenWidget(
      backgroundColor: Colors.transparent,
      backgroundIsTransparent: true,
      child: centeredImage(itemIndex),
    );
  }

  Widget editableAdvert(itemIndex) {
    return ImagePickerModalBottomSheet(
      title: 'Advert',
      subtitle: 'Your customers love quality adverts 👌',
      fileName: 'advert',
      submitMethod: SubmitMethod.post,
      submitUrl: store.links.updateAdvert.href,
      submitBody: {
        'position': (itemIndex + 1).toString()
      },
      onSubmittedFile: (file, response) {
        
        /// Set the updated advert from the response
        setState(() => store.adverts[itemIndex] = response.data['advert']);

        /**
         *  The reason we use a Future.delayed here is because the carouselController.jumpToPage() 
         *  method does not work if called immediately after the setState() method. Instead it
         *  works if called after a delay.
         */
        Future.delayed(Duration.zero).then((value) {

          /// Navigate to this item
          carouselController.jumpToPage(adverts.length - 1);
          
        });

      },
      deleteUrl: store.links.deleteAdvert.href,
      deleteBody: {
        'position': (itemIndex + 1).toString()
      },
      onDeletedFile: (response) {
        
        /// Remove the advert from the store adverts
        setState(() => store.adverts.removeAt(itemIndex));

      },
      trigger: (openBottomModalSheet) => GestureDetector(
        onTap: () {
          openBottomModalSheet();
        },
        child: centeredImage(itemIndex)
      ),
    );
  }

  Widget addAdvert() {
    return Center(
      child: ImagePickerModalBottomSheet(
        title: 'Advert',
        subtitle: 'Your customers love quality adverts 👌',
        fileName: 'advert',
        onSubmittedFile: (file, response) {
          
          /// Set the updated advert from the response
          setState(() => store.adverts.add(response.data['advert']));

          /**
           *  The reason we use a Future.delayed here is because the carouselController.jumpToPage() 
           *  method does not work if called immediately after the setState() method. Instead it
           *  works if called after a delay.
           */
          Future.delayed(Duration.zero).then((value) {

            /// Navigate to this item
            carouselController.jumpToPage(adverts.length - 1);

          });

        },
        triggerText: 'Add Advert ${adverts.isEmpty ? '' : '#${adverts.length + 1}'}',
        submitMethod: SubmitMethod.post,
        triggerIcon: Icons.photo_outlined,
        submitUrl: store.links.createAdvert.href
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 500),
      child: Column(
        children: [
      
          if(adverts.isNotEmpty) CarouselSlider.builder(
            carouselController: carouselController,
            options: CarouselOptions(
              height: 300.0,
              padEnds: true,
              //autoPlay: true,
              //aspectRatio: 2/3,
              viewportFraction: 0.8,
              //clipBehavior: Clip.none,
              //enlargeCenterPage: true,
              enableInfiniteScroll: false,
              //initialPage: adverts.length >= 2 ? 1 : 0,
              //autoPlayInterval: const Duration(seconds: 10),
              //autoPlayAnimationDuration: const Duration(seconds: 1),
            ),
            itemCount: adverts.length,
            itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
                
              /// Return the advert
              return canChangeAdvert ? editableAdvert(itemIndex) : expandableAdvert(itemIndex);

            }
          ),
    
          if(canAddAdvert) ...[
    
            /// Spacer
            if(hasAdverts) const SizedBox(height: 16,),
    
            /// Add Advert
            addAdvert()
    
          ]
    
        ],
      ),
    );
  }
}