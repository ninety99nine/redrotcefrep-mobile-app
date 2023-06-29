import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';

class CustomDatetimePicker extends StatefulWidget {
  
  final bool enabled;
  final String? dateMask;
  final String? errorText;
  final DateTime? lastDate;
  final DateTime? firstDate;
  final String? initialValue;
  final String? dateLabelText;
  final String? timeLabelText;
  final DateTimePickerType type;
  final double borderRadiusAmount;
  final EdgeInsets contentPadding;
  final TextInputType? keyboardType;
  final String validatorOnEmptyText;
  final void Function(String?)? onSaved;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;

  const CustomDatetimePicker( 
    {
      super.key,
      this.onSaved,
      this.dateMask,
      this.lastDate,
      this.firstDate,
      this.errorText,
      this.validator,
      this.onChanged,
      this.initialValue,
      this.dateLabelText,
      this.timeLabelText,
      this.enabled = true,
      this.onFieldSubmitted,
      this.borderRadiusAmount = 50.0,
      this.keyboardType = TextInputType.text,
      this.type = DateTimePickerType.dateTimeSeparate,
      this.validatorOnEmptyText = 'This field is required',
      this.contentPadding = const EdgeInsets.symmetric(vertical: 8, horizontal: 20)
    }
  );

  @override
  State<CustomDatetimePicker> createState() => CustomDatetimePickerState();
}

class CustomDatetimePickerState extends State<CustomDatetimePicker> {
  
  @override
  Widget build(BuildContext context) {

    final primaryColor = Theme.of(context).primaryColor;
    final bodyLarge = Theme.of(context).textTheme.bodyLarge!;

    return DateTimePicker(
      type: widget.type,
      onSaved: widget.onSaved,
      dateMask: widget.dateMask,
      lastDate: widget.lastDate,
      firstDate: widget.firstDate,
      onChanged: widget.onChanged,
      initialValue: widget.initialValue,
      dateLabelText: widget.dateLabelText,
      timeLabelText: widget.timeLabelText,
      onFieldSubmitted: widget.onFieldSubmitted,
      validator: widget.validator ?? (value) {
        if(value == null || value.isEmpty) {
          return 'Please enter a date';
        }
        return null;
      },
      style: bodyLarge.copyWith(
        color: widget.enabled ? Colors.black : Colors.grey.shade400,
        fontWeight: FontWeight.normal,
      ),
      decoration: InputDecoration(
        filled: true,
        errorMaxLines: 2,
        errorText: widget.errorText,
        labelStyle: TextStyle(
          color: bodyLarge.color,
          fontWeight: FontWeight.normal
        ),
        hintStyle: bodyLarge.copyWith(
          color: Colors.grey.shade400,
          fontWeight: FontWeight.normal
        ),
        contentPadding: widget.contentPadding,
        fillColor: primaryColor.withOpacity(0.05),
        
        //  Border disabled (i.e enabled = false)
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadiusAmount),
          borderSide: BorderSide(
            color: primaryColor.withOpacity(0.1),
            width: 1.0,
          ),
        ),

        //  Border enabled (i.e enabled = true)
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadiusAmount),
          borderSide: BorderSide(
            color: primaryColor.withOpacity(0.5),
            width: 1.0,
          ),
        ),

        //  Border focused (i.e while typing - onFocus)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadiusAmount),
          borderSide: BorderSide(
            color: primaryColor.withOpacity(1),
            width: 1.0,
          ),
        ),

        //  Border error onfocused (i.e validation error showing while not typing - onblur)
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadiusAmount),
          borderSide: BorderSide(
            color: Colors.red.withOpacity(0.5),
            width: 1.0,
          ),
        ),

        //  Border error focused (i.e validation error showing while typing - onFocus)
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadiusAmount),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.0,
          ),
        ),
      ),
    );
    
  }
}