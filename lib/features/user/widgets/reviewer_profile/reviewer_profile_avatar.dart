import '../../../../core/shared_widgets/text/custom_title_medium_text.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../../core/shared_models/user.dart';
import '../../../reviews/models/review.dart';
import 'package:flutter/material.dart';

class ReviewerProfileAvatar extends StatefulWidget {

  final Review review;

  const  ReviewerProfileAvatar({
    super.key,
    required this.review,
  });

  @override
  State<ReviewerProfileAvatar> createState() => _ReviewerAvatarProfileState();
}

class _ReviewerAvatarProfileState extends State<ReviewerProfileAvatar> {

  Review get review => widget.review;
  String get name => user.attributes.name;
  User get user => review.relationships.user!;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
    
            /// Avatar
            const CircleAvatar(backgroundColor: Colors.black, foregroundColor: Colors.white,child: Icon(Icons.person),),
    
            /// Spacer
            const SizedBox(width: 16),

            /// Name
            CustomTitleMediumText(name),
    
          ],
        ),
      ],
    );
  }
}