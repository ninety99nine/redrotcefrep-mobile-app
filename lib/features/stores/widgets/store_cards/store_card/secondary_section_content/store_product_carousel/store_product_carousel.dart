import 'package:bonako_demo/features/Image_picker/widgets/image_picker_modal_bottom_sheet/image_picker_modal_bottom_sheet.dart';
import 'package:bonako_demo/core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import '../../../../../../../../../../../../../core/shared_widgets/full_screen_image/main.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_medium_text.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_large_text.dart';
import 'package:bonako_demo/features/Image_picker/enums/image_picker_enums.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/stores/providers/store_provider.dart';
import 'package:bonako_demo/features/stores/services/store_services.dart';
import 'package:bonako_demo/features/home/providers/home_provider.dart';
import 'package:bonako_demo/features/products/models/product.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../../../models/shoppable_store.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class StoreProductCarousel extends StatefulWidget {
  
  final ShoppableStore store;

  const StoreProductCarousel({required this.store, super.key});

  @override
  State<StoreProductCarousel> createState() => _StoreProductCarouselState();
}

class _StoreProductCarouselState extends State<StoreProductCarousel> {

  final CarouselController carouselController = CarouselController();

  ShoppableStore get store => widget.store;
  bool get hasProductPhotos => store.hasProductPhotos;
  List<String> get productPhotos => store.productPhotos;
  int get totalProductPhotos => store.totalProductPhotos;
  List<Product> get selectedProducts => store.selectedProducts;
  bool get isShowingStorePage => storeProvider.isShowingStorePage;
  bool get hasSelectedMyStores => homeProvider.hasSelectedMyStores;
  List<Product> get productsWithPhotos => store.productsWithPhotos;
  bool get teamMemberWantsToViewAsCustomer => store.teamMemberWantsToViewAsCustomer;
  HomeProvider get homeProvider => Provider.of<HomeProvider>(context, listen: false);
  bool get isTeamMemberWhoHasJoined => StoreServices.isTeamMemberWhoHasJoined(store);
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: true);
  bool get showEditableMode => (isShowingStorePage || hasSelectedMyStores) && isTeamMemberWhoHasJoined && !teamMemberWantsToViewAsCustomer;

  @override
  void initState() {
    super.initState();
    store.onSelectedProductCallbacks.add(scrollToPhoto);
    store.onChangedProductQuantityCallbacks.add(scrollToPhoto);
    store.addOrRemoveSelectedProductCallbacks.add(scrollToPhoto);
  }

  @override
  void dispose() {
    super.dispose();
    store.onSelectedProductCallbacks.removeWhere((callback) => callback == scrollToPhoto);
    store.onChangedProductQuantityCallbacks.removeWhere((callback) => callback == scrollToPhoto);
    store.addOrRemoveSelectedProductCallbacks.removeWhere((callback) => callback == scrollToPhoto);
  }

  void scrollToPhoto(Product product) {

    final int index = productsWithPhotos.indexWhere((productWithPhoto) => productWithPhoto.id == product.id);

    /// If we have a matching product
    if(index >= 0) {

      /// Animate scroll to this product
      carouselController.animateToPage(index);

    }

  }

  double get viewportFraction {
    if(totalProductPhotos == 1) {
      return 1;
    }else {
      return 0.9;
    }
  }

  bool isSelectedProduct(itemIndex) {
    return selectedProducts.map((product) => product.id).contains(productsWithPhotos[itemIndex].id);
  }

  Widget centeredImage(itemIndex, boxFit) {

    final Product product = productsWithPhotos[itemIndex];
    final bool hasMoreThanOneQuantity = product.quantity > 1;
    final bool isSelected = selectedProducts.map((selectedProduct) => selectedProduct.id).contains(product.id);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: totalProductPhotos == 1 ? 0 : 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            
            /// Product Image
            CachedNetworkImage(
              placeholder: (context, url) => const CustomCircularProgressIndicator(),
              imageUrl: productsWithPhotos[itemIndex].photo!,
              height: double.infinity,
              width: double.infinity,
              fit: boxFit,
            ),

            /// Edit Mode Icon
            if(showEditableMode) Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8)
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.mode_edit_outlined, color: Colors.white,)
              ),
            ),

            /// Checkmark & Selected Product Quantity
            AnimatedSwitcher(
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              duration: const Duration(milliseconds: 500),
              child: isSelected ? Align(
                key: ValueKey('${product.quantity}'),
                alignment: Alignment.topRight,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: CustomTitleLargeText('x${product.quantity}', height: 1, color: Colors.green),
                ),
              ) : null,
            ),
    
          ],
        ),
      ),
    );
  }

  Widget fullImage(itemIndex) {

    String productName = store.relationships.products[itemIndex].name;
    String? productDescription = store.relationships.products[itemIndex].description;
    bool hasProductDescription = productDescription != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Stack(
        children: [
          
          CachedNetworkImage(
            placeholder: (context, url) => const CustomCircularProgressIndicator(),
            imageUrl: productsWithPhotos[itemIndex].photo!,
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.contain,
          ),

          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              margin: const EdgeInsets.only(left: 16, right: 16, bottom: 100),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTitleMediumText(productName, overflow: TextOverflow.ellipsis),
                  if(hasProductDescription) ...[
                    const SizedBox(height: 4),
                    CustomBodyText(productDescription, overflow: TextOverflow.ellipsis, maxLines: 4)
                  ]
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget expandablePhoto(itemIndex) {
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
      backgroundIsTransparent: true,
      backgroundColor: Colors.transparent,
      fullScreenChild: fullImage(itemIndex),
      child: centeredImage(itemIndex, BoxFit.cover),
    );
  }

  Widget editablePhoto(itemIndex) {
    return ImagePickerModalBottomSheet(
      fileName: 'photo',
      title: 'Product Photo',
      submitMethod: SubmitMethod.post,
      subtitle: 'Your customers love quality photos 👌',
      submitUrl: productsWithPhotos[itemIndex].links.updatePhoto.href,
      onSubmittedFile: (file, response) {

        /// Set the updated photo from the file system
        /// We could use the upadated photo from the
        /// request but this would be slower to load
        /// e.g the following takes time to show up:
        /// 
        /// product!.photo = response.data['photo']
        setState(() => productsWithPhotos[itemIndex].photo = file.path);

        /**
         *  The reason we use a Future.delayed here is because the carouselController.jumpToPage() 
         *  method does not work if called immediately after the setState() method. Instead it
         *  works if called after a delay.
         */
        Future.delayed(Duration.zero).then((value) {

          /// Navigate to this item
          carouselController.jumpToPage(productsWithPhotos.length - 1);

        });

      },
      deleteUrl: productsWithPhotos[itemIndex].links.deletePhoto.href,
      onDeletedFile: (response) {
        
        /// Remove the photo from the product
        setState(() => productsWithPhotos[itemIndex].photo = null);

      },
      trigger: (openBottomModalSheet) => GestureDetector(
        onTap: () {
          openBottomModalSheet();
        },
        child: centeredImage(itemIndex, BoxFit.cover)
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 500),
      child: Column(
        children: [
      
          if(productsWithPhotos.isNotEmpty) CarouselSlider.builder(
            carouselController: carouselController,
            options: CarouselOptions(
              //height: 100,
              padEnds: true,
              //autoPlay: true,              
              aspectRatio: 3/2,
              //pageSnapping: true,
              //clipBehavior: Clip.none,
              //enlargeCenterPage: true,
              enableInfiniteScroll: false,
              viewportFraction: viewportFraction,
              //initialPage: productPhotos.length >= 2 ? 1 : 0,
              //autoPlayInterval: const Duration(seconds: 10),
              //autoPlayAnimationDuration: const Duration(seconds: 1),
            ),
            itemCount: productsWithPhotos.length,
            itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
                
              /// Return the product photos
              return showEditableMode ? editablePhoto(itemIndex) : expandablePhoto(itemIndex);

            }
          ),
    
        ],
      ),
    );
  }
}