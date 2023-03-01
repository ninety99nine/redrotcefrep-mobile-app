import '../../../../../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../../../../../../core/shared_models/shortcode.dart';
import '../../../../../../models/shoppable_store.dart';
import 'package:flutter/material.dart';

class StoreVisitShortcode extends StatelessWidget {

  final ShoppableStore store;

  const StoreVisitShortcode({
    super.key,
    required this.store
  });

  bool get hasVisitShortcode => visitShortcode != null;
  Shortcode? get visitShortcode => store.relationships.visitShortcode;

  @override
  Widget build(BuildContext context) {
    return CustomBodyText(
      lightShade: !hasVisitShortcode,
      fontWeight: hasVisitShortcode ? FontWeight.bold : FontWeight.normal,
      hasVisitShortcode ? visitShortcode!.attributes.dial.code : 'No shortcode',
    );
  }
}