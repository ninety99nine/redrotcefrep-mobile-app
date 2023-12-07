import '../../../../../../core/shared_widgets/bottom_modal_sheet/custom_bottom_modal_sheet.dart';
import 'package:bonako_demo/core/shared_widgets/button/custom_elevated_button.dart';
import '../../../enums/sms_alert_enums.dart';
import 'package:flutter/material.dart';
import '../sms_alert_content.dart';

class SmsAlertModalBottomSheet extends StatefulWidget {
  
  final Widget Function(Function())? trigger;
  final SmsAlertContentView? smsAlertContentView;

  const SmsAlertModalBottomSheet({
    super.key,
    this.trigger,
    this.smsAlertContentView,
  });

  @override
  State<SmsAlertModalBottomSheet> createState() => SmsAlertModalBottomSheetState();
}

class SmsAlertModalBottomSheetState extends State<SmsAlertModalBottomSheet> {

  Widget Function(Function())? get trigger => widget.trigger;
  SmsAlertContentView? get smsAlertContentView => widget.smsAlertContentView;

  /// This allows us to access the state of CustomBottomModalSheet widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomBottomModalSheetState> _customBottomModalSheetState = GlobalKey<CustomBottomModalSheetState>();

  Widget get _trigger {

    final Widget defaultTrigger = CustomElevatedButton(
      'Sms Alert', 
      onPressed: openBottomModalSheet,
    );

    return trigger == null ? defaultTrigger : trigger!(openBottomModalSheet);
  }

  /// Open the bottom modal sheet
  void openBottomModalSheet() {
    if(_customBottomModalSheetState.currentState != null) {
      _customBottomModalSheetState.currentState!.showBottomSheet(context);
    } 
  }
  
  @override
  Widget build(BuildContext context) {
    return CustomBottomModalSheet(
      key: _customBottomModalSheetState,
      /// Trigger to open the bottom modal sheet
      trigger: _trigger,
      /// Content of the bottom modal sheet
      content: SmsAlertContent(
        smsAlertContentView: smsAlertContentView,
      ),
    );
  }
}