import 'package:get/get.dart';

import '../../../../core/shared_widgets/button/custom_text_button.dart';
import '../../../../../core/utils/dialog.dart';
import 'package:flutter/material.dart';
import '../qr_code_scanner.dart';

class QRCodeScannerDialog extends StatefulWidget {

  final Function(String) onScanned;

  const QRCodeScannerDialog({
    super.key,
    required this.onScanned
  });

  @override
  State<QRCodeScannerDialog> createState() => _QRCodeScannerDialogState();
}

class _QRCodeScannerDialogState extends State<QRCodeScannerDialog> {

  Function(String) get onScanned => widget.onScanned;

  @override
  Widget build(BuildContext context) {
    return CustomTextButton(
      'scan',
      prefixIcon: Icons.qr_code_scanner,
      onPressed: () {
        DialogUtility.showContentDialog(
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8, 
            height: 300, 
            child: QRCodeScanner(
              onScanned: onScanned,
            )
          ), 
          context: context
        );
      },
    );
  }
}