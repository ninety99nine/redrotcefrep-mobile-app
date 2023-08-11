import '../text/custom_body_text.dart';
import 'package:flutter/material.dart';

enum AlertMessageType {
  info,
  success,
  warning,
  error
}

class CustomMessageAlert extends StatelessWidget {
  
  final String text;
  final double? size;
  final bool showIcon;
  final Color? bgColor;
  final IconData? icon;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final TextAlign? textAlign;
  final AlertMessageType type;

  const CustomMessageAlert(
    this.text, 
    {
      super.key,  
      this.icon,
      this.size,
      this.bgColor,
      this.textAlign,
      this.showIcon = true,
      this.type = AlertMessageType.info,
      this.margin = const EdgeInsets.all(0),
      this.padding = const EdgeInsets.all(8.0),
    }
  );

  @override
  Widget build(BuildContext context) {

    Color color;
    Color backgroundColor = bgColor ?? Colors.grey.shade200;

    if(type == AlertMessageType.error) {
      color = Colors.red.shade700;
    }else if(type == AlertMessageType.warning) {
      color = Colors.amber.shade700;
    }else if(type == AlertMessageType.success) {
      color = Colors.green.shade700;
    }else{
      color = Colors.blue.shade700;
    }

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.0)
      ),
      child: Row(
        children: [

          if(showIcon) ...[
            
            /// Icon
            Icon(icon ?? Icons.info, color: color, size: size),

            /// Spacer
            const SizedBox(width: 8,),

          ],
    
          /// Text
          Expanded(child: CustomBodyText(text, textAlign: textAlign),)
    
        ],
      ),
    );
  }
}