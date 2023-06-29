import 'package:bonako_demo/core/shared_widgets/Loader/custom_circular_progress_indicator.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:flutter/material.dart';

class CustomBanner extends StatefulWidget {
  
  final String? text;
  final bool canShow;
  final double height;
  final bool isLoading;
  final String actionText;
  final Function()? onRefresh;

  const CustomBanner({
    super.key,
    this.onRefresh,
    this.height = 44,
    required this.text,
    this.canShow = true,
    this.isLoading = true,
    this.actionText = 'Open',
  });

  @override
  State<CustomBanner> createState() => _CustomBannerState();
}

class _CustomBannerState extends State<CustomBanner> {

  String? get text => widget.text;
  double get height => widget.height;
  bool get canShow => widget.canShow;
  bool get isLoading => widget.isLoading;
  String get actionText => widget.actionText;
  Function()? get onRefresh => widget.onRefresh;

  Widget? get content {

    if(isLoading) {

      return const CustomCircularProgressIndicator(
        size: 16, 
        strokeWidth: 1
      );

    }else{

      /// If we can show the contents of this banner
      if(canShow) {

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            /// Banner Text e.g You have 3 messages
            CustomBodyText(text ?? ''),

            /// Action Text e.g Open
            CustomBodyText(actionText, isLink: true),

            //  Refresh button
            if(onRefresh != null) IconButton(
              onPressed: onRefresh, 
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.refresh, color: Colors.grey,)
            )
          ],
        );

      /// If we cannot show the contents of this banner
      }else{

        return null;

      }

    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      height: canShow ? height : 0,
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200
      ),
      child: content,
    );
  }
}