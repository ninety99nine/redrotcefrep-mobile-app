import '../../../core/shared_widgets/text/custom_body_text.dart';
import '../../reviews/models/review_rating_options.dart';
import 'package:flutter/material.dart';

class RatingSelectorUsingStars extends StatefulWidget {

  //  You can pass a default rating
  final int? rating;
  final double size;
  final Function(int)? onSelectedRating;
  final ReviewRatingOptions reviewRatingOptions;

  const RatingSelectorUsingStars({ 
    super.key, 
    this.rating,
    this.size = 30,
    this.onSelectedRating,
    required this.reviewRatingOptions,
  });

  @override
  State<RatingSelectorUsingStars> createState() => _SelectRatingState();
}

class _SelectRatingState extends State<RatingSelectorUsingStars> {

  int? rating;
  double get size => widget.size;
  Function(int)? get onSelectedRating => widget.onSelectedRating;
  List<RatingOption> get ratingOptions => reviewRatingOptions.ratingOptions;
  ReviewRatingOptions get reviewRatingOptions => widget.reviewRatingOptions;

  @override
  void initState() {
    super.initState();

    /// Update the state rating using the intial widget rating
    if(widget.rating != null && rating == null) {
      setState(() => rating = widget.rating);
    }
  }

  Widget multipleStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [

        /// Star Icons
        Row(
          children: List.generate(5, (index) {

            final number = index + 1;
            final hightlight = rating == null ? false : number <= rating!;

            return IconButton(
              icon: Icon(Icons.star, size: size, color: hightlight ? Colors.orange : Colors.grey,),
              onPressed: () {
                setState(() {

                  /// Change the rating number
                  rating = number;

                  if( onSelectedRating != null) {

                    /// Nofify parent
                    onSelectedRating!(rating!);

                  }
                });
              }
            );
          
          }).toList(),
        ),

        /// Spacer
        const SizedBox(width: 8,),

        /// Rating Name e.g Very Bad or Very Good
        if(rating != null && ratingOptions.isNotEmpty) CustomBodyText(ratingOptions[rating! - 1].name),
        
        /// Spacer
        const SizedBox(width: 8,),

      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return multipleStars();
  }
}