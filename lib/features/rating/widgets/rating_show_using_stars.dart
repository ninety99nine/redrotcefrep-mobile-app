import '../../../../core/shared_widgets/text/custom_body_text.dart';
import 'package:flutter/material.dart';

class RatingShowUsingStars extends StatelessWidget {

  final String rating;
  final bool showMultipleStars;

  const RatingShowUsingStars({ 
    super.key, 
    required this.rating,
    this.showMultipleStars = false,
  });

  Widget multipleStars() {
    return Row(
      children: List.generate(5, (index) {

        final number = index + 1;
        final hightlight = number <= int.parse(rating);
        return Icon(Icons.star, size: 16, color: hightlight ? Colors.orange : Colors.grey,);
      
      }).toList()
    );
  }

  Widget singleStar() {
    return Row(
      children: [
        const Icon(Icons.star_border_outlined, size: 16, color: Colors.orange,),
        const SizedBox(width: 4.0,),
        CustomBodyText(rating)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return showMultipleStars ? multipleStars() : singleStar();
  }

}