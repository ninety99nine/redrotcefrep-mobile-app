import 'package:bonako_demo/core/shared_widgets/text/custom_title_small_text.dart';

import '../../../../../../../../core/shared_widgets/text/custom_title_medium_text.dart';
import '../../../../../../../../core/shared_widgets/icons/verified_icon.dart';
import '../../../../../../models/shoppable_store.dart';
import 'package:flutter/material.dart';

enum StoreNameSize {
  small,
  big
}

class StoreName extends StatelessWidget {

  final ShoppableStore store;
  final StoreNameSize storeNameSize;

  const StoreName({
    super.key,
    required this.store,
    this.storeNameSize = StoreNameSize.small
  });

  Widget get smallStoreName {
    return Row(
      children: [

        //  Store name
        Flexible(
          child: CustomTitleSmallText(
            store.name, 
            overflow: TextOverflow.ellipsis
          )
        ),

        //  Spacer
        const SizedBox(width: 4,),

        //  Store Verified Checkmark 
        VerifiedIcon(verified: store.verified, size: 20)

      ],
    );
  }

  Widget get bigStoreName {
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

  @override
  Widget build(BuildContext context) {
    return storeNameSize == StoreNameSize.small ? smallStoreName : bigStoreName;
  }
}