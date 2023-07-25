import '../../../../../../../../core/shared_widgets/text/custom_title_medium_text.dart';
import '../../../../../../../../core/shared_widgets/icons/verified_icon.dart';
import '../../../../../../models/shoppable_store.dart';
import 'package:flutter/material.dart';

class StoreName extends StatelessWidget {

  final ShoppableStore store;

  const StoreName({
    super.key,
    required this.store
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        //  Store name
        Flexible(
          child: CustomTitleMediumText(
            store.name, 
            overflow: TextOverflow.ellipsis
          )
        ),

        //  Spacer
        const SizedBox(width: 4,),

        //  Store Verified Checkmark 
        VerifiedIcon(verified: store.verified)

      ],
    );
  }
}