import '../shared_widgets/message_alert/custom_message_alert.dart';
import '../shared_widgets/button/custom_elevated_button.dart';
import '../shared_widgets/text/custom_title_large_text.dart';
import '../../../core/constants/constants.dart' as constants;
import '../shared_widgets/text/custom_body_text.dart';
import 'package:flutter/material.dart';

class SomethingWentWrongPage extends StatelessWidget {

  static const routeName = 'SomethingWentWrongPage';
  final String? fatalErrorMessage;
  final Function onTryAgain;

  const SomethingWentWrongPage({
    super.key, 
    this.fatalErrorMessage,
    required this.onTryAgain,
  });

  bool get hasFatalErrorMessage => fatalErrorMessage != null;

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
                const CustomTitleLargeText('Something Went Wrong'),
              
                /// Spacer
                const SizedBox(height: 30),
          
                /// Instruction
                const CustomBodyText(
                  constants.errorDebugMessage,
                  height: 1.6,
                ),
        
                /// Check if we have the fatal error message
                if(hasFatalErrorMessage) ...[
              
                  /// Spacer
                  const SizedBox(height: 30),
                  
                  /// Fatal error message
                  CustomMessageAlert(fatalErrorMessage!),
        
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