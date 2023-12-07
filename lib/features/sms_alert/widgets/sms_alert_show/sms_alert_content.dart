import 'package:bonako_demo/core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import 'package:bonako_demo/features/authentication/providers/auth_provider.dart';
import '../../../../../core/shared_widgets/text/custom_title_medium_text.dart';
import 'package:bonako_demo/features/user/repositories/user_repository.dart';
import 'package:bonako_demo/features/sms_alert/models/sms_alert.dart';
import '../../../../../core/shared_widgets/text/custom_body_text.dart';
import 'sms_alert_page/sms_alert_page.dart';
import '../../enums/sms_alert_enums.dart';
import 'sms_alert_settings_content.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';

class SmsAlertContent extends StatefulWidget {
  
  final bool showingFullPage;
  final SmsAlertContentView? smsAlertContentView;

  const SmsAlertContent({
    super.key,
    this.smsAlertContentView,
    this.showingFullPage = false,
  });

  @override
  State<SmsAlertContent> createState() => _SmsAlertContentState();
}

class _SmsAlertContentState extends State<SmsAlertContent> {

  SmsAlert? smsAlert;
  bool isLoadingSmsAlert = false;
  SmsAlertContentView smsAlertContentView = SmsAlertContentView.viewingReviews;

  double get topPadding => showingFullPage ? 32 : 0;
  bool get showingFullPage => widget.showingFullPage;
  bool get isViewingReview => smsAlertContentView == SmsAlertContentView.viewingReview;
  bool get isViewingReviews => smsAlertContentView == SmsAlertContentView.viewingReviews;
  
  UserRepository get userRepository => authProvider.userRepository;
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);

  void _startSmsAlertLoader() => setState(() => isLoadingSmsAlert = true);
  void _stopSmsAlertLoader() => setState(() => isLoadingSmsAlert = false);

  String get title {
    return '💬 SMS Alerts';
  }
  
  @override
  void initState() {
    super.initState();
    requestShowSmsAlert();
  }

  /// Request the SMS Alert
  void requestShowSmsAlert() {

    if(isLoadingSmsAlert) return;

    _startSmsAlertLoader();
    
    userRepository.showSmsAlert().then((dio.Response response) {

      if(!mounted) return;

      if( response.statusCode == 200 ) {
        
        setState(() {

          smsAlert = SmsAlert.fromJson(response.data);

        });

      }

    }).whenComplete(() {
      
      _stopSmsAlertLoader();

    });

  }

  /// Content to show based on the specified view
  Widget get content {

    if(isLoadingSmsAlert) {

      return const CustomCircularProgressIndicator();

    /// If we want to view the reviews content
    }else if(isViewingReviews || isViewingReview) {

      /// Show reviews view
      return SmsAlertSettingsContent(smsAlert: smsAlert!);

    }else{

      /// Show the add review view
      /*
      return ReviewCreate(
        store: store,
        onLoading: onLoading,
        onUpdatedSmsAlert: _onUpdatedSmsAlert
      );
      */

      return const Text('');

    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Stack(
        children: [
          AnimatedSwitcher(
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            duration: const Duration(milliseconds: 500),
            child: Column(
              key: ValueKey(smsAlertContentView.name),
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                
                /// Wrap Padding around the following:
                /// Title, Subtitle, Filters
                Padding(
                  padding: EdgeInsets.only(top: 20 + topPadding, left: 32, bottom: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                
                      /// Title
                      CustomTitleMediumText(title, padding: const EdgeInsets.only(bottom: 8),),
                      
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
          ),
  
          /// Expand Icon
          if(!showingFullPage) Positioned(
            top: 8,
            right: 50,
            child: IconButton(
              icon: const Icon(Icons.open_in_full_rounded, size: 24, color: Colors.grey),
              onPressed: () {
                
                /// Close the Modal Bottom Sheet
                Get.back();
                
                /// Navigate to the page
                Get.toNamed(SmsAlertPage.routeName);
              
              }
            ),
          ),
  
          /// Cancel Icon
          Positioned(
            right: 10,
            top: 8 + topPadding,
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