import 'package:flutter/material.dart';

class CustomBottomModalSheet extends StatefulWidget {

  final bool disabled;
  final Widget trigger;
  final Widget content;
  final double heightFactor;
  final Function()? onClose;

  const CustomBottomModalSheet({ 
    super.key,
    this.onClose,
    this.disabled = false,
    required this.trigger,
    required this.content,
    this.heightFactor = 0.7
  });

  @override
  State<CustomBottomModalSheet> createState() => CustomBottomModalSheetState();
}

class CustomBottomModalSheetState extends State<CustomBottomModalSheet> {
  
  void showBottomSheet(BuildContext context) async {
    /// If this is disabled, then do not open the bottom modal sheet
    if(widget.disabled) return;

    /// Await so that we can know that this bottom modal sheet was closed
    await showModalBottomSheet(
      elevation: 5,
      context: context,
      isScrollControlled: true,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0)
      ),
      builder: ( BuildContext context ) {

          /// Set the initial height factor provided by the widget
          double currHeightFactor = widget.heightFactor;

          /**
           *  StatefulBuilder widget helps us adjust the height of the 
           *  modal bottom sheet by changing the state height factor
           *  value
           * 
           *  Reference: https://stackoverflow.com/questions/52414629/how-to-update-state-of-a-modalbottomsheet-in-flutter
           */
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState /*You can rename this!*/) {
            
            /**
             *  FractionallySizedBox widget helps us adjust the height of the 
             *  modal bottom sheet. This way we can decide whether to set a 
             *  full height e.g "1.0" or a fraction of the full height e.g 
             *  "0.5". This only works if we also set isScrollControlled to 
             *  "true" on the showModalBottomSheet() method.
             * 
             *  Reference: https://stackoverflow.com/questions/53311553/how-to-set-showmodalbottomsheet-to-full-height/72791083#72791083
             */
            return FractionallySizedBox(
              heightFactor: currHeightFactor,
              child: ModalContent(
                content: widget.content
              ),
            );
          }
        );
      }
    );

    /// Notify the parent that the bottom modal sheet was closed
    if(widget.onClose != null) widget.onClose!();

  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showBottomSheet(context),
      child: widget.trigger
    );
  }
}

class ModalContent extends StatefulWidget {

  final Widget content;

  const ModalContent({ 
    super.key,
    required this.content,
  });

  @override
  State<ModalContent> createState() => _ModalContentState();

}

class _ModalContentState extends State<ModalContent> {

  Widget get content => widget.content;

  @override
  Widget build(BuildContext context) {
    /// The GestureDetector helps us to unfocus from input fields
    /// such as the CustomSearchTextFormField. Its annoying when
    /// we focus into the search bar but have a hard time trying
    /// to unfocus and hide the keyboard. This allows us to
    /// unfocus by interacting anywhere outside of the
    /// input field. 
    /// 
    /// Reference 1: https://github.com/flutter/flutter/issues/54277
    /// Reference 2: https://stackoverflow.com/questions/67148239/how-to-stop-text-field-from-getting-auto-focused-when-accessing-drawer-in-flutte
    return GestureDetector(
      onTap: () {
        final FocusScopeNode currentScope = FocusScope.of(context);
        if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
          FocusManager.instance.primaryFocus!.unfocus();
        }
      },
      /// Scaffold helps the Snackbar to appear on top of the 
      /// Bottom Modal Sheet, otherwise the default behaviour
      /// without this Scaffold is to hide any Snackbar that
      /// appears behind the Bottom Modal Sheet which makes
      /// it difficult to see important notifications such
      /// as when errors occur.
      child: Scaffold(
        backgroundColor: Colors.white,
        body: content,
      ),
    );
  }
}