import 'package:flutter/material.dart';

class CustomBodyText extends StatefulWidget {
  
  final bool isLink;
  final dynamic text;
  final bool isError;
  final Color? color;
  final int? maxLines;
  final bool isWarning;
  final double? height;
  final bool lightShade;
  final double? fontSize;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final FontStyle? fontStyle;
  final TextAlign? textAlign;
  final FontWeight fontWeight;
  final TextOverflow? overflow;

  const CustomBodyText(
    this.text, 
    {
      super.key,
      this.color,
      this.height,
      this.margin,
      this.padding,
      this.maxLines,
      this.overflow,
      this.fontSize,
      this.textAlign,
      this.fontStyle,
      this.isLink = false,
      this.isError = false,
      this.isWarning = false,
      this.lightShade = false,
      this.fontWeight = FontWeight.normal
    }
  );

  @override
  State<CustomBodyText> createState() => _CustomBodyTextState();
}

class _CustomBodyTextState extends State<CustomBodyText> {

  double? get fontSize => widget.fontSize;
  FontStyle? get fontStyle => widget.fontStyle;
  FontWeight? get fontWeight => widget.fontWeight;

  Color? getColor(BuildContext context) {
    if(widget.isLink) {
      return Theme.of(context).primaryColor;
    }else if(widget.isError) {
      return Colors.red;
    }else if(widget.isWarning) {
      return Colors.orange.shade700;
    }else if(widget.lightShade) {
      return Colors.grey;
    }else {
      return widget.color;
    }
  }

  Widget get finalText {

    /// If the text is a list of two texts
    if((widget.text.runtimeType == List<String>) && (widget.text as List).length == 2) {

      /// Return the first text in Bold weight 
      /// and the second text in Normal weight
      return getMultiTextWidget(
        (widget.text as List)[0],
        (widget.text as List)[1],
      );


    /// If the text is a single String text
    }else{
      
      return getSingleTextWidget((widget.text as String));

    }
  }

  Widget getSingleTextWidget(text) {
    return Text(
      text,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
      textAlign: widget.textAlign,
      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
        fontSize: fontSize,
        fontStyle: fontStyle,
        height: widget.height,
        color: getColor(context),
        fontWeight: widget.isLink ? FontWeight.bold : fontWeight,
      )
    );
  }

  Widget getMultiTextWidget(text, text2) {
    return RichText(
      /// First text must have a bold weight
      text: TextSpan(
        text: text,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.bold
        ),
        children: [
          /// Second text must have a normal weight
          TextSpan(
            text: ' $text2',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontSize: fontSize,
              fontWeight: FontWeight.normal,
            )
          )
        ]
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      padding: widget.padding,
      child: finalText
    );
  }
}