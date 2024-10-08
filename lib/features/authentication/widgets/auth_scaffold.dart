
import 'package:perfect_order/core/shared_widgets/animated_widgets/custom_rotating_widget.dart';

import '../../../core/shared_widgets/text/custom_title_large_text.dart';
import '../services/auth_form_service.dart';
import 'package:flutter/material.dart';

class AuthScaffold extends StatefulWidget {

  final Widget form;
  final String title;
  final String? imageUrl;
  final double? imageWidth;
  final double topHeightRatio;
  final AuthFormService authForm;
  final EdgeInsetsGeometry imageMargin;

  const AuthScaffold({ 
    super.key, 
    this.imageUrl,
    this.imageWidth,
    required this.form,
    required this.title,
    required this.authForm,
    this.topHeightRatio = 0.05,
    this.imageMargin = EdgeInsets.zero
  });

  @override
  State<AuthScaffold> createState() => _AuthScaffoldState();
}

class _AuthScaffoldState extends State<AuthScaffold> {

  AuthFormService get authForm => widget.authForm;

  @override
  Widget build(BuildContext context) {
    /**
     *  The GestureDetector is used to hide the soft input keyboard 
     *  after clicking outside TextField or anywhere on screen
     */
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: authForm.floatingButtonAction == null ? null : authForm.floatingActionButton(),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [

                /**
                 *  Image
                 * 
                 *  Set the Container height so that the content does not
                 *  jump while waiting for the image to be loaded from
                 *  the device storage.
                 */
                if(widget.imageUrl != null) Container(
                  margin: widget.imageMargin,
                  height: widget.imageWidth ?? 400,
                  child: CustomRotatingWidget(
                    animationDuration: const Duration(seconds: 2),
                    delayDuration: const Duration(seconds: 30),
                    child: Image.asset(widget.imageUrl!),
                  )
                ),
            
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        //  Title
                        CustomTitleLargeText(widget.title),
                        
                        //  Spacer
                        const SizedBox(height: 16),
                      
                        //  Body
                        widget.form,
                        
                        //  Spacer
                        SizedBox(
                          height: authForm.floatingButtonAction == null ? 100 : 200
                        ),
            
                      ],
                    ),
                  ),
                ),
          
              ],
            ),
          ),
        ),
      ),
    );
  }
}