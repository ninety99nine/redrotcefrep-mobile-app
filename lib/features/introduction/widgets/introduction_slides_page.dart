import '../../../core/constants/constants.dart' as constants;
import '../services/introduction_service.dart';
import 'package:intro_slider/intro_slider.dart';
import '../enums/introduction_enums.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'landing_page.dart';

class IntroductionSlidesPage extends StatelessWidget {

  static const routeName = 'IntroductionSlidesPage';
  
  const IntroductionSlidesPage({super.key});

  void onDone(BuildContext context, Role role) {

    final IntroductionService introductionServices = IntroductionService();

    if(role == Role.seller) {
      introductionServices.saveHasSeenSellerIntroOnDeviceStorage(true);
    }else if(role == Role.buyer) {
      introductionServices.saveHasSeenBuyerIntroOnDeviceStorage(true);
    }

    Get.offAndToNamed(LandingPage.routeName);

  }

  @override
  Widget build(BuildContext context) {

    //  Set the default role
    Role role = Role.seller;

    //  If the role has been provided via the Modal Route arguments
    if( 
        ModalRoute.of(context) != null && 
        ModalRoute.of(context)!.settings.arguments != null
    ) {

      //  Overide the default role
      role = ModalRoute.of(context)!.settings.arguments as Role;

    }

    //  Determine slides to show
    final slides = (role == Role.seller) 
      ? SliderManager.sellerSlides(context)
      : SliderManager.buyerSlides(context);

    //  Set the default button style
    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      foregroundColor: Theme.of(context).primaryColor,
      textStyle: const TextStyle(fontWeight: FontWeight.bold)
    );

    return Scaffold(
      body: IntroSlider(
        listContentConfig: slides,
        nextButtonStyle: buttonStyle,
        doneButtonStyle: buttonStyle,
        skipButtonStyle: buttonStyle,
        onSkipPress: () => onDone(context, role),
        onDonePress: () => onDone(context, role),
      ),
    );
    
  }
}

/// SliderManager is a custom class we created to craft
/// and return the seller or buyer slides by simply
/// calling the sellerSlides() or buyerSlides()
/// class methods
class SliderManager {

  ///  getContentConfig is a custom function that we created
  ///  to dynamically create the slide content based on the
  ///  information provided e.g title, description, image,
  ///  e.t.c
  static ContentConfig getContentConfig({
    String title = '',
    dynamic description,
    required Widget image,
    bool setImageHeight = true,
    required BuildContext context
  }) {

    /// Build the actual slide using the package provided Widget
    return ContentConfig(
      marginTitle: const EdgeInsets.all(0),
      centerWidget: Container(
        constraints: const BoxConstraints(
          maxWidth: 400
        ),
        child: Column(
          children: [

            /**
             *  Image
             * 
             *  Set the SizedBox height so that the content does not
             *  jump while waiting for the images to be loaded from
             *  the device storage.
             */
            setImageHeight 
              ? SizedBox(
                  height: 400,
                  child: image,
                )
              : image,

            //  Title
            if(title.isNotEmpty) Text(
              title.toUpperCase(),
              style: Theme.of(context).textTheme.titleLarge!
            ),

            //  Spacer
            const SizedBox(height: 32),

            //  Description
            if (description != null)
              (description.runtimeType == String
                ? Text(
                    description,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium!
                  )
                : description),

            //  Spacer
            const SizedBox(height: 100)
            
          ],
        ),
      )
    );
  }

  /// The seller introduction slides
  static List<ContentConfig> sellerSlides(BuildContext context) {

    return [

      //  Slide 1
      getContentConfig(
        title: 'Welcome',
        context: context,
        setImageHeight: false,
        image: Container(
          width: 200,
          margin: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.3,
            bottom: MediaQuery.of(context).size.height * 0.05,
          ),
          child: Image.asset('assets/images/logo-black.png')
        ),
        description: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: 'Sell goods and services to local customers and get paid while reaching more people all in one space',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(height: 1.4),
            ),
          ),
        )
      ),
      
      //  Slide 2
      getContentConfig(
        title: 'Sell Your Best',
        context: context,
        image: Image.asset('assets/images/intro_slides/inventory.png'),
        description: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: 'Perfect Order lets you sell up to five',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(height: 1.6),
              children: const <TextSpan>[
                TextSpan(
                  text: '✋', style: TextStyle(fontSize: 32, height: 0.5)
                ),
                TextSpan(
                  text: 'products at a time. This means picking your best fast-selling and on-demand products. Avoid the clutter and confusion of selling too many products at the same time'
                ),
              ],
            ),
          ),
        )
      ),
      
      //  Slide 3
      getContentConfig(
        title: 'Dial 2 Buy',
        context: context,
        image: Image.asset('assets/images/intro_slides/customer.png'),
        description: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: 'No WIFI, No Mobile Data, No Airtime, No problem. Your customers simply Dial to Buy ',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(height: 1.6),
              children: const <TextSpan>[
                TextSpan(
                  text: '😍', style: TextStyle(fontSize: 28, height: 0.5)
                ),
                TextSpan(
                  text: ' At work, home or in traffic, your customers can place those orders at that special moment of inspiration'
                ),
              ],
            ),
          ),
        )
      ),
      
      //  Slide 4
      getContentConfig(
        title: 'Team Up',
        context: context,
        image: Image.asset('assets/images/intro_slides/team.png'),
        description: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: '${constants.appName} makes it easy to invite',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(height: 1.6),
              children: const <TextSpan>[
                TextSpan(
                  text: '🤝', style: TextStyle(fontSize: 32, height: 0.5)
                ),
                TextSpan(
                  text: 'friends, family and co-workers to help grow your business and make more profit. Dreams and teams work together'
                ),
              ],
            ),
          ),
        )
      ),
      
      //  Slide 5
      getContentConfig(
        context: context,
        image: Image.asset('assets/images/intro_slides/celebration.png'),
        description: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: 'Thats it!  ',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(height: 1.6),
              children: const <TextSpan>[
                TextSpan(
                  text: '🙌', style: TextStyle(fontSize: 32, height: 0.5)
                ),
                TextSpan(
                  text: '\nIt\'s time to create your store and start selling'
                ),
              ],
            ),
          ),
        )
      )

    ];
    
  }

  /// The buyer introduction slides
  static List<ContentConfig> buyerSlides(BuildContext context) {

    return [

      //  Slide 1
      getContentConfig(
        title: 'Welcome',
        context: context,
        image: Container(
          width: 200,
          margin: const EdgeInsets.only(top: 100, bottom: 40),
          child: Image.asset('assets/images/logo-black.png')
        ),
        description: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: 'Buy goods and services from your favourite local suppliers all in one space',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(height: 1.4),
            ),
          ),
        )
      ),
      
      //  Slide 2
      getContentConfig(
        title: 'Buy Only The Best',
        context: context,
        image: Image.asset('assets/images/intro_slides/comparing.png'),
        description: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: '${constants.appName} reduces your options for the best shopping experience. Local sellers list their top 5 best products so that you can ',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(height: 1.6),
              children: const <TextSpan>[
                TextSpan(
                  text: '😍', style: TextStyle(fontSize: 24, height: 0.5)
                ),
                TextSpan(
                  text: ' pick from the best in store'
                ),
              ],
            ),
          ),
        )
      ),
      
      //  Slide 3
      getContentConfig(
        title: 'Split The Bill',
        context: context,
        image: Image.asset('assets/images/intro_slides/sharing.png'),
        description: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: 'Place an order and share that ',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(height: 1.6),
              children: const <TextSpan>[
                TextSpan(
                  text: '🤝', style: TextStyle(fontSize: 32, height: 0.5)
                ),
                TextSpan(
                  text: ' bill with two or more friends, family or co-workers. You don’t have to pay for that order alone. ${constants.appName} makes it easy for others to contribute and split those costs.'
                ),
              ],
            ),
          ),
        )
      ),
      
      //  Slide 4
      getContentConfig(
        title: 'Follow Your Plug',
        context: context,
        image: Image.asset('assets/images/intro_slides/followers.png'),
        description: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: 'Like what you get from your plug? ',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(height: 1.6),
              children: const <TextSpan>[
                TextSpan(
                  text: '👌', style: TextStyle(fontSize: 32, height: 0.5)
                ),
                TextSpan(
                  text: ' ${constants.appName} makes it easy to follow your favourite stores and always get the best of what you like'
                ),
              ],
            ),
          ),
        )
      ),

      //  Slide 5
      getContentConfig(
        context: context,
        image: Image.asset('assets/images/intro_slides/celebration.png'),
        description: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: 'Thats it!  ',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(height: 1.6),
              children: const <TextSpan>[
                TextSpan(
                  text: '🙌', style: TextStyle(fontSize: 32, height: 0.5)
                ),
                TextSpan(
                  text: '\nIt\'s time to start shopping'
                ),
              ],
            ),
          ),
        )
      )

    ];
    
  }

}



