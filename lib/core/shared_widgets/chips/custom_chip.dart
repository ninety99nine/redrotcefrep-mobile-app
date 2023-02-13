import 'package:flutter/material.dart';

enum CustomChipType {
  success,
  primary,
  error
}

class CustomChip extends StatelessWidget {
  
  final String label;
  final Widget? labelWidget;
  final CustomChipType? type;

  const CustomChip(
    {
      this.labelWidget,
      this.label = '',
      super.key,
      this.type
    }
  );

  Color getBorderColor(BuildContext context) {
    if( type == CustomChipType.success ) {
      return Colors.green;
    }else if( type == CustomChipType.primary ) {
      return Theme.of(context).primaryColor;
    }else{
      return Colors.grey;
    }
  }

  Color getTextColor(BuildContext context) {
    if( type == CustomChipType.success ) {
      return Colors.green;
    }else if( type == CustomChipType.primary ) {
      return Theme.of(context).primaryColor;
    }else{
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        side: BorderSide(
          color: getBorderColor(context)
        ),
      ),
      label: labelWidget ?? Text(label, style: Theme.of(context).chipTheme.copyWith(
        labelStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
          color: getTextColor(context),
          fontWeight: FontWeight.bold
        ),
      ).labelStyle), 
      backgroundColor:getBorderColor(context).withOpacity(0.05),
    );
  }
}