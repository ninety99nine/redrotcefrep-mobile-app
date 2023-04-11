import '../../../../core/shared_widgets/message_alert/custom_message_alert.dart';
import '../../../../core/shared_widgets/infinite_scroll/custom_vertical_list_view_infinite_scroll.dart';
import '../../../../../core/shared_widgets/text/custom_title_medium_text.dart';
import '../../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../rating/widgets/rating_show_using_stars.dart';
import '../../../stores/providers/store_provider.dart';
import '../../../../../core/shared_models/user.dart';
import '../../../stores/models/shoppable_store.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../../models/review.dart';

class ReviewsInVerticalScrollableContent extends StatefulWidget {
  
  final User? reviewer;
  final ShoppableStore store;
  final String reviewFilter;
  final Function(Review) onViewReview;

  const ReviewsInVerticalScrollableContent({
    Key? key,
    this.reviewer,
    required this.store,
    required this.onViewReview,
    required this.reviewFilter,
  }) : super(key: key);

  @override
  State<ReviewsInVerticalScrollableContent> createState() => ReviewsScrollableContentState();
}

class ReviewsScrollableContentState extends State<ReviewsInVerticalScrollableContent> {

  /// This allows us to access the state of CustomVerticalListViewInfiniteScroll widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomVerticalInfiniteScrollState> _customVerticalListViewInfiniteScrollState = GlobalKey<CustomVerticalInfiniteScrollState>();

  User? get reviewer => widget.reviewer;
  ShoppableStore get store => widget.store;
  String get reviewFilter => widget.reviewFilter;
  Function(Review) get onViewReview => widget.onViewReview;
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);

  @override
  void didUpdateWidget(covariant ReviewsInVerticalScrollableContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    /// If the review subject changed
    if(reviewFilter != oldWidget.reviewFilter) {

      /// Start a new request (so that we can filter reviews by the specified review subject)
      _customVerticalListViewInfiniteScrollState.currentState!.startRequest();

    }
  }

  /// Render each request item as an ReviewItem
  Widget onRenderItem(review, int index, List reviews, bool isSelected, List selectedItems, bool hasSelectedItems, int totalSelectedItems) => ReviewItem(
    reviewer: reviewer,
    onViewReview: onViewReview,
    review: (review as Review),
  );

  /// Render each request item as an Review
  Review onParseItem(review) => Review.fromJson(review);
  Future<http.Response> requestStoreReviews(int page, String searchWord) {

    final int? userId = reviewer == null ? null : reviewer!.id;

    return storeProvider.setStore(store).storeRepository.showReviews(
      searchWord: searchWord,
      filter: reviewFilter,
      withUser: true,
      userId: userId,
      page: page
    );
  }

  Widget get reviewerMessageAlert {

    /// Instruction (On viewing a specific reviewer)
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 16),
      child: CustomMessageAlert('You are reading reviews from ${reviewer!.attributes.name}')
    );
  
  }
  
  @override
  Widget build(BuildContext context) {
    return CustomVerticalListViewInfiniteScroll(
      debounceSearch: true,
      onParseItem: onParseItem, 
      onRenderItem: onRenderItem,
      key: _customVerticalListViewInfiniteScrollState,
      catchErrorMessage: 'Can\'t show invitations',
      contentAfterSearchBar: reviewer == null ? null : reviewerMessageAlert,
      onRequest: (page, searchWord) => requestStoreReviews(page, searchWord),
      headerPadding: const EdgeInsets.only(top: 32, bottom: 0, left: 16, right: 16),
    );
  }
}

class ReviewItem extends StatelessWidget {
  
  final Review review;
  final User? reviewer;
  final Function(Review) onViewReview;

  const ReviewItem({
    super.key,
    required this.review,
    required this.reviewer,
    required this.onViewReview,
  });

  @override
  Widget build(BuildContext context) {

    return ListTile(
        dense: true,
        key: ValueKey<int>(review.id),
        onTap: () => onViewReview(review),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Reviewer's name
            if(reviewer == null) CustomTitleMediumText(review.relationships.user.attributes.name),
            
            Row(
              children: [

                /// Review Subject
                CustomBodyText('@${review.subject}', color: Colors.grey,),
                
                /// Spacer
                const SizedBox(width: 4,),

                /// Rating Stars
                RatingShowUsingStars(
                  rating: review.rating.toString(), 
                  showMultipleStars: true
                ),

              ],
            ),

          ],
        ),

        /// Review Comment
        subtitle: review.comment == null ? null : CustomBodyText(review.comment!, margin: const EdgeInsets.only(top: 8),),
        
        /// Review Created At
        trailing: CustomBodyText(timeago.format(review.createdAt, locale: 'en_short')),
        
      );
  }
}