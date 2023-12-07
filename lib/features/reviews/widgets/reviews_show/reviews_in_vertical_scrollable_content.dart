import 'package:bonako_demo/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:bonako_demo/features/authentication/providers/auth_provider.dart';
import 'package:bonako_demo/features/reviews/enums/review_enums.dart';
import 'package:bonako_demo/features/stores/widgets/store_cards/store_card/primary_section_content/profile/profile_left_side/store_name.dart';
import 'package:bonako_demo/features/stores/widgets/store_cards/store_card/primary_section_content/store_logo.dart';

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
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import '../../models/review.dart';
import 'dart:convert';

class ReviewsInVerticalScrollableContent extends StatefulWidget {
  
  final User? reviewer;
  final String reviewFilter;
  final ShoppableStore? store;
  final Function(Review) onViewReview;
  final UserReviewAssociation? userReviewAssociation;

  const ReviewsInVerticalScrollableContent({
    Key? key,
    this.store,
    this.reviewer,
    required this.onViewReview,
    required this.reviewFilter,
    this.userReviewAssociation
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
  ShoppableStore? get store => widget.store;
  String get reviewFilter => widget.reviewFilter;
  Function(Review) get onViewReview => widget.onViewReview;
  UserReviewAssociation? get userReviewAssociation => widget.userReviewAssociation;
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
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
  Widget onRenderItem(review, int index, List reviews, bool isSelected, List selectedItems, bool hasSelectedItems, int totalSelectedItems) {

    return ReviewItem(
      reviewer: reviewer,
      onViewReview: onViewReview,
      review: (review as Review),
    );

  }

  /// Render each request item as an Review
  Review onParseItem(review) => Review.fromJson(review);
  Future<dio.Response> requestReviews(int page, String searchWord) {
    
    Future<dio.Response> request;

    /**
     *  If the store is not provided, then we must load the current authenticated user's reviews.
     */
    if( store == null ) {

      /// Request the user orders
      request = authProvider.userRepository.showReviews(
        /// Since we don't have the store, we can eager load the store on each review.
        /// Note that the user review association must be specifiec e.g 
        /// 
        /// userReviewAssociation = "reviewer"     - Return reviews where the user is associated as a reviewer
        /// userReviewAssociation = "team member"  - Return reviews where the user is associated as a team member to stores where these reviews belong
        withUser: userReviewAssociation == UserReviewAssociation.teamMember,
        userReviewAssociation: userReviewAssociation!,
        searchWord: searchWord,
        filter: reviewFilter,
        withStore: true,
        page: page
      );

    /// If the store is provided
    }else{

      final int? userId = reviewer == null ? null : reviewer!.id;

      /// Request the store reviews
      request = storeProvider.setStore(store!).storeRepository.showReviews(
        searchWord: searchWord,
        filter: reviewFilter,
        withUser: true,
        userId: userId,
        page: page
      );
      
    }

    return request.then((response) {

      if( response.statusCode == 200 ) {

        setState(() {

          /// If the response review count does not match the store review count
          if(searchWord.isEmpty && reviewFilter == 'All' && store != null && store!.reviewsCount != response.data['total']) {

            store!.reviewsCount = response.data['total'];
            store!.runNotifyListeners();

          }

        });
        
      }

      return response;

    });
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
      onRequest: (page, searchWord) => requestReviews(page, searchWord),
      contentAfterSearchBar: reviewer == null ? null : reviewerMessageAlert,
      headerPadding: const EdgeInsets.only(top: 32, bottom: 0, left: 16, right: 16),
      listPadding: EdgeInsets.only(top: 0, bottom: 0, left: store == null ? 0 : 16, right: 16),
    );
  }
}

class ReviewItem extends StatelessWidget {
  
  final Review review;
  final User? reviewer;
  final Function(Review) onViewReview;

  const ReviewItem({
    super.key,
    this.reviewer,
    required this.review,
    required this.onViewReview,
  });

  ShoppableStore? get store => review.relationships.store;
  User? get _reviewer => reviewer ?? review.relationships.user;

  @override
  Widget build(BuildContext context) {

    return ListTile(
        dense: true,
        key: ValueKey<int>(review.id),
        onTap: () => onViewReview(review),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            if(store != null) ...[

              /// Store Logo
              StoreLogo(store: store!),

              /// Spacer
              const SizedBox(width: 8),

            ],

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                /// If the reviewer is specified but the store is not specified
                if(_reviewer != null && store == null) ...[
                  
                  /// Reviewer's name
                  CustomTitleMediumText(_reviewer!.attributes.name),

                ],
                    
                /// If the store is specified
                if(store != null) ...[
                  
                  /// Reviewer's name
                  CustomTitleSmallText(
                    store!.name, 
                    overflow: TextOverflow.ellipsis
                  ),
            
                  /// Spacer
                  const SizedBox(height: 4),

                  /// If both the reviewer and store is specified
                  if(_reviewer != null) ...[
                  
                    /// Title
                    CustomBodyText(_reviewer!.attributes.name, lightShade: true,),
              
                    /// Spacer
                    const SizedBox(height: 4),

                  ],
            
                ],

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
        
                /// Review Comment
                if(review.comment != null) CustomBodyText(review.comment!, margin: const EdgeInsets.only(top: 8)),
        
              ],
            ),
          ],
        ),
        
        /// Review Created At
        trailing: CustomBodyText(timeago.format(review.createdAt, locale: 'en_short')),
        
      );
  }
}