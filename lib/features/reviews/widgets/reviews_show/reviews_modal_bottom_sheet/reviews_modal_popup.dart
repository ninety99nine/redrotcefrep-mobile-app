import '../../../../../../core/shared_widgets/bottom_modal_sheet/custom_bottom_modal_sheet.dart';
import '../../../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../../stores/models/shoppable_store.dart';
import 'package:flutter/material.dart';
import '../reviews_content.dart';

class ReviewsModalBottomSheet extends StatefulWidget {
  
  final ShoppableStore store;

  const ReviewsModalBottomSheet({
    super.key,
    required this.store
  });

  @override
  State<ReviewsModalBottomSheet> createState() => _ReviewsModalBottomSheetState();
}

class _ReviewsModalBottomSheetState extends State<ReviewsModalBottomSheet> {

  ShoppableStore get store => widget.store;
  String get totalReviews => widget.store.reviewsCount!.toString();
  String get totalReviewsText => widget.store.reviewsCount == 1 ? 'Review' : 'Reviews';

  @override
  Widget build(BuildContext context) {
    return CustomBottomModalSheet(
      /// Trigger to open the bottom modal sheet
      trigger: CustomBodyText([totalReviews, totalReviewsText]),
      /// Content of the bottom modal sheet
      content: ReviewsContent(
        store: store,
      ),
    );
  }
}