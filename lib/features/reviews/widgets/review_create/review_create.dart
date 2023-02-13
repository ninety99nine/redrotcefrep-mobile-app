import '../../../../../core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import '../../../../../core/shared_widgets/text_form_fields/custom_text_form_field.dart';
import '../../../../../core/shared_widgets/buttons/custom_elevated_button.dart';
import '../../../../../core/shared_widgets/text/custom_body_text.dart';
import 'package:flutter_shake_animated/flutter_shake_animated.dart';
import '../../../rating/widgets/rating_selector_using_stars.dart';
import '../../../stores/providers/store_provider.dart';
import '../../../../../core/utils/shake_utility.dart';
import '../../../stores/models/shoppable_store.dart';
import '../../../../../core/utils/snackbar.dart';
import '../../models/review_rating_options.dart';
import 'review_subject_selector.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class ReviewCreate extends StatefulWidget {
  
  final ShoppableStore store;
  final void Function(bool) onLoading;
  final void Function() onCreatedReview;

  const ReviewCreate({
    super.key,
    required this.store,
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
  bool isLoading = false;
  ReviewRatingOptions? reviewRatingOptions;
  ShoppableStore get store => widget.store;
  GlobalKey<FormState> formKey = GlobalKey();
  ShakeUtility shakeUtility = ShakeUtility();
  String get commentHint => 'Say something ${subject == null ? '' : 'about the ${subject!.toLowerCase()}' }';

  String? get ratingError => serverErrors.containsKey('rating') ? serverErrors['rating'] : null;
  String? get subjectError => serverErrors.containsKey('subject') ? serverErrors['subject'] : null;
  String? get commentError => serverErrors.containsKey('comment') ? serverErrors['comment'] : null;

  void Function(bool) get onLoading => widget.onLoading;
  void _startLoader() => setState(() => isLoading = true);
  void _stopLoader() => setState(() => isLoading = false);
  void Function() get onCreatedReview => widget.onCreatedReview;
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  
  @override
  void initState() {
    super.initState();
    _requestShowReviewRatingOptions();
  }

  /// Request the review rating options.
  /// This provides the "rating subjects" such as "Customer Service"
  /// as well as the "rating options" e.g "1" would imply "very bad"
  /// while "5" would mean "very good"
  Future<void> _requestShowReviewRatingOptions() async {
    
    _startLoader();
    
    await storeProvider.setStore(store).storeRepository.showReviewRatingOptions(
      context: context,
    ).then((response) async {

      if(!mounted) return;

      if( response.statusCode == 200 ) {

        final responseBody = jsonDecode(response.body);
          
        reviewRatingOptions = ReviewRatingOptions.fromJson(responseBody);

        /// Select the first subject by default
        setState(() => subject = reviewRatingOptions!.ratingSubjects.first);

      }else{

        SnackbarUtility.showSuccessMessage(message: 'Can\'t get review options', context: context);
      
      }

    }).catchError((error) {

      if(!mounted) return;

      SnackbarUtility.showSuccessMessage(message: 'Can\'t show review options', context: context);
    
    }).whenComplete(() {

      if(!mounted) return;

      _stopLoader();

    });

  }

  _requestCreateReview() {

    _resetServerErrors();

    if( rating == null ) {
      
      /// Start shaking the ShakeWidget widget
      shakeUtility.shake(setState: setState);

      return;

    }

    if(formKey.currentState!.validate()) {

      _startLoader();
      
      /// Notify parent that we are loading
      onLoading(true);

      storeProvider.setStore(store).storeRepository.createReview(
        context: context,
        subject: subject!,
        comment: comment,
        rating: rating!,
      ).then((response) async {

        final responseBody = jsonDecode(response.body);

        if(response.statusCode == 201) {

          SnackbarUtility.showSuccessMessage(message: 'Thank you for your honestly', context: context);

          onCreatedReview();

        }else if(response.statusCode == 422) {

          handleServerValidation(responseBody['errors']);
          
        }

      }).catchError((error) {

        SnackbarUtility.showErrorMessage(message: 'Can\'t create review', context: context);

      }).whenComplete((){

        _stopLoader();
      
        /// Notify parent that we are not loading
        onLoading(false);

      });

    }else{

      SnackbarUtility.showErrorMessage(context: context, message: 'We found some mistakes');

    }

  }

  /// Set the validation errors as serverErrors
  void handleServerValidation(Map errors) {

    /**
     *  errors = {
     *    comment: [The comment must be more than 10 characters]
     * }
     */
    setState(() {
      errors.forEach((key, value) {
        serverErrors[key] = value[0];
      });
    });

  }

  /// Reset the server errors
  void _resetServerErrors() => setState(() => serverErrors = {});

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

  /// Show the rating and subject selector widgets
  Widget get ratingAndSubjectSelector {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [ 

        /// Review Star Rating
        ShakeWidget(
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
        ReviewSubjectSelector(
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
      disabled: isLoading,
      alignment: Alignment.center,
      onPressed: _requestCreateReview,
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

              AnimatedSize(
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

            ],
          )
        ),
      ),
    );
  }
}