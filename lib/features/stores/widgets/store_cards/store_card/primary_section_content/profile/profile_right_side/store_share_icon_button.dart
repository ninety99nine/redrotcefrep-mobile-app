import 'package:bonako_demo/core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import 'package:bonako_demo/core/shared_widgets/icon_button/share_icon_button.dart';
import 'package:bonako_demo/features/stores/providers/store_provider.dart';
import '../../../../../../models/shoppable_store.dart';
import 'package:bonako_demo/core/utils/snackbar.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

class StoreShareIconButton extends StatefulWidget {
  
  final ShoppableStore store;

  const StoreShareIconButton({
    super.key,
    required this.store,
  });

  @override
  State<StoreShareIconButton> createState() => _StoreShareIconButtonState();
}

class _StoreShareIconButtonState extends State<StoreShareIconButton> {

  bool isLoading = false;
  ShoppableStore get store => widget.store;
  void _startLoader() => setState(() => isLoading = true);
  void _stopLoader() => setState(() => isLoading = false);
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);

  void shareStoreProducts() {

    _startLoader();

    Provider.of<StoreProvider>(context, listen: false).setStore(store).storeRepository.showSharableContent()
      .then((http.Response response) {

        if(!mounted) return;

        if( response.statusCode == 200 ) {

          final responseBody = jsonDecode(response.body);
            
          /// Set the sharable content
          final String sharableContent = responseBody['message'];

          /// Share this content with line break tags
          Share.share(sharableContent, subject: store.name);

        }
      
      }).catchError((error) {

        /// Show the error message
        SnackbarUtility.showErrorMessage(message: 'Can\'t share store');

        return error;

      }).whenComplete(() {
    
        _stopLoader();

      });
  }

  @override
  Widget build(BuildContext context) {
    
    return isLoading 
      ? const CustomCircularProgressIndicator(size: 16, alignment: Alignment.centerLeft,)
      : ShareIconButton(size: 16, onTap: shareStoreProducts);

  }
}