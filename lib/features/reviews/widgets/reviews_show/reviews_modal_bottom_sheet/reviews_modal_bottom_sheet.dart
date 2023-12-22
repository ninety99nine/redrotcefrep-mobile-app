import '../../../../../../core/shared_widgets/bottom_modal_sheet/custom_bottom_modal_sheet.dart';
import '../../../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../../stores/models/shoppable_store.dart';
import '../../../enums/review_enums.dart';
import 'package:flutter/material.dart';
import '../reviews_content.dart';

class ReviewsModalBottomSheet extends StatefulWidget {
  
  final String? reviewFilter;
  final ShoppableStore? store;
  final void Function()? onCreatedReview;
  final ReviewContentView? reviewContentView;
  final Widget Function(Function())? trigger;
  final UserReviewAssociation? userReviewAssociation;

  const ReviewsModalBottomSheet({
    super.key,
    this.store,
    this.trigger,
    this.reviewFilter,
    this.onCreatedReview,
    this.reviewContentView,
    this.userReviewAssociation
  });

  @override
  State<ReviewsModalBottomSheet> createState() => _ReviewsModalBottomSheetState();
}

class _ReviewsModalBottomSheetState extends State<ReviewsModalBottomSheet> {

  ShoppableStore? get store => widget.store;
  String? get reviewFilter => widget.reviewFilter;
  Function()? get onCreatedReview => widget.onCreatedReview;
  Widget Function(Function())? get trigger => widget.trigger;
  String get totalReviews => (store?.reviewsCount ?? 0).toString();
  ReviewContentView? get reviewContentView => widget.reviewContentView;
  String get totalReviewsText => store?.reviewsCount == 1 ? 'Review' : 'Reviews';
  UserReviewAssociation? get userReviewAssociation => widget.userReviewAssociation;

  /// This allows us to access the state of CustomBottomModalSheet widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomBottomModalSheetState> _customBottomModalSheetState = GlobalKey<CustomBottomModalSheetState>();

  Widget get _trigger {
    return trigger == null ? CustomBodyText([totalReviews, totalReviewsText]) : trigger!(openBottomModalSheet);
  }

  /// Open the bottom modal sheet
  void openBottomModalSheet() {
    if(_customBottomModalSheetState.currentState != null) {
      _customBottomModalSheetState.currentState!.showBottomSheet(context);
    } 
  }
  
  @override
  Widget build(BuildContext context) {
    return CustomBottomModalSheet(
      key: _customBottomModalSheetState,
      /// Trigger to open the bottom modal sheet
      trigger: _trigger,
      /// Content of the bottom modal sheet
      content: ReviewsContent(
        store: store,
        reviewFilter: reviewFilter,
        onCreatedReview: onCreatedReview,
        reviewContentView: reviewContentView,
        userReviewAssociation: userReviewAssociation
      ),
    );
  }
}