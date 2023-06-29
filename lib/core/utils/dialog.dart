import 'dart:convert';

import 'package:bonako_demo/core/shared_widgets/button/custom_elevated_button.dart';
import 'package:bonako_demo/core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import 'package:bonako_demo/core/shared_widgets/text_form_field/custom_text_form_field.dart';
import 'package:bonako_demo/core/utils/snackbar.dart';
import 'package:bonako_demo/features/api/providers/api_provider.dart';
import 'package:bonako_demo/features/api/repositories/api_repository.dart';
import 'package:provider/provider.dart';

import '../shared_widgets/Loader/custom_circular_progress_indicator_with_text.dart';
import '../shared_widgets/text/custom_title_small_text.dart';
import '../shared_widgets/button/custom_text_button.dart';
import '../shared_widgets/text/custom_body_text.dart';
import 'package:flutter/material.dart';

class DialogUtility {

  /// Show a dialog that supports any kind of content
  static Future<bool?> showBlankDialog({ required content, required BuildContext context }) {

    return showDialog<bool>(
      context: context, 
      builder: (dialogContext) {
        return content;
      }
    );

  }

  /// Show a dialog that supports the dynamic infinite scroll content
  static Future<bool?> showInfiniteScrollContentDialog({ required content, required BuildContext context }) {

    Widget dialogContent() {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          
          /// Content
          content,
  
          /// Cancel Icon
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              /// This padding is to increase the surface area for the gesture detector
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                /// This container is to provide a white background around the cancel icon
                /// so that as we scoll and the content passes underneath the icon we do
                /// not see the content showing up on the transparent parts of the icon
                child: Container(
                  decoration: BoxDecoration(
                  color: Colors.white,
                    borderRadius: BorderRadius.circular(20)
                  ),
                  child: Icon(Icons.cancel, size: 28, color: Theme.of(context).primaryColor,)
                ),
              ),
              onTap: () => Navigator.of(context).pop(),
            ),
          ),

        ],
      );
    }

    return showDialog<bool>(
      context: context, 
      builder: (context) {
        /// The layout builder is required so that we can support widgets
        /// that use the ListView widget e.g our CustomVerticalListViewInfiniteScroll().
        /// The constraints are required so that we can set the height
        /// using the SizedBox() as see below.
        /// Reference: https://stackoverflow.com/questions/73233497/rendershrinkwrappingviewport-does-not-support-returning-intrinsic-dimensions
        return LayoutBuilder(
          builder: (context, constraints) {
            return AlertDialog(
              content: SizedBox(
                /// On scrollable content such as using CustomVerticalListViewInfiniteScroll(),
                /// set the width and height dynamically based on the given
                /// constraints
                height: constraints.maxHeight * 0.6,
                width: constraints.maxWidth,
                child: dialogContent()
              ),
              /// The contentPadding is zero so that we can allow the Cancel Icon to be as close as
              /// possible to the edges of the Alert Dialog. The SingleChildScrollView will handle
              /// the padding of the content.
              contentPadding: const EdgeInsets.all(0.0),
          
              /// The insetPadding has been modified so that the Dialog is as close as possible to
              /// the screen edges. The default padding is too much and makes the dialog to narrow
              /// on smaller devices.
              insetPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 24.0),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16.0))),
            );
          }
        );
      }
    );

  }

  /// Show a dialog that supports static or dynamic content
  static Future<bool?> showContentDialog({ String title = '', required content, List<Widget>? actions, required BuildContext context }) {

    Widget dialogContent() {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                /**
                 *  The mainAxisSize: MainAxisSize.min will
                 *  Auto size AlertDialog to fit content
                 * 
                 *  Reference: https://stackoverflow.com/questions/54669630/flutter-auto-size-alertdialog-to-fit-list-content
                 */
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              
                    /// Title
                    if(title.isNotEmpty) CustomTitleSmallText(title),
              
                    /// Spacer
                    if(title.isNotEmpty) const Divider(height: 24,),
              
                    /// Content
                    content
              
                ],
              ),
            ),
          ),
  
          /// Cancel Icon
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              /// This padding is to increase the surface area for the gesture detector
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Icon(Icons.cancel, size: 28, color: Theme.of(context).primaryColor,),
              ),
              onTap: () => Navigator.of(context).pop(),
            ),
          ),

        ],

      );
    }

    return showDialog<bool>(
      context: context, 
      builder: (context) {
        return AlertDialog(
          actions: actions,
          content: dialogContent(),
          /// The contentPadding is zero so that we can allow the Cancel Icon to be as close as
          /// possible to the edges of the Alert Dialog. The SingleChildScrollView will handle
          /// the padding of the content.
          contentPadding: const EdgeInsets.all(0.0),
          actionsPadding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),

          /// The insetPadding has been modified so that the Dialog is as close as possible to
          /// the screen edges. The default padding is too much and makes the dialog to narrow
          /// on smaller devices.
          insetPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 24.0),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16.0))),
        );
      }
    );

  }








  /// Show a dialog that allows us to confirm the delete of an Api Resource action
  static Future<bool?> showConfirmDeleteApiResourceDialog({ String? resourceName, required String confirmDeleteUrl, required String deleteUrl, required void Function() onDeleted, required BuildContext context }) {

    Widget confirmContent() {

      String code = '';
      String message = '';
      bool isLoading = false;
      bool isDeleting = false;
      String userProvidedCode = '';
      bool confirmDeleteRequested = false;

      ApiProvider apiProvider = Provider.of<ApiProvider>(context, listen: false);
      ApiRepository apiRepository = apiProvider.apiRepository;

      /// Get the confirmation code required to delete the resource
      void confirmDelete(StateSetter setState) {

        confirmDeleteRequested = true;
        setState(() => isLoading = true);

        apiRepository.post(url: confirmDeleteUrl).then((response) {

          if( response.statusCode == 200) {

            setState(() {

              final responseBody = jsonDecode(response.body);
              code = responseBody['code'].toString();
              message = responseBody['message'];

            });
          
          }else{

            /// Close e.g When the resource does not exist
            Navigator.of(context).pop(false);

          }

        }).whenComplete(() {

          setState(() => isLoading = false);

        });

      }

      /// Delete the resource
      void delete(StateSetter setState) {

        setState(() => isDeleting = true);

        Map body = {
          'code': code
        };

        apiRepository.delete(url: deleteUrl, body: body).then((response) {

          if(response.statusCode == 200) {

            final responseBody = jsonDecode(response.body);
            message = responseBody['message'];

            /// Notify parent on deleted
            onDeleted();

            Navigator.of(context).pop(true);

            SnackbarUtility.showSuccessMessage(message: message);

          }else {

            Navigator.of(context).pop(false);

            SnackbarUtility.showSuccessMessage(message: 'Failed to delete');

          }

        }).whenComplete(() {

          setState(() => isDeleting = true);

        });

      }

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      
          /// Run this method immediately
          if(confirmDeleteRequested == false) confirmDelete(setState);

          return Stack(
            clipBehavior: Clip.none,
            children: [

              Column(
                /**
                 *  The mainAxisSize: MainAxisSize.min will
                 *  Auto size AlertDialog to fit content
                 * 
                 *  Reference: https://stackoverflow.com/questions/54669630/flutter-auto-size-alertdialog-to-fit-list-content
                 */
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomTitleSmallText('Confirm Delete'),
                  const Divider(height: 24,),

                  SizedBox(
                    width: double.infinity,
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 500),
                      child: AnimatedSwitcher(
                        switchInCurve: Curves.easeIn,
                        switchOutCurve: Curves.easeOut,
                        duration: const Duration(milliseconds: 500),
                        child: isLoading || isDeleting ? const CustomCircularProgressIndicator() : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                    
                            /// Delete Confirmation Message
                            if(resourceName != null) CustomTitleSmallText(resourceName, overflow: TextOverflow.ellipsis,),
                    
                            /// Divider
                            if(resourceName != null) const SizedBox(height: 8,),
                    
                            /// Delete Confirmation Message
                            CustomBodyText(message),
                    
                            /// Divider
                            const Divider(height: 24,),
                    
                            /// Text Form Field To Confirm Delete Resource
                            CustomTextFormField(
                              maxLength: 6,
                              hintText: code,
                              onChanged: (value) {
                                setState(() => userProvidedCode = value);
                              },
                            ),
                    
                            /// Divider
                            const SizedBox(height: 24,),
                    
                            CustomElevatedButton(
                              'Delete',
                              isError: true,
                              isLoading: isDeleting,
                              onPressed: () => delete(setState),
                              disabled: userProvidedCode.isEmpty || code.isEmpty || userProvidedCode != code,
                            )
                    
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),

              /// Cancel Icon
              Positioned(
                top: -24,
                right: -16,
                child: GestureDetector(
                  /// This padding is to increase the surface area for the gesture detector
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Icon(Icons.cancel, size: 28, color: Theme.of(context).primaryColor,),
                  ),
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),

            ],
          );

        },
      );
    }

    return showDialog<bool>(
      context: context, 
      builder: (context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16.0))),
          actionsPadding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
          contentPadding: const EdgeInsets.all(24.0),
          content: confirmContent()
        );
      }
    );

  }









  /// Show a dialog that allows us to confirm an action
  static Future<bool?> showConfirmDialog({ required content, String title = 'Confirm', required BuildContext context }) {

    Widget confirmContent() {
      return Column(
        /**
         *  The mainAxisSize: MainAxisSize.min will
         *  Auto size AlertDialog to fit content
         * 
         *  Reference: https://stackoverflow.com/questions/54669630/flutter-auto-size-alertdialog-to-fit-list-content
         */
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            CustomTitleSmallText(title),
            const Divider(height: 24,),
            CustomBodyText(content),
        ],
      );
    }

    return showDialog<bool>(
      context: context, 
      builder: (context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16.0))),
          contentPadding: const EdgeInsets.all(24.0),
          content: content.runtimeType == String ? confirmContent() : content,
          actionsPadding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
          actions: [

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [

                /// No action
                CustomTextButton(
                  'No',
                  color: Colors.grey,
                  onPressed: () => Navigator.of(context).pop(false),
                ),

                /// Spacer
                const SizedBox(width: 8,),

                /// Yes action
                CustomTextButton(
                  'Yes',
                  onPressed: () => Navigator.of(context).pop(true),
                ),
                
              ],
            )

          ],
        );
      }
    );

  }

  /// Show a dialog that displays a loading indicator
  static void showLoader({ required BuildContext context, String message = 'Loading...' }) {
    
    showDialog(
      context: context,
      builder: (BuildContext context) {

        ///  Return an alert dialog with a circular loader and loading message
        return AlertDialog(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(50.0))),
          contentPadding: const EdgeInsets.all(15.0),
          content: SizedBox(
            height: 20,
            child: CustomCircularProgressIndicatorWithText(
              message,
              mainAxisAlignment: MainAxisAlignment.center,
            ),
          )
        );

      }
    );

  }

  /// Hide the loading indicator dialog
  static void hideLoader(BuildContext context) {
        
    ///  Hide the loading dialog
    Navigator.of(context, rootNavigator: true).pop('dialog');

  }


}