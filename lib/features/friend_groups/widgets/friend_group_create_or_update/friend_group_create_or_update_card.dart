import 'package:bonako_demo/core/shared_widgets/button/custom_elevated_button.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_medium_text.dart';
import 'package:bonako_demo/core/shared_widgets/button/add_or_close_button.dart';
import 'package:bonako_demo/features/friend_groups/widgets/friend_group_create_or_update/friend_group_create_or_update.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

class FriendGroupCreateOrUpdateCard extends StatefulWidget {

  final bool hasFriendGroup;
  final Function onCreatedFriendGroup;

  const FriendGroupCreateOrUpdateCard({
    super.key,
    required this.hasFriendGroup,
    required this.onCreatedFriendGroup,
  });

  @override
  State<FriendGroupCreateOrUpdateCard> createState() => _FriendGroupCreateOrUpdateCardState();
}

class _FriendGroupCreateOrUpdateCardState extends State<FriendGroupCreateOrUpdateCard> {

  bool canShowGroupForm = false;
  bool get hasFriendGroup => widget.hasFriendGroup;
  final CarouselController carouselController = CarouselController();

  bool get doesntHaveFriendGroup => !hasFriendGroup;
  Function get onCreatedFriendGroup => widget.onCreatedFriendGroup;

  List<Map> whyCreateAGroupReasons = [
    {
      'image': '1',
      'title': 'Order With Friends',
      'description': 'Create a shopping group and order with your friends! Buy gifts, lunches, group trips, bulk groceries and so much more!',
    },
    {
      'image': '2',
      'title': 'Make Shopping Social Again',
      'description': 'Shopping is always better when shared with friends. With Group Shopping, its easy to share your favourite stores and products with your shopping group.',
    },
    {
      'image': '3',
      'title': 'Connect, Discover, and Bond',
      'description': 'It\'s the perfect way to discover new products and local sellers, and bond over your mutual love for finding great deals, discovering hidden gems, and sharing exciting shopping experiences.',
    }
  ];

  void _onCreatedFriendGroup() {
    setState(() => canShowGroupForm = false);
    onCreatedFriendGroup();
  }

  void toggleVisibility() => setState(() => canShowGroupForm = !canShowGroupForm);

  Widget get getStarted {
    return Column(
      children: [

        /// Spacer
        const SizedBox(height: 32,),

        /// Create Your First Friend Group Button
        CustomElevatedButton(
          'Create Your First Group!',
          width: 200,
          onPressed: toggleVisibility,
          alignment: Alignment.center,
        ),

        /// Spacer
        const SizedBox(height: 20,),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Why Create Your Friend Group On Bonako - Carousel Slider
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
              itemCount: whyCreateAGroupReasons.length,
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
                        child: Image.asset('assets/images/groups/${itemIndex + 1}.png'),
                      ),

                      //  Reason
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            /// Reason Title
                            CustomTitleMediumText(whyCreateAGroupReasons[itemIndex]['title'], margin: const EdgeInsets.only(bottom: 8.0),),

                            /// Reason Description
                            CustomBodyText(whyCreateAGroupReasons[itemIndex]['description'], textAlign: TextAlign.justify,),

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

  Widget get createGroupCard {
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
                  child: const CustomBodyText('Create your group and invite friends', lightShade: true,)
                ),
              ],
            ),
      
            /// Spacer
            const SizedBox(height: 8,),
      
            FriendGroupCreateOrUpdate(
              bottomHeight: 0,
              padding: const EdgeInsets.all(0),
              onCreatedFriendGroup: _onCreatedFriendGroup
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
        if(hasFriendGroup) Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 16, bottom: 16),
          child: AddOrCloseButton(
            isAdding: !canShowGroupForm,
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
                key: ValueKey(canShowGroupForm),
                children: [
                  
                  /// Get Started Information
                  if(doesntHaveFriendGroup && !canShowGroupForm) getStarted,

                  /// Spacer
                  if(doesntHaveFriendGroup && canShowGroupForm) const SizedBox(
                    height: 32,
                  ),
        
                  /// Create Friend Group Card
                  if(canShowGroupForm) createGroupCard,
                  
                ],
              )
            )
          ),
        ),
      ],
    );
  }
}