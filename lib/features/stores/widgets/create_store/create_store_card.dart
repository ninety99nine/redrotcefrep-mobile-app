import 'package:bonako_demo/core/shared_widgets/button/custom_elevated_button.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_medium_text.dart';
import 'package:bonako_demo/core/shared_widgets/button/add_or_close_button.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'create_store_form.dart';

class CreateStoreCard extends StatefulWidget {

  final int totalStores;
  final Function(ShoppableStore)? onCreatedStore;

  const CreateStoreCard({
    super.key,
    this.onCreatedStore,
    required this.totalStores,
  });

  @override
  State<CreateStoreCard> createState() => _CreateStoreCardState();
}

class _CreateStoreCardState extends State<CreateStoreCard> {

  bool canShowStoreForm = false;
  int get totalStores => widget.totalStores;
  final CarouselController carouselController = CarouselController();

  bool get hasStores => totalStores > 0;
  bool get doesntHaveStores => totalStores == 0;
  Function(ShoppableStore)? get onCreatedStore => widget.onCreatedStore;

  List<Map> whySellOnBonakoReasons = [
    {
      'image': '1',
      'title': 'Instant Access',
      'description': 'Your store gets its own shortcode e.g *250*1# so that customers can dial and place orders faster and more conveniently.',
    },
    {
      'image': '2',
      'title': 'Build Credibility',
      'description': 'You can build credibility and trust among potential customers through positive reviews and ratings from satisfied buyers, encouraging more people to choose your store.',
    },
    {
      'image': '3',
      'title': 'Grow Your Business',
      'description': 'As your store grows and demonstrates potential, Bonako connects you with relevant investors, banks, and insurance companies who can provide financial assistance and other support to take your business to the next level.',
    },
    {
      'image': '4',
      'title': 'Local Connections',
      'description': 'Bonako prioritizes local commerce, allowing you to connect directly with customers in Botswana. By catering specifically to their preferences and needs, you can foster stronger relationships and build a loyal customer base.',
    },
    {
      'image': '5',
      'title': 'Local Access',
      'description': 'Benefit from Bonako\'s marketing and promotional efforts, which increases your store\'s visibility and chances of attracting more customers.',
    }
  ];

  void _onCreatedStore(ShoppableStore createdStore) {
    
    /// Hide the store creation form
    toggleVisibility();

    /// Notify parent widget on store creation
    if(onCreatedStore != null) onCreatedStore!(createdStore);

  }

  void toggleVisibility() => setState(() => canShowStoreForm = !canShowStoreForm);

  Widget get getStarted {
    return Column(
      children: [

        /// Spacer
        const SizedBox(height: 32,),

        /// Create Your First Store Button
        CustomElevatedButton(
          'Create Your First Store!',
          width: 200,
          onPressed: toggleVisibility,
          alignment: Alignment.center,
        ),

        /// Spacer
        const SizedBox(height: 20,),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Why Create Your Store On Bonako - Carousel Slider
            CarouselSlider.builder(
              carouselController: carouselController,
              options: CarouselOptions(
                height: 450.0,
                padEnds: true,
                autoPlay: true,
                viewportFraction: 0.9,
                enlargeCenterPage: false,
                enableInfiniteScroll: false,
                clipBehavior: Clip.hardEdge,
                autoPlayInterval: const Duration(seconds: 10),
                autoPlayAnimationDuration: const Duration(seconds: 5),
              ),
              itemCount: whySellOnBonakoReasons.length,
              itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
                
                /// Slider Content
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16)
                  ),
                  child: Column(
                    children: [
      
                      //  Image
                      SizedBox(
                        height: 300,
                        child: Image.asset('assets/images/my_stores/${itemIndex + 1}.png'),
                      ),

                      //  Reason
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            /// Reason Title
                            CustomTitleMediumText(whySellOnBonakoReasons[itemIndex]['title'], margin: const EdgeInsets.only(bottom: 8.0),),

                            /// Reason Description
                            CustomBodyText(whySellOnBonakoReasons[itemIndex]['description'], textAlign: TextAlign.justify,),

                          ],
                        )
                      ),
                    
                    ],
                  )
                );

              }
            ),
      
          ],
        ),

        /// Spacer
        const SizedBox(height: 100,),

      ],
    );
  }

  Widget get createStoreCard {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
      child: DottedBorder(
        padding: const EdgeInsets.all(16),
        radius: const Radius.circular(8),
        borderType: BorderType.RRect,
        strokeCap: StrokeCap.butt,
        dashPattern: const [6, 3], 
        color: Colors.grey,
        strokeWidth: 1,
        child: Column(
          children: [
      
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
      
                /// Instruction
                Container(
                  margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                  alignment: Alignment.centerLeft,
                  child: const CustomBodyText('Create your store - add your brand emoji 😉', lightShade: true,)
                ),
    
              ],
            ),
      
            /// Spacer
            const SizedBox(height: 8,),
      
            CreateStoreForm(
              onCreatedStore: (createdStore) => _onCreatedStore(createdStore)
            ),
      
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [

        /// Add / Remove Button
        if(hasStores) Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 16, bottom: 16),
          child: AddOrCloseButton(
            isAdding: !canShowStoreForm,
            onTap: toggleVisibility
          ),
        ),

        SizedBox(
          width: double.infinity,
          child: AnimatedSize(
            clipBehavior: Clip.none,
            duration: const Duration(milliseconds: 500),
            child: AnimatedSwitcher(
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              duration: const Duration(milliseconds: 500),
              child: Column(
                key: ValueKey(canShowStoreForm),
                children: [
                  
                  /// Get Started Information
                  if(doesntHaveStores && !canShowStoreForm) getStarted,

                  /// Spacer
                  if(doesntHaveStores && canShowStoreForm) const SizedBox(
                    height: 32,
                  ),
        
                  /// Create Store Card
                  if(canShowStoreForm) createStoreCard,
                  
                ],
              )
            )
          ),
        ),
      ],
    );
  }
}