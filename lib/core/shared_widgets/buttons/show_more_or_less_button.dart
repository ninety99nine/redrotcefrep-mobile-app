import 'package:flutter/material.dart';
import 'custom_text_button.dart';

class ShowMoreOrLessButton extends StatefulWidget {
  
  final bool showAll;
  final Function()? toggleShowAll;

  const ShowMoreOrLessButton({
    super.key,
    required this.showAll,
    required this.toggleShowAll
  });

  @override
  State<ShowMoreOrLessButton> createState() => _ShowMoreOrLessButtonState();
}

class _ShowMoreOrLessButtonState extends State<ShowMoreOrLessButton> {
  @override
  Widget build(BuildContext context) {
    return CustomTextButton(
      widget.showAll ? 'show less' : 'show more', 
      alignment: Alignment.center,
      onPressed: widget.toggleShowAll,
    );
  }
}