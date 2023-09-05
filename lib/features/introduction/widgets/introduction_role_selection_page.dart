import 'package:get/get.dart';

import '../../../core/shared_widgets/text/custom_title_large_text.dart';
import '../../../core/shared_widgets/button/proceed_text_button.dart';
import '../../../core/shared_widgets/chips/custom_choice_chip.dart';
import '../../../core/shared_widgets/text/custom_body_text.dart';
import './../enums/introduction_enums.dart';
import './introduction_slides_page.dart';
import 'package:flutter/material.dart';

class IntroductionRoleSelectionPage extends StatefulWidget {

  static const routeName = 'IntroductionRoleSelectionPage';

  const IntroductionRoleSelectionPage({super.key});

  @override
  State<IntroductionRoleSelectionPage> createState() => _IntroductionRoleSelectionPageState();
  
}

class _IntroductionRoleSelectionPageState extends State<IntroductionRoleSelectionPage> {

  Role role = Role.seller;

  bool get isBuyer => role == Role.buyer;
  bool get isSeller => role == Role.seller;

  void changeRole (Role selectedRole) {

    setState(() {
      if( selectedRole == Role.seller ) {
        role = Role.seller;
      }else if( selectedRole == Role.buyer ) {
        role = Role.buyer;
      }
    });

  }

  void onContinue(BuildContext context) {

    Get.offAndToNamed(
      arguments: role,
      IntroductionSlidesPage.routeName,
    );

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          child: Column(
            children: [
              
              //  Spacer
              //  SizedBox(height: mediaQuery.height * 0.0),
      
              //  Images
              SizedBox(
                height: 430,
                child: Stack(
                  children: [
              
                    //  Seller image
                    AnimatedOpacity(
                      opacity: isSeller ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: Image.asset('assets/images/welcome/7.png'),
                    ),
              
                    //  Buyer image
                    AnimatedOpacity(
                      opacity: isSeller ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 500),
                      child: Image.asset('assets/images/welcome/6.png'),
                    )
              
                  ],
                ),
              ),
              
              //  Title
              const CustomTitleLargeText('Lets get started'),
              
              //  Spacer
              const SizedBox(height: 20),
        
              //  Body
              const CustomBodyText('Are you a seller or a buyer?'),
              
              //  Spacer
              const SizedBox(height: 20),
      
              //  Chips (Seller / Buyer)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  
                  //  Seller Option
                  CustomChoiceChip(
                    label: 'Seller', 
                    selected: isSeller,
                    onSelected: (_) {
                      changeRole(Role.seller);
                    },
                  ),
      
                  //  Spacer
                  const SizedBox(width: 20),
      
                  //  Buyer Option
                  CustomChoiceChip(
                    label: 'Buyer', 
                    selected: isBuyer,
                    onSelected: (_) {
                      changeRole(Role.buyer);
                    },
                  ),
                  
                ],
              ),
        
              //  Spacer
              const SizedBox(height: 40),
      
              //  Continue Button
              ProceedTextButton(
                'Continue',
                onPressed: () => onContinue(context),
              )
      
            ],
          ),
        ),
      ),
    );
  }
}
