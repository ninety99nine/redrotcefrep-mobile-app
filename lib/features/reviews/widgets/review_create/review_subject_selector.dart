import '../../../../../core/shared_widgets/chips/custom_choice_chip.dart';
import '../../models/review_rating_options.dart';
import 'package:flutter/material.dart';

class ReviewSubjectSelector extends StatefulWidget {

  final String? subject;
  final Function(String) onSelectedSubject;
  final ReviewRatingOptions reviewRatingOptions;

  const ReviewSubjectSelector({ 
    super.key, 
    required this.subject,
    required this.onSelectedSubject,
    required this.reviewRatingOptions,
  });

  @override
  State<ReviewSubjectSelector> createState() => _ReviewSubjectSelectorState();
}

class _ReviewSubjectSelectorState extends State<ReviewSubjectSelector> {

  String? subject;
  Function(String) get onSelectedSubject => widget.onSelectedSubject;
  List<String> get ratingSubjects => reviewRatingOptions.ratingSubjects;
  ReviewRatingOptions get reviewRatingOptions => widget.reviewRatingOptions;

  @override
  void initState() {
    super.initState();

    /// Update the local state subject using the intial widget subject
    if(widget.subject != null && subject == null) {
      setState(() => subject = widget.subject);
    }
  }

  /// Set the selected subject
  void selectSubject(String subject) {
    setState(() {
      
      this.subject = subject;

      /// Notify parent widget on selected subject
      onSelectedSubject(subject);

    });
  }

  Widget get content {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.start,
        alignment: WrapAlignment.start,
        spacing: 4,
        children: [

          /// List each subject as a selectable choice chip
          ...ratingSubjects.map((ratingSubject) {
            return CustomChoiceChip(
              label: ratingSubject,
              selected: ratingSubject == subject,
              onSelected: (_) => selectSubject(ratingSubject),
            );
          }).toList()

        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 500),
        child: AnimatedSwitcher(
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          duration: const Duration(milliseconds: 500),
          child: content
        ),
      ),
    );
  }
}