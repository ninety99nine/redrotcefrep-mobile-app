import '../../../../../core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import '../../../../../core/shared_widgets/button/custom_elevated_button.dart';
import '../../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../../../core/shared_models/shortcode.dart';
import '../../../../../core/utils/snackbar.dart';
import '../../../../../core/utils/dialer.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';

class SubscribeContent extends StatefulWidget {

  final Widget header;
  final Function()? onDial;
  final Function()? onResumed;
  final Future<dio.Response> generatePaymentShortcode;

  const SubscribeContent({
    super.key,
    this.onDial,
    this.onResumed,
    required this.header,
    required this.generatePaymentShortcode,
  });

  @override
  State<SubscribeContent> createState() => _SubscribeContentState();
}

class _SubscribeContentState extends State<SubscribeContent> with WidgetsBindingObserver{

  bool isLoading = false;
  Shortcode? paymentShortcode;

  Widget get header => widget.header;
  Function()? get onDial => widget.onDial;
  Function()? get onResumed => widget.onResumed;
  void _startLoader() => setState(() => isLoading = true);
  void _stopLoader() => setState(() => isLoading = false);
  bool get hasPaymentShortcode => paymentShortcode != null;
  Future<dio.Response> get generatePaymentShortcode => widget.generatePaymentShortcode;

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
      
      // Perform logic as soon as the App is resumed
      if(onResumed != null) onResumed!();

    }

  }

  void dial() {

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

    generatePaymentShortcode.then((response) {

      if(response.statusCode == 200) {

        paymentShortcode = Shortcode.fromJson(response.data);
        
        
      }

    }).catchError((error) {

      printError(info: error.toString());

      /// Show the error message
      SnackbarUtility.showErrorMessage(message: 'Failed to create payment shortcode');

    }).whenComplete((){

      _stopLoader();

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
                    
                    /// Header
                    header
                    
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
              onPressed: () => Get.back()
            ),
          ),
        ],
      ),
    );
  }
}