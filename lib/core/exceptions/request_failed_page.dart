import 'package:bonako_demo/core/shared_widgets/text/custom_title_large_text.dart';

import '../shared_widgets/message_alert/custom_message_alert.dart';
import '../shared_widgets/button/custom_elevated_button.dart';
import '../../../core/constants/constants.dart' as constants;
import '../shared_widgets/text/custom_body_text.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;

class RequestFailedPage extends StatelessWidget {

  static const routeName = 'RequestFailedPage';
  final dio.Response failedResponse;
  final Function onTryAgain;

  const RequestFailedPage({
    super.key, 
    required this.onTryAgain,
    required this.failedResponse,
  });

  String? get requestMessage {
    if(failedResponse.data.containsKey('message')) {
      return failedResponse.data['message'];
    }
    return null;
  }

  String? get requestError {
    if(failedResponse.data.containsKey('error')) {
      return failedResponse.data['error'];
    }
    return null;
  }

  String? get displayMessage {
    if(hasRequestMessage && hasRequestError) {

      return '$requestMessage\n$requestError';

    }else if(hasRequestMessage) {

      return requestMessage!;

    }else if(hasRequestError) {

      return requestError!;

    }else{

      return null;

    }
  }

  bool get hasRequestError => requestError != null;
  bool get hasRequestMessage => requestMessage != null;
  bool get hasDisplayMessage => displayMessage != null;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 150,
                    child: Image.asset('assets/images/oops.png')
                  ),
                ),
        
                /// Spacer
                const SizedBox(height: 50),
          
                /// Title
                const CustomTitleLargeText('Service Unavailable'),
              
                /// Spacer
                const SizedBox(height: 30),
          
                /// Instruction
                const CustomBodyText(
                  constants.errorDebugMessage,
                  height: 1.6,
                ),
        
                /// Check if we have the display message
                if(hasDisplayMessage) ...[
              
                  /// Spacer
                  const SizedBox(height: 30),
                  
                  /// Request Message
                  CustomMessageAlert(displayMessage!),
        
                ],
          
                const Divider(height: 50),
        
                /// Button
                CustomElevatedButton(
                  'Try Again',
                  suffixIcon: Icons.refresh,
                  alignment: Alignment.center,
                  onPressed: () => onTryAgain()
                ),
          
              ],
            )
          ),
        ),
      )
   );

  }
}