import '../../../../core/shared_widgets/text/custom_title_small_text.dart';
import '../../../../core/shared_widgets/text/custom_title_large_text.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../models/shoppable_store.dart';
import 'package:flutter/material.dart';

class MenuContent extends StatefulWidget {

  final ShoppableStore store;

  const MenuContent({
    super.key,
    required this.store
  });

  @override
  State<MenuContent> createState() => _MenuContentState();
}

class _MenuContentState extends State<MenuContent> {

  List<Map> menus = [
    {
      'name': 'Add To Group',
    }
  ];

  ShoppableStore get store => widget.store;

  /// Content to show based on the specified view
  Widget get content {

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.separated(
        itemCount: menus.length,
        separatorBuilder: (_, __) => const Divider(height: 0,), 
        itemBuilder: (context, index) {
          return Material(                                                                                                                                           
            color: Colors.transparent,                                                                                                                                        
            child: InkWell(                                                                                                                                          
              child: ListTile(
                onTap: () {},
                title: CustomTitleSmallText(menus[index]['name']),
              ),
            ),
          );
        }, 
      ),
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
              
              /// Wrap Padding around the following:
              /// Title, Subtitle, Filters
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 32, bottom: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              
                    /// Title
                    CustomTitleLargeText(store.name, padding: const EdgeInsets.only(bottom: 8),),
                    
                    /// Subtitle
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: CustomBodyText('How can we help you?'),
                    )
                    
                  ],
                ),
              ),
          
              /// Content
              Expanded(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  alignment: Alignment.topCenter,
                  width: double.infinity,
                  color: Colors.white,
                  child: content,
                ),
              )
          
            ],
          ),
  
          /// Cancel Icon
          Positioned(
            right: 10,
            top: 8,
            child: IconButton(
              icon: Icon(Icons.cancel, size: 28, color: Theme.of(context).primaryColor,),
              onPressed: () => Navigator.of(context).pop(),
            ),
          )

        ],
      ),
    );
  }
}