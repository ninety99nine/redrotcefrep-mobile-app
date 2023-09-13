import 'package:bonako_demo/features/stores/widgets/store_cards/store_card/primary_section_content/profile/profile_right_side/adverts/show_adverts/advert_carousel.dart';
import 'package:bonako_demo/features/stores/widgets/store_cards/store_card/primary_section_content/store_cover_photo.dart';
import '../../../subscribe_to_store/subscribe_to_store_modal_bottom_sheet/subscribe_to_store_modal_bottom_sheet.dart';
import 'package:bonako_demo/features/products/widgets/edit_product_cards/edit_product_cards.dart';
import 'package:bonako_demo/core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import 'package:bonako_demo/features/stores/providers/store_provider.dart';
import '../../../../../shopping_cart/widgets/shopping_cart_content.dart';
import 'package:bonako_demo/features/home/providers/home_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'store_product_carousel/store_product_carousel.dart';
import '../../../../services/store_services.dart';
import '../../../../models/shoppable_store.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class StoreSecondarySectionContent extends StatefulWidget {

  final bool canShowAdverts;
  final ShoppableStore store;
  final EdgeInsetsGeometry padding;
  final ShoppingCartCurrentView shoppingCartCurrentView;

  const StoreSecondarySectionContent({
    Key? key,
    required this.store,
    this.canShowAdverts = true,
    required this.shoppingCartCurrentView,
    this.padding = const EdgeInsets.all(0)
  }) : super(key: key);

  @override
  State<StoreSecondarySectionContent> createState() => _StoreSecondarySectionContentState();
}

class _StoreSecondarySectionContentState extends State<StoreSecondarySectionContent> {

  ShoppableStore get store => widget.store;
  bool get hasCoverPhoto => store.hasCoverPhoto;
  EdgeInsetsGeometry get padding => widget.padding;
  bool get canShowAdverts => widget.canShowAdverts;
  bool get hasProductPhotos => store.hasProductPhotos;
  bool get doesNotHaveCoverPhoto => store.doesNotHaveCoverPhoto;
  bool get hasProducts => store.relationships.products.isNotEmpty;
  bool get isShowingStorePage => storeProvider.isShowingStorePage;
  bool get hasSelectedMyStores => homeProvider.hasSelectedMyStores;
  bool get doesNotHaveProductPhotos => store.doesNotHaveProductPhotos;
  bool get canAccessAsShopper => StoreServices.canAccessAsShopper(store);
  bool get canAccessAsTeamMember => StoreServices.canAccessAsTeamMember(store);
  bool get teamMemberWantsToViewAsCustomer => store.teamMemberWantsToViewAsCustomer;
  HomeProvider get homeProvider => Provider.of<HomeProvider>(context, listen: false);
  bool get isTeamMemberWhoHasJoined => StoreServices.isTeamMemberWhoHasJoined(store);
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: true);
  bool get showEditableMode => (isShowingStorePage || hasSelectedMyStores) && isTeamMemberWhoHasJoined && !teamMemberWantsToViewAsCustomer;

  /// key: ValueKey(showEditableMode),
  /// key: ValueKey(teamMemberWantsToViewAsCustomer),

  @override
  Widget build(BuildContext context) {

    return AnimatedSize(
      clipBehavior: Clip.none,
      duration: const Duration(milliseconds: 500),
      child: AnimatedSwitcher(
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        duration: const Duration(milliseconds: 500),
        child: Column(
          key: ValueKey('$showEditableMode $teamMemberWantsToViewAsCustomer'),
          children: [
              
            if(showEditableMode && doesNotHaveProductPhotos) ...[
      
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isShowingStorePage ? 16.0 : 0),
                child: StoreCoverPhoto(
                  store: store,
                  canChangeCoverPhoto: true,
                ),
              ),
      
              /// Spacer
              const SizedBox(height: 16,),
      
            ],

            /// Store Cover Photo (Uneditable)
            if(!showEditableMode && doesNotHaveProductPhotos && hasCoverPhoto) ...[
              
              Container(
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8)
                ),
                child: CachedNetworkImage(
                  placeholder: (context, url) => const CustomCircularProgressIndicator(),
                  imageUrl: store.coverPhoto!,
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                ),
              ),
      
              /// Spacer
              const SizedBox(height: 16,),
      
            ],
      
            if(canShowAdverts) ...[
            
              /// Store Adverts
              StoreAdvertCarousel(store: store),
      
              /// Spacer
              const SizedBox(height: 16,),
      
            ],

            if(hasProductPhotos) ...[

              /// Store Product Carousel
              StoreProductCarousel(store: store),

            ],
      
            if(showEditableMode || (hasProducts && !showEditableMode && canAccessAsShopper)) Padding(
              padding: padding,
              child: Column(
                children: [
              
                  /// Spacer
                  if(hasProductPhotos) const SizedBox(height: 16,),
                  
                  /// Edit Product Cards
                  if(showEditableMode)  ...[
      
                    EditProductCards(
                      shoppingCartCurrentView: widget.shoppingCartCurrentView
                    )
      
                  ],
      
                  /// Shopping Cart
                  if(!showEditableMode && canAccessAsShopper) ...[
      
                    /// Spacer
                    if(teamMemberWantsToViewAsCustomer) const SizedBox(height: 16,),
      
                    ShoppingCartContent(
                      shoppingCartCurrentView: widget.shoppingCartCurrentView
                    ),
      
                  ]
      
                ]
              ),
            ),
      
            /// Subscribe Modal Bottom Sheet
            if(isTeamMemberWhoHasJoined && !canAccessAsTeamMember) Column(
              children: [
            
                /// Access Denied For Team Member
                if(doesNotHaveCoverPhoto && doesNotHaveProductPhotos) ...[
      
                  SubscribeToStoreModalBottomSheet(
                    store: widget.store,
                    subscribeButtonAlignment: Alignment.center,
                  ),
      
                ],
            
              ]
            )
      
          ],
        ),
      ),
    );
  }
}