import 'package:perfect_order/core/shared_widgets/button/custom_text_button.dart';
import '../../../../../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../../../../../../core/shared_models/shortcode.dart';
import '../../../../../../models/shoppable_store.dart';
import 'package:perfect_order/core/utils/dialer.dart';
import 'package:flutter/material.dart';

class StoreVisitShortcode extends StatelessWidget {

  final ShoppableStore store;

  const StoreVisitShortcode({
    super.key,
    required this.store
  });

  bool get hasVisitShortcode => visitShortcode != null;
  Shortcode? get visitShortcode => store.relationships.visitShortcode;

  Widget get shortcode {
    if(hasVisitShortcode) {
      return CustomTextButton(
        visitShortcode!.attributes.dial.code,
        padding: EdgeInsets.zero,
        onPressed: () {
          DialerUtility.dial(number: visitShortcode!.attributes.dial.code);
        },
      );
    }else{
      return const CustomBodyText(
        'No shortcode',
        lightShade: true,
        fontWeight: FontWeight.normal,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return shortcode;
  }
}