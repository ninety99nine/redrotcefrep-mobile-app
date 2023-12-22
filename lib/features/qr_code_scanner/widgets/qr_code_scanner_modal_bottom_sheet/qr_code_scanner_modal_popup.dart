import '../../../../../../core/shared_widgets/bottom_modal_sheet/custom_bottom_modal_sheet.dart';
import '../qr_code_scanner_content.dart';
import 'package:flutter/material.dart';

class QRCodeScannerModalBottomSheet extends StatefulWidget {

  final Function(String?)? onScanned;

  const QRCodeScannerModalBottomSheet({
    super.key,
    this.onScanned,
  });

  @override
  State<QRCodeScannerModalBottomSheet> createState() => _QRCodeScannerModalBottomSheetState();
}

class _QRCodeScannerModalBottomSheetState extends State<QRCodeScannerModalBottomSheet> {

  Function(String?)? get onScanned => widget.onScanned;

  /// This allows us to access the state of CustomBottomModalSheet widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomBottomModalSheetState> _customBottomModalSheetState = GlobalKey<CustomBottomModalSheetState>();

  Widget get trigger {
    return FloatingActionButton(
      mini: true,
      heroTag: 'qr-code-button',
      onPressed: openBottomModalSheet,
      child: const Icon(Icons.qr_code_scanner)
    );
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
      heightFactor: 1,
      borderRadius: BorderRadius.zero,
      /// Trigger to open the bottom modal sheet
      trigger: trigger,
      /// Content of the bottom modal sheet
      content: QRCodeScannerContent(
        onScanned: onScanned
      ),
    );
  }
}