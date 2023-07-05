
import '../../../core/shared_widgets/text/custom_title_large_text.dart';
import '../services/auth_form_service.dart';
import 'package:flutter/material.dart';

class AuthScaffold extends StatefulWidget {

  final Widget form;
  final String title;
  final String? imageUrl;
  final double topHeightRatio;
  final AuthFormService authForm;

  const AuthScaffold({ 
    super.key, 
    this.imageUrl,
    required this.form,
    required this.title,
    required this.authForm,
    this.topHeightRatio = 0.05,
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
        floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
        floatingActionButton: authForm.floatingButtonAction == null ? null : authForm.floatingActionButton(),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [

                /**
                 *  Image
                 * 
                 *  Set the SizedBox height so that the content does not
                 *  jump while waiting for the images to be loaded from
                 *  the device storage.
                 */
                if(widget.imageUrl != null) SizedBox(
                  height: 400,
                  child: Image.asset(widget.imageUrl!),
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