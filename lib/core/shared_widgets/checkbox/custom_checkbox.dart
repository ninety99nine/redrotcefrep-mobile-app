import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class CustomCheckbox extends StatefulWidget {

  final bool value;
  final String link;
  final dynamic text;
  final bool disabled;
  final String linkText;
  final void Function(bool?) onChanged;
  final EdgeInsetsGeometry checkBoxMargin;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const CustomCheckbox({
    super.key, 
    this.text = '',
    this.link = '',
    this.linkText = '',
    required this.value,
    this.disabled = false,
    required this.onChanged,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.checkBoxMargin = const EdgeInsets.only(right: 8),
  });

  @override
  State<CustomCheckbox> createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {

  Widget get linkContent {

    final primaryColor = Theme.of(context).primaryColor;

    Widget linkWidget = Text(widget.linkText, style: TextStyle(color: primaryColor, decoration: TextDecoration.underline));

    if(widget.text is Widget || (widget.text is String && widget.text.isEmpty == false) && widget.linkText.isNotEmpty) {
      
      /// Add Spacer and Link
      linkWidget = Row(
        children: [

          /// Spacer
          if(widget.text is Widget || (widget.text is String && widget.text.isEmpty == false)) const SizedBox(width: 5,),
          
          /// Link
          linkWidget
        
        ]
      );
    }

    return InkWell(
      child: linkWidget,
      onTap: () => widget.link.isEmpty ? null : launchUrl(Uri.parse(widget.link))
    );

  }

  @override
  Widget build(BuildContext context) {

    return Row(
      mainAxisAlignment: widget.mainAxisAlignment,
      crossAxisAlignment: widget.crossAxisAlignment,
      children: [
        
        Container(
          width: 20.0,
          height: 20.0,
          margin: widget.checkBoxMargin,
          child: Checkbox(
            value: widget.value,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4)
            ),
            onChanged: widget.disabled ? null : widget.onChanged,
            side: BorderSide(
              color: widget.disabled ? Colors.grey : Theme.of(context).primaryColor,
              width: 1
            ),
          ),
        ),
        
        Flexible(
          child: GestureDetector(
            onTap: () => widget.disabled ? null : widget.onChanged(!widget.value),
            child: (widget.text is Widget) ? widget.text : CustomBodyText(widget.text),
          ),
        ),

        if(widget.link.isNotEmpty) linkContent,
      ],
    );

  }
}