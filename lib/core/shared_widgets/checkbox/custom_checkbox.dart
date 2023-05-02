import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class CustomCheckbox extends StatelessWidget {

  final bool value;
  final String link;
  final dynamic text;
  final bool disabled;
  final String linkText;
  final void Function(bool?) onChanged;
  final EdgeInsetsGeometry checkBoxMargin;
  final MainAxisAlignment mainAxisAlignment;

  const CustomCheckbox({
    super.key, 
    this.text = '',
    this.link = '',
    this.linkText = '',
    required this.value,
    this.disabled = false,
    required this.onChanged,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.checkBoxMargin = const EdgeInsets.only(right: 8),
  });

  Widget get linkContent {

    Widget linkWidget = Text(linkText, style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline));

    if(text is Widget || (text is String && text.isEmpty == false) && linkText.isNotEmpty) {
      
      /// Add Spacer and Link
      linkWidget = Row(
        children: [

          /// Spacer
          if(text is Widget || (text is String && text.isEmpty == false)) const SizedBox(width: 5,),
          
          /// Link
          linkWidget
        
        ]
      );
    }

    return InkWell(
      child: linkWidget,
      onTap: () => link.isEmpty ? null : launchUrl(Uri.parse(link))
    );

  }

  @override
  Widget build(BuildContext context) {

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        
        Container(
          width: 20.0,
          height: 20.0,
          margin: checkBoxMargin,
          child: Checkbox(
            value: value,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4)
            ),
            onChanged: disabled ? null : onChanged,
            side: BorderSide(
              color: disabled ? Colors.grey : Theme.of(context).primaryColor,
              width: 1
            ),
          ),
        ),
        
        Flexible(
          child: GestureDetector(
            onTap: () => disabled ? null : onChanged(!value),
            child: (text is Widget) ? text : CustomBodyText(text),
          ),
        ),

        if(link.isNotEmpty) linkContent,
      ],
    );

  }

}