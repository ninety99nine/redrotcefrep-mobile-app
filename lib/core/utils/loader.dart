import 'package:perfect_order/core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import 'package:flutter/material.dart';

class LoaderUtility {
  static OverlayEntry? _overlayEntry;

  static void showLoader(BuildContext context, { bool hideOnTap = true }) {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: GestureDetector(
          onTap: hideOnTap ? hideLoader : null,
          child: Container(
            color: Colors.white.withOpacity(0.9),
            child: const CustomCircularProgressIndicator(),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  static void hideLoader() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
