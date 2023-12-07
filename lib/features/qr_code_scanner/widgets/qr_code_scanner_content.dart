import 'package:bonako_demo/features/stores/widgets/store_cards/store_card/primary_section_content/store_logo.dart';
import 'package:bonako_demo/features/orders/widgets/order_show/order_full_content/order_full_content.dart';
import 'package:bonako_demo/features/qr_code_scanner/widgets/qr_code_scanner.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import 'package:bonako_demo/features/api/providers/api_provider.dart';
import 'package:bonako_demo/features/orders/models/order.dart';
import 'package:bonako_demo/core/utils/snackbar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QRCodeScannerContent extends StatefulWidget {
  
  final Function(String?)? onScanned;

  const QRCodeScannerContent({
    super.key,
    this.onScanned
  });

  @override
  State<QRCodeScannerContent> createState() => _QRCodeScannerContentState();
}

class _QRCodeScannerContentState extends State<QRCodeScannerContent> {

  Order? order;
  bool isLoading = false;
  AudioPlayer audioPlayer = AudioPlayer();
  bool disableFloatingActionButton = false;

  bool get hasOrder => order != null;
  Function(String?)? get onScanned => widget.onScanned;
  ShoppableStore? get store => order?.relationships.store;

  void _startLoader() => setState(() => isLoading = true);
  void _stopLoader() => setState(() => isLoading = false);
  ApiProvider get apiProvider => Provider.of<ApiProvider>(context, listen: false);

  void _onScanned(String rawValue) {

    /// Notify parent of the raw value captured otherwise respond the detection if the onScanned action is specified
    if(onScanned == null) {

      /// If this raw value contains the collection code, then we scanned a qr code linked to an order 
      if(rawValue.contains('collection_code')) {

        /// Update the order status to completed
        _updateStatusOrderToCompleted(rawValue);

      }

    }else{
      
      onScanned!(rawValue);

    }

  }

  _updateStatusOrderToCompleted(String rawValue) async {

    /// Prevent request while submitting
    if(isLoading) return false;

    _startLoader();

    /**
     *  Split the value into 2 separate parts:
     * 
     *  The QR Code consists of two parts
     * 
     *  1) The url to update the status of this order to completed with the collection code embedded
     *  2) The collection code
     */
    List<String> values = rawValue.split('|');

    /// For our case we just want to extract the the url to update the status of this order to completed
    String url = values[0];

    Map<String, String> queryParams = {
      'with_customer': '1',
      'with_store': '1',
      'with_cart': '1'
    };

    apiProvider.apiRepository.put(url: url, queryParams: queryParams).then((response) {

        if(response.statusCode == 200) {

          /// Play success sound
          audioPlayer.play(AssetSource('sounds/success.mp3'), mode: PlayerMode.lowLatency);

          /// Set the updated order
          setState(() => order = Order.fromJson(response.data));

          /// Show success snackbar
          SnackbarUtility.showSuccessMessage(message: 'Completed');
          
        }else{

          /// Play error sound
          audioPlayer.play(AssetSource('sounds/error.mp3'), mode: PlayerMode.lowLatency);

        }

    }).whenComplete((){

      _stopLoader();

    });

  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [

        SingleChildScrollView(
          child: Column(
            children: [
        
              /// Content
              QRCodeScanner(
                isLoading: isLoading,
                onScanned: _onScanned,
              ),
        
              /// Scanned Order
              if(hasOrder) ...[

                /// Spacer
                const SizedBox(height: 16,),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
              
                      //  Store Logo
                      StoreLogo(store: store!, radius: 16,),

                      /// Spacer
                      const SizedBox(width: 8,),

                      /// Store Name
                      CustomBodyText(store!.name),

                    ],
                  ),
                ),
        
                /// Order Content
                OrderFullContent(
                  key: ValueKey(order!.id),
                  order: order!,
                ),
                
                /// Spacer
                const SizedBox(height: 100,),
        
              ],
        
            ],
          ),
        ),
  
        /// Cancel Icon
        Positioned(
          right: 16,
          top: 32,
          child: IconButton(
            icon: const Icon(Icons.cancel, size: 28, color: Colors.grey),
            onPressed: () => Get.back(),
          ),
        ),
      ],
    );
  }
}