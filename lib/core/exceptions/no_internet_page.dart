import '../shared_widgets/button/custom_elevated_button.dart';
import '../shared_widgets/text/custom_title_large_text.dart';
import '../shared_widgets/text/custom_body_text.dart';
import 'package:flutter/material.dart';

class NoInternetPage extends StatelessWidget {

  static const routeName = 'NoInternetPage';
  final Function onTryAgain;

  const NoInternetPage({
    super.key, 
    required this.onTryAgain,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 150,
                    child: Image.asset('assets/images/disconnected.png')
                  ),
                ),
        
                /// Spacer
                const SizedBox(height: 50),
          
                /// Title
                const CustomTitleLargeText('No Internet'),
              
                /// Spacer
                const Divider(height: 50),
          
                /// Instruction
                const CustomBodyText(
                  'Please check your internet connectivity',
                  height: 1.6,
                ),
          
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