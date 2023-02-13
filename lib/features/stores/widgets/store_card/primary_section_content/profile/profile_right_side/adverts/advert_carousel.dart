import '../../../../../../../../core/shared_widgets/full_screen_image/main.dart';
import '../../../../../../models/shoppable_store.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class StoreAdvertCarousel extends StatelessWidget {
  
  final ShoppableStore store;

  const StoreAdvertCarousel({required this.store, super.key});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      options: CarouselOptions(
        height: 400.0,
        padEnds: true,
        autoPlay: true,
        clipBehavior: Clip.none,
        enlargeCenterPage: true,
        enableInfiniteScroll: false,
        autoPlayInterval: const Duration(seconds: 10),
        autoPlayAnimationDuration: const Duration(seconds: 1),
      ),
      itemCount: store.adverts.length,
      itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {

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
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                store.adverts[itemIndex],
                fit: BoxFit.cover,
              ),
            ),
          ),
        );

        /*
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300,),
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: NetworkImage(store.adverts[itemIndex]),
              fit: BoxFit.fill,
            ),
            /*
            boxShadow: [
              BoxShadow(
                blurRadius: 0 /* 5 */,
                offset: const Offset(0, 5),
                color: Colors.grey.shade200 /* Colors.grey.shade300 */,
              )
            ],
            */
          ),
        );
        */
      }
    );
  }

}