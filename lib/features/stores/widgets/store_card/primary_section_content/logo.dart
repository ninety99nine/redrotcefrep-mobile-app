import '../../../providers/store_provider.dart';
import '../../../services/store_services.dart';
import '../../../models/shoppable_store.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class StoreLogo extends StatefulWidget {

  final double? radius;
  final ShoppableStore store;

  const StoreLogo({
    Key? key,
    this.radius,
    required this.store,
  }) : super(key: key);

  @override
  State<StoreLogo> createState() => _StoreLogoState();
}

class _StoreLogoState extends State<StoreLogo> {

  ShoppableStore get store => widget.store;
  StoreProvider get storesProvider => Provider.of<StoreProvider>(context, listen: false);

  @override
  Widget build(BuildContext context) {

    /**
     * The onTap() method can be used with an Enum to decide
     * the type of callback that should be executed. For now
     * we just want to navigate to show the store
     */
    return GestureDetector(
      onTap: () => StoreServices.navigateToStorePage(
        store, storesProvider, context
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300,),
          borderRadius: BorderRadius.circular(50)
        ),
        child: CircleAvatar(
          radius: widget.radius,
          backgroundColor: Colors.grey.shade100,
          backgroundImage: store.logo == null ? null : NetworkImage(store.logo!),
        ),
      ),
    );
  }
}