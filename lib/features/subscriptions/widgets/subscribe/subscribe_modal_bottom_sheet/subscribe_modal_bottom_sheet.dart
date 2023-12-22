import '../../../../../../core/shared_widgets/bottom_modal_sheet/custom_bottom_modal_sheet.dart';
import '../../../../../../core/shared_widgets/button/custom_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import '../subscribe_content.dart';

class SubscribeModalBottomSheet extends StatefulWidget {

  final Widget header;
  final Widget? trigger;
  final Function()? onDial;
  final String? triggerText;
  final Function()? onResumed;
  final Alignment subscribeButtonAlignment;
  final Future<dio.Response> generatePaymentShortcode;

  const SubscribeModalBottomSheet({
    super.key,
    this.onDial,
    this.trigger,
    this.onResumed,
    this.triggerText,
    required this.header,
    required this.generatePaymentShortcode,
    this.subscribeButtonAlignment = Alignment.centerRight
  });

  @override
  State<SubscribeModalBottomSheet> createState() => _SubscribeModalBottomSheetState();
}

class _SubscribeModalBottomSheetState extends State<SubscribeModalBottomSheet> {

  /// This allows us to access the state of CustomVerticalListViewInfiniteScroll widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomBottomModalSheetState> _customBottomModalSheetState = GlobalKey<CustomBottomModalSheetState>();

  Widget get header => widget.header;
  Widget? get _trigger => widget.trigger;
  Function()? get onDial => widget.onDial;
  Function()? get onResumed => widget.onResumed;
  String? get triggerText => widget.triggerText;
  Alignment get subscribeButtonAlignment => widget.subscribeButtonAlignment;
  Future<dio.Response> get generatePaymentShortcode => widget.generatePaymentShortcode;

  Widget get trigger {

    /// Subscribe Button
    return _trigger == null ? CustomElevatedButton(
      padding: EdgeInsets.zero,
      triggerText ?? 'Subscribe',
      onPressed: openBottomModalSheet,
      alignment: subscribeButtonAlignment,
    ) : _trigger!;

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
      /// Bottom modal sheet height ratio in comparison to screen height
      heightFactor: 0.4,
      /// Trigger to open the bottom modal sheet
      trigger: trigger,
      /// Content of the bottom modal sheet
      content: SubscribeContent(
        onDial: onDial,
        header: header,
        onResumed: onResumed,
        generatePaymentShortcode: generatePaymentShortcode,
      ),
    );
  }
}