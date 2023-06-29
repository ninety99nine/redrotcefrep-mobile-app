import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:flutter/material.dart';

class CustomMultiSelectFormField extends StatelessWidget {
  
  final bool enabled;
  final String title;
  final String hintText;
  final String errorText;
  final String textField;
  final String valueField;
  final String okButtonLabel;
  final dynamic initialValue;
  final String cancelButtonLabel;
  final List<dynamic>? dataSource;
  final AutovalidateMode autovalidate;
  final void Function(dynamic)? onSaved;

  const CustomMultiSelectFormField( 
    {
      super.key,
      this.onSaved,
      this.initialValue,
      required this.title,
      this.enabled = true,
      required this.hintText,
      required this.dataSource,
      this.valueField = 'value',
      this.textField = 'display',
      this.okButtonLabel = 'OK',
      this.cancelButtonLabel = 'CANCEL',
      this.autovalidate = AutovalidateMode.disabled,
      this.errorText = 'Please select one or more options',
    }
  );

  @override
  Widget build(BuildContext context) {

    final primaryColor = Theme.of(context).primaryColor;

    return MultiSelectFormField(
      enabled: enabled,
      errorText: errorText,
      autovalidate: autovalidate,
      chipBackGroundColor: primaryColor,
      checkBoxActiveColor: primaryColor,
      checkBoxCheckColor: Colors.white,
      dialogShapeBorder: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0))
      ),
      dialogTextStyle: const TextStyle(fontWeight: FontWeight.normal),
      chipLabelStyle: const TextStyle(color: Colors.white, fontSize: 14),
      title: CustomBodyText(title),
      /**
       *  When:
       * 
       *  textField: 'display',
       *  valueField: 'value',
       * 
       *  then:
       * 
       *  dataSource: [
       *    {
       *      "display": "Australia",
       *      "value": 1,
       *    },
       *    {
       *      "display": "Canada",
       *      "value": 2,
       *    },
       *  ]
       *
       */
      onSaved: onSaved,
      textField: textField,
      dataSource: dataSource,
      valueField: valueField,
      initialValue: initialValue,
      okButtonLabel: okButtonLabel,
      cancelButtonLabel: cancelButtonLabel,
      hintWidget: CustomBodyText(hintText),
    );

  }
}