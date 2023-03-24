import 'package:bonako_demo/core/shared_widgets/loader/custom_circular_progress_indicator.dart';

import '../../../../core/shared_widgets/text/custom_title_small_text.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/material.dart';

class QRCodeScanner extends StatefulWidget {

  final bool? isLoading;
  final Function(String)? onScanned;

  const QRCodeScanner({
    super.key,
    this.isLoading,
    this.onScanned,
  });

  @override
  State<QRCodeScanner> createState() => _QRCodeScannerState();
}

class _QRCodeScannerState extends State<QRCodeScanner> {

  String? rawValue;

  bool? get isLoading => widget.isLoading;
  Function(String)? get onScanned => widget.onScanned;
  MobileScannerController cameraController = MobileScannerController();
  
  @override
  void dispose() {
    super.dispose();
    cameraController.dispose();
  }

  @override
  void didUpdateWidget(covariant QRCodeScanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    print('cameraController.isStarting');
    print(cameraController.isStarting);
    
    print('isLoading');
    print(isLoading);

    if(isLoading == true) {
      print('cameraController.stop()');
      cameraController.stop();
    }else if(isLoading == false) {
      print('cameraController.start()');
      cameraController.start();
    }
  }

  void onDetect(BarcodeCapture barcodeCapture) {

    /// Get the current raw value
    final newRawValue = barcodeCapture.barcodes.first.rawValue;

    /// If the current raw value is not the same as the new raw value
    if(newRawValue != null && rawValue != newRawValue) {

      /// Set the new raw value as the current raw value
      rawValue = newRawValue;

      /// Notify parent of the raw value captured
      if(onScanned != null ) onScanned!(rawValue!);

      /**
       *  Clear the rawValue after 10 seconds. This is so that you
       *  can scan the same QR Code after 10 seconds.
       */
      Future.delayed(const Duration(seconds: 10)).then((value) {
        
        if(mounted) rawValue = null;

      });

    }

  }

  String compileErrorTitle(MobileScannerErrorCode errorCode) {
    if(errorCode == MobileScannerErrorCode.permissionDenied) {
      return 'Permission Denied';
    }else {
      return 'Scan Failed';
    }
  }

  Widget get toggleTorchIcon {
    return IconButton(
      iconSize: 32,
      onPressed: () => cameraController.toggleTorch(), 
      icon: ValueListenableBuilder(
        valueListenable: cameraController.torchState,
        builder: (context, state, child) {
          switch (state) {
            case TorchState.on:
              return const Icon(Icons.flash_on, size: 20, color: Colors.blue,);
            default:
              return const Icon(Icons.flash_off, size: 20, color: Colors.grey,);
          } 
        },
      )
    );
  }

  Widget get toggleCameraIcon {
    return IconButton(
      iconSize: 32,
      onPressed: () => cameraController.switchCamera(), 
      icon: ValueListenableBuilder(
        valueListenable: cameraController.cameraFacingState,
        builder: (context, state, child) {
          switch (state) {
            case CameraFacing.front:
              return const Icon(Icons.flip_camera_android, size: 16, color: Colors.blue,);
            default:
              return const Icon(Icons.flip_camera_android, size: 16, color: Colors.grey,);
          } 
        },
      )
    );
  }

  Widget get scannerContent {
    return Column(
      children: [

        /// Scanner
        Stack(
          children: [

            /// Mobile Scanner
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: MobileScanner(
                onDetect: onDetect,
                controller: cameraController,
                errorBuilder: (context, error, _) {
                  return Column(
                    children: [
                    
                      /// Error Code
                      CustomTitleSmallText(
                        compileErrorTitle(error.errorCode),
                        margin: const EdgeInsets.only(bottom: 8),
                      ),
                    
                      if(error.errorDetails != null) ...[
                        
                        /// Spacer
                        const SizedBox(height: 8,),
                    
                        /// Error Message
                        CustomBodyText(
                          error.errorDetails!.message,
                          margin: const EdgeInsets.only(bottom: 8),
                        ),
                    
                      ]
                    
                    ],
                  );
                },
              ),
            ),

            /// Toggle Buttons
            Positioned(
              left: 0,
              right: 0,
              bottom: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
            
                  /// Toggle Torch Icon
                  toggleTorchIcon,
            
                  /// Spacer
                  const SizedBox(width: 24,),
            
                  /// Toggle Camera Icon
                  toggleCameraIcon
            
                ],
              ),
            ),

            /// Loader
            if(isLoading == true) const Positioned.fill(
              child: CustomCircularProgressIndicator(),
            ),

          ],
        ),

      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return scannerContent;
  }
}