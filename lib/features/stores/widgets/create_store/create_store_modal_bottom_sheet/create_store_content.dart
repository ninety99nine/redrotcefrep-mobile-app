import 'package:bonako_demo/features/stores/widgets/create_store/create_store_form.dart';
import '../../../../../core/shared_widgets/text/custom_title_medium_text.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import '../../../../../core/shared_widgets/text/custom_body_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateStoreContent extends StatefulWidget {
  
  final String? title;
  final String? subtitle;
  final void Function(ShoppableStore)? onCreatedStore;

  const CreateStoreContent({
    super.key,
    this.title,
    this.subtitle,
    this.onCreatedStore,
  });

  @override
  State<CreateStoreContent> createState() => _CreateStoreContentState();
}

class _CreateStoreContentState extends State<CreateStoreContent> {

  String get title => widget.title ?? 'Create Your Store';
  String get subtitle => widget.subtitle ?? 'Lets get your store ready';
  void Function(ShoppableStore)? get onCreatedStore => widget.onCreatedStore;

  Widget get content {
    return CreateStoreForm(
      onCreatedStore: onCreatedStore
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              
                    /// Title
                    CustomTitleMediumText(title, padding: const EdgeInsets.only(bottom: 8),),
                    
                    /// Subtitle
                    CustomBodyText(subtitle),

                    /// Spacer
                    const SizedBox(height: 16),

                    /// Divider
                    const Divider(height: 0),
                    
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                    child: content,
                  ),
                ),
              ),
          
            ],
          ),
    
          /// Cancel Icon
          Positioned(
            right: 10,
            top: 8,
            child: IconButton(
              icon: Icon(Icons.cancel, size: 28, color: Theme.of(context).primaryColor,),
              onPressed: () => Get.back()
            ),
          ),

        ],
      ),
    );
  }
}