import '../../../../core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import '../../../../core/shared_widgets/button/custom_elevated_button.dart';
import '../../../../core/shared_widgets/text/custom_title_medium_text.dart';
import '../store_cards/store_card/primary_section_content/store_logo.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../../core/shared_models/shortcode.dart';
import '../../../../core/utils/snackbar.dart';
import '../../providers/store_provider.dart';
import '../../../../core/utils/dialer.dart';
import '../../models/shoppable_store.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';

class SubscribeToStoreContent extends StatefulWidget {

  final Function()? onDial;
  final ShoppableStore store;

  const SubscribeToStoreContent({
    super.key,
    this.onDial,
    required this.store,
  });

  @override
  State<SubscribeToStoreContent> createState() => _SubscribeToStoreContentState();
}

class _SubscribeToStoreContentState extends State<SubscribeToStoreContent> with WidgetsBindingObserver{

  bool isLoading = false;
  bool isFakeLoading = false;
  Shortcode? paymentShortcode;

  Function()? get onDial => widget.onDial;
  ShoppableStore get store => widget.store;
  void _startLoader() => setState(() => isLoading = true);
  void _stopLoader() => setState(() => isLoading = false);
  bool get hasPaymentShortcode => paymentShortcode != null;
  void _startFakeLoader() => setState(() => isFakeLoading = true);
  void _stopFakeLoader() => setState(() => isFakeLoading = false);
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);

  @override
  void initState() {
    super.initState();
    requestGeneratePaymentShortcode();

    // Register the observer to detect app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Remove the observer to detect app lifecycle changes
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {

    /**
     *  When the user clicks on the dial button, they will be moved away from the app.
     *  Once the user returns we want to refresh the stores immediately incase they
     *  subscribed and need to see that subscribed store.
     */
    if (state == AppLifecycleState.resumed) {

      /// Close this modal bottom sheet
      Get.back();
      
      // App is now resumed, perform logic to refresh stores
      storeProvider.refreshStores!();

    }

  }

  void dial() {

    /**
     *  The following is to fake a subscription
     */
    //  requestCreateFakeSubscription();
    //  return;

    /// Notify parent that we are dialing
    if(onDial != null) onDial!();

    /**
     *  We need to launch the dialer instead of using the
     *  fake subscription. So remove the code above and
     *  use the code below to continue the subscription
     *  via USSD instead of faking the subcription
     */
    DialerUtility.dial(
      number: paymentShortcode!.attributes.dial.code
    );

  }

  void requestGeneratePaymentShortcode() {

    _startLoader();

    storeProvider.setStore(store).storeRepository.generatePaymentShortcode()
    .then((response) {

      if(response.statusCode == 200) {

        final responseBody = jsonDecode(response.body);

        paymentShortcode = Shortcode.fromJson(responseBody);
        
        
      }

    }).catchError((error) {

      SnackbarUtility.showErrorMessage(message: 'Failed to create payment shortcode');

    }).whenComplete((){

      _stopLoader();

    });

  }

  void requestCreateFakeSubscription() {

    _startFakeLoader();

    storeProvider.setStore(store).storeRepository.createFakeSubscription()
    .then((response) {

      if(response.statusCode == 200) {

        /**
         *  Close the modal bottom sheet
         * 
         *  This must be placed before the SnackbarUtility.showSuccessMessage()
         *  since placing it after will hide the Snackbar message instead of
         *  the modal bottom sheet
         */
        Get.back();

        /// Notify parent that we are dialing
        if(onDial != null) onDial!();

        if(storeProvider.refreshStores != null) storeProvider.refreshStores!();
        
        SnackbarUtility.showSuccessMessage(message: 'You subscribed successfully');
        
      }

    }).catchError((error) {

      SnackbarUtility.showErrorMessage(message: 'Failed to subscribe');

    }).whenComplete((){

      _stopFakeLoader();

    });

  }

  Widget get content {

    return AnimatedSwitcher(
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      duration: const Duration(milliseconds: 500),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: hasPaymentShortcode ? [
    
          /// Payment shortcode instruction
          Container(
            margin: const EdgeInsets.symmetric(vertical: 32),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16)
            ),
            child: CustomBodyText(
              paymentShortcode!.attributes.dial.instruction
            ),
          ),
    
          /// Dial
          CustomElevatedButton(
            'Dial',
            onPressed: dial,
            isLoading: isFakeLoading,
            alignment: Alignment.center,
          )
    
        ] : [
    
          const CustomCircularProgressIndicator(
            margin: EdgeInsets.only(top: 40),
          ),
    
        ],
      ),
    );
    
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              
              /// Wrap Padding around the following:
              /// Title, Subtitle, Filters
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 32, bottom: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        //  Store Logo
                        StoreLogo(store: store, radius: 24),

                        /// Spacer
                        const SizedBox(width: 8,),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
              
                            /// Title
                            CustomTitleMediumText(store.name, overflow: TextOverflow.ellipsis, margin: const EdgeInsets.only(top: 4, bottom: 4),),
                            
                            /// Subtitle
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: CustomBodyText('Dial to subscribe'),
                            )

                          ],
                        )

                      ],
                    )
                    
                  ],
                ),
              ),

              /// Content
              Expanded(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  alignment: Alignment.topCenter,
                  width: double.infinity,
                  color: Colors.white,
                  child: content,
                ),
              )
          
            ],
          ),
  
          /// Cancel Icon
          Positioned(
            top: 8,
            right: 10,
            child: IconButton(
              icon: Icon(Icons.cancel, size: 28, color: Theme.of(context).primaryColor,),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}