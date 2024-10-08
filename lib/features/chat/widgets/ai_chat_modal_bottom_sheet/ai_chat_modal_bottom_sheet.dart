import '../../../../../../core/shared_widgets/bottom_modal_sheet/custom_bottom_modal_sheet.dart';
import 'package:perfect_order/core/shared_widgets/button/custom_elevated_button.dart';
import 'package:perfect_order/features/chat/widgets/ai_chat_content.dart';
import 'package:flutter/material.dart';

class AiChatModalBottomSheet extends StatefulWidget {
  
  final Widget Function(Function())? trigger;

  const AiChatModalBottomSheet({
    super.key,
    this.trigger,
  });

  @override
  State<AiChatModalBottomSheet> createState() => _AiChatModalBottomSheetState();
}

class _AiChatModalBottomSheetState extends State<AiChatModalBottomSheet> {

  Widget Function(Function())? get trigger => widget.trigger;

  /// This allows us to access the state of CustomBottomModalSheet widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomBottomModalSheetState> _customBottomModalSheetState = GlobalKey<CustomBottomModalSheetState>();

  Widget get _trigger {
    return trigger == null ? CustomElevatedButton('Need Advice?', width: 140, prefixIcon: Icons.bubble_chart_outlined, alignment: Alignment.center, onPressed: openBottomModalSheet) : trigger!(openBottomModalSheet);
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
      content: const AiChatContent(
        showingFullPage: false
      ),
    );
  }
}