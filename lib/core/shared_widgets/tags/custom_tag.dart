import 'package:flutter/material.dart';

enum CustomTagType {
  fill,
  outline
}

class CustomTag extends StatelessWidget {
  
  final String text;
  final Color? color;
  final int? textMaxLength;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final bool showCancelIcon;
  final void Function()? onTap;
  final void Function()? onCancel;
  final CustomTagType customTagType;

  const CustomTag(this.text, {
    super.key,
    this.onTap,
    this.color,
    this.onCancel,
    this.textMaxLength,
    this.showCancelIcon = true,
    this.customTagType = CustomTagType.fill,
    this.margin = const EdgeInsets.only(right: 4.0),
    this.padding = const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
  });

  String get finalText {

    if(textMaxLength != null) {

      return text.length > textMaxLength! ? text.substring(0, textMaxLength) + '...' : text;

    }else{

      return text;

    }

  }

  @override
  Widget build(BuildContext context) {

    Color color = this.color ?? Theme.of(context).primaryColor;
    bool selectedFill = customTagType == CustomTagType.fill;

    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(20.0)),
        border: selectedFill ? null : Border.all(
          width: 1.0,
          color: color,
        ),
        color: selectedFill ? color : color.withOpacity(0.1),
      ),
      margin: margin,
      padding: padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          /// Tag
          InkWell(
            onTap: onTap,
            child: Text(
              finalText, 
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: selectedFill ? Colors.white : color
              )
            ),
          ),
          
          if(showCancelIcon) ...[

            /// Spacer
            const SizedBox(width: 4.0),

            /// Cancel Icon
            InkWell(
              onTap: onCancel,
              child: Icon(
                size: 14.0,
                Icons.cancel,
                color: selectedFill ? const Color.fromARGB(255, 233, 233, 233) : color,
              ),
            )

          ]

        ],
      ),
    );
  }
}