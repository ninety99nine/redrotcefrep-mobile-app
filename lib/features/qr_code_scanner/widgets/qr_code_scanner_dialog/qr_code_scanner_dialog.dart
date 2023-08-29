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
  State<QRCodeScannerDialog> createState() => QRCodeScannerDialogState();
}

class QRCodeScannerDialogState extends State<QRCodeScannerDialog> {

  Function(String) get onScanned => widget.onScanned;

  void showQRCodeScanner() {
    DialogUtility.showContentDialog(
      content: QRCodeScanner(
        onScanned: onScanned,
      ), 
      context: context
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: showQRCodeScanner,
      child: const CircleAvatar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.orange,
        child: Icon(Icons.qr_code_scanner_rounded),
      ),
    );
  }
}