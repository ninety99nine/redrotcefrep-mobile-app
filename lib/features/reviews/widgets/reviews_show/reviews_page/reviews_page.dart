import '../../../../stores/providers/store_provider.dart';
import '../../../../stores/models/shoppable_store.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../reviews_content.dart';

class ReviewsPage extends StatefulWidget {

  static const routeName = 'ReviewsPage';

  const ReviewsPage({
    super.key,
  });

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {

  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  ShoppableStore get store => storeProvider.store!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ReviewsContent(
        store: store,
        showingFullPage: true
      ),
    );
  }
}