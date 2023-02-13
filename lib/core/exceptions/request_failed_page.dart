import '../shared_widgets/message_alerts/custom_message_alert.dart';
import '../shared_widgets/buttons/custom_elevated_button.dart';
import '../shared_widgets/text/custom_title_large_text.dart';
import '../shared_widgets/text/custom_body_text.dart';
import '../constants/constants.dart' as constants;
import 'package:flutter/material.dart';

class RequestFailedPage extends StatelessWidget {

  static const routeName = 'RequestFailedPage';
  final String errorMessage;
  final Function onTryAgain;

  const RequestFailedPage({
    super.key, 
    this.errorMessage = '',
    required this.onTryAgain,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: 350,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            
              /// Spacer
              const SizedBox(height: 50),
        
              /// Title
              const CustomTitleLargeText('Something Went Wrong'),
            
              /// Spacer
              const Divider(height: 50),
        
              /// Instruction
              const CustomBodyText(
                'Sorry, we can\'t access the application services at the moment',
                height: 1.6,
              ),
            
              /// Spacer
              const SizedBox(height: 30),
        
              /// Instruction
              const CustomBodyText(
                constants.errorDebugMessage,
                height: 1.6,
              ),

              /// Error Message
              if(errorMessage.isNotEmpty) ...[
            
                /// Spacer
                const SizedBox(height: 30),
                
                /// Error Message Alert
                CustomMessageAlert(errorMessage),

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