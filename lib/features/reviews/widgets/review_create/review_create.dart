import 'package:bonako_demo/features/stores/widgets/stores_in_horizontal_list_view_infinite_scroll/stores_in_horizontal_list_view_infinite_scroll.dart';
import '../../../../../core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import '../../../../core/shared_widgets/text_form_field/custom_text_form_field.dart';
import '../../../../core/shared_widgets/button/custom_elevated_button.dart';
import '../../../../../core/shared_widgets/text/custom_body_text.dart';
import 'package:flutter_shake_animated/flutter_shake_animated.dart';
import 'package:bonako_demo/features/stores/enums/store_enums.dart';
import '../../../rating/widgets/rating_selector_using_stars.dart';
import 'package:bonako_demo/core/utils/error_utility.dart';
import '../../../stores/providers/store_provider.dart';
import '../../../../../core/utils/shake_utility.dart';
import '../../../stores/models/shoppable_store.dart';
import '../../../../../core/utils/snackbar.dart';
import '../../models/review_rating_options.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'review_subject_selector.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';

class ReviewCreate extends StatefulWidget {
  
  final ShoppableStore? store;
  final void Function(bool) onLoading;
  final void Function() onCreatedReview;

  const ReviewCreate({
    super.key,
    this.store,
    required this.onLoading,
    required this.onCreatedReview,
  });

  @override
  State<ReviewCreate> createState() => _ReviewCreateState();
}

class _ReviewCreateState extends State<ReviewCreate> {
  
  int? rating;
  String? comment;
  String? subject;
  Map serverErrors = {};
  ShoppableStore? store;
  bool isLoading = false;
  bool isAddingReview = false;
  ReviewRatingOptions? reviewRatingOptions;
  GlobalKey<FormState> formKey = GlobalKey();
  ShakeUtility shakeUtility = ShakeUtility();
  String get commentHint => 'Say something ${subject == null ? '' : 'about the ${subject!.toLowerCase()}' }';

  bool get hasStore => store != null;
  bool get hasSpecifiedStore => widget.store != null;
  String? get ratingError => serverErrors.containsKey('rating') ? serverErrors['rating'] : null;
  String? get subjectError => serverErrors.containsKey('subject') ? serverErrors['subject'] : null;
  String? get commentError => serverErrors.containsKey('comment') ? serverErrors['comment'] : null;

  void Function(bool) get onLoading => widget.onLoading;
  void _startLoader() => setState(() => isLoading = true);
  void _stopLoader() => setState(() => isLoading = false);
  void _startAddReviewLoader() => setState(() => isAddingReview = true);
  void _stopAddReviewLoader() => setState(() => isAddingReview = false);
  void Function() get onCreatedReview => widget.onCreatedReview;
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  
  @override
  void initState() {
    super.initState();

    if(widget.store != null) {  
      store = widget.store;
      _requestShowReviewRatingOptions();
    }
  }

  /// Request the review rating options.
  /// This provides the "rating subjects" such as "Customer Service"
  /// as well as the "rating options" e.g "1" would imply "very bad"
  /// while "5" would mean "very good"
  Future<void> _requestShowReviewRatingOptions() async {

    if(isLoading) return;
    
    _startLoader();
    
    await storeProvider.setStore(store!).storeRepository.showReviewRatingOptions()
    .then((response) async {

      if(!mounted) return;

      if( response.statusCode == 200 ) {
          
        reviewRatingOptions = ReviewRatingOptions.fromJson(response.data);

        /// Select the first subject by default
        setState(() => subject = reviewRatingOptions!.ratingSubjects.first);

      }
      
    }).catchError((error) {

      printError(info: error.toString());

      SnackbarUtility.showSuccessMessage(message: 'Can\'t show review options');

    }).whenComplete(() {

      if(!mounted) return;

      _stopLoader();

    });

  }

  _requestCreateReview() {

    if(isAddingReview) return;

    _resetServerErrors();

    if( rating == null ) {
      
      /// Start shaking the ShakeWidget widget
      shakeUtility.shake(setState: setState);

      return;

    }

    if(formKey.currentState!.validate()) {

      _startAddReviewLoader();
      
      /// Notify parent that we are loading
      onLoading(true);

      storeProvider.setStore(store!).storeRepository.createReview(
        subject: subject!,
        comment: comment,
        rating: rating!,
      ).then((response) async {

        if(response.statusCode == 201) {

          SnackbarUtility.showSuccessMessage(message: 'Thank you for your honestly');

          onCreatedReview();

        }

      }).onError((dio.DioException exception, stackTrace) {

        ErrorUtility.setServerValidationErrors(setState, serverErrors, exception);

      }).catchError((error) {

        printError(info: error.toString());

        SnackbarUtility.showErrorMessage(message: 'Can\'t create review');

      }).whenComplete(() {

        _stopAddReviewLoader();
      
        /// Notify parent that we are not loading
        onLoading(false);

      });

    }else{

      SnackbarUtility.showErrorMessage(message: 'We found some mistakes');

    }

  }

  /// Reset the server errors
  void _resetServerErrors() => setState(() => serverErrors = {});

  void onSelectedStore(ShoppableStore store) {
    setState((){
      this.store = store;
      if(reviewRatingOptions == null) {
        _requestShowReviewRatingOptions();
      }
    });
  }

  /// Set the selected subject e.g "Customer Service"
  void onSelectedSubject(String subject) => setState(() => this.subject = subject);

  /// Set the selected rating e.g "5"
  void onSelectedRating(int rating) => setState(() => this.rating = rating);

  /// Show loader widget
  Widget get loader {
    return const CustomCircularProgressIndicator(
      margin: EdgeInsets.only(top: 32, bottom: 32),
    );
  }

  Widget contentBeforeSearchBar(isLoading, totalItems) {

    if(!isLoading && totalItems == 0) {

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: const [
          
          CustomBodyText('Place your first order to review'),

        ],
      );

    }else{

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: const [
          CustomBodyText('Who are your revewing?', lightShade: true,),
        ],
      );

    }

  }

  /// Show the stores in horizontal list view
  Widget get _storesAssociatedAsCustomer {
    return Column(
      children: [
        
        /// Spacer
        const SizedBox(height: 16),

        /// Stores In Horizontal List View
        StoresInHorizontalListViewInfiniteScroll(
          listPadding: EdgeInsets.zero,
          onSelectedStore: onSelectedStore,
          userAssociation: UserAssociation.customer,
          contentBeforeSearchBar: contentBeforeSearchBar,
          headerPadding: const EdgeInsets.only(left: 8, right: 8, bottom: 16),
          storesInHorizontalListViewDesignType: StoresInHorizontalListViewDesignType.selectable,
        ),
        
        /// Spacer
        const SizedBox(height: 16),

      ],
    );
  }

  /// Show the rating and subject selector widgets
  Widget get ratingAndSubjectSelector {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// Review Star Rating
        if(reviewRatingOptions != null) ShakeWidget(
          shakeConstant: ShakeHorizontalConstant2(),
          autoPlay: shakeUtility.canShake,
          enableWebMouseHover: true,
          child: RatingSelectorUsingStars(
            rating: rating,
            onSelectedRating: onSelectedRating,
            reviewRatingOptions: reviewRatingOptions!
          ),
        ),

        /// Review Star Rating Server Error
        if(ratingError != null) CustomBodyText(ratingError, isError: true, margin: const EdgeInsets.only(top: 8),),

        /// Spacer
        const SizedBox(height: 16,),
        
        /// Instruction
        const CustomBodyText('What are you reviewing?', margin: EdgeInsets.only(left: 8),),
        
        /// Spacer
        const SizedBox(height: 8,),

        /// Subject Selector
        if(reviewRatingOptions != null) ReviewSubjectSelector(
          subject: subject,
          onSelectedSubject: onSelectedSubject,
          reviewRatingOptions: reviewRatingOptions!,
        ),

        /// Subject Selector Server Error
        if(subjectError != null) CustomBodyText(subjectError, isError: true, margin: const EdgeInsets.only(top: 8),),

      ],
    );

  }

  /// Comment text form field
  Widget get commentFiled {
    return CustomTextFormField(
      minLines: 3,
      maxLines: 4,
      maxLength: 160,
      enabled: !isLoading,
      borderRadiusAmount: 12,
      errorText: commentError,
      contentPadding: const EdgeInsets.all(16.0),
      validatorOnEmptyText: 'Say something about your experience',
      hintText: commentHint,
      onChanged: (input) {
        setState(() {
          comment = input;
        });
      },
    );
  }

  /// Leave review button
  Widget get leaveReviewButton {
    return CustomElevatedButton(
      'Leave Review',
      alignment: Alignment.center,
      onPressed: _requestCreateReview,
      disabled: isLoading || !hasStore,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.only(top: 0.0),
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              /// Selectable Stores
              if(!hasSpecifiedStore) _storesAssociatedAsCustomer,

              SizedBox(
                width: double.infinity,
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 500),
                  child: AnimatedSwitcher(
                    switchInCurve: Curves.easeIn,
                    switchOutCurve: Curves.easeOut,
                    duration: const Duration(milliseconds: 500),
                    child: Column(
                      key: ValueKey(hasStore),
                      children: hasStore ? [
              
                        /// Rating & Subject Selector
                        SizedBox(
                          width: double.infinity,
                          child: AnimatedSize(
                            duration: const Duration(milliseconds: 500),
                            child: AnimatedSwitcher(
                              switchInCurve: Curves.easeIn,
                              switchOutCurve: Curves.easeOut,
                              duration: const Duration(milliseconds: 500),
                              child: isLoading 
                                /// Loader
                                ? loader
                                /// Rating & Subject Selector
                                : ratingAndSubjectSelector
                            )
                          ),
                        ),
              
                        /// Spacer
                        const SizedBox(height: 8,),
              
                        /// Comment
                        commentFiled,
              
                        /// Spacer
                        const SizedBox(height: 16,),
              
                        /// Leave Review Button
                        leaveReviewButton,
              
                        /// Spacer
                        const SizedBox(height: 60,),
                        
                      ] : [],
                    )
                  )
                ),
              ),

            ],
          )
        ),
      ),
    );
  }
}